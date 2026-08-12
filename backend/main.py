import os
import math
from datetime import datetime, timezone
from typing import List, Optional
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from supabase import create_client, Client
from dotenv import load_dotenv
from scheduler import start_scheduler

load_dotenv()

app = FastAPI(title="ParkSafe Recommendation API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")

if not SUPABASE_URL or not SUPABASE_KEY:
    print("Warning: Supabase credentials not found in environment variables.")

# Create Supabase client conditionally so docs still work if missing
if SUPABASE_URL and SUPABASE_KEY:
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
else:
    supabase = None

# Start the background notification scheduler
if supabase:
    start_scheduler(supabase)

class RecommendationRequest(BaseModel):
    user_lat: float
    user_lng: float
    vehicle_type: str  # 'car', 'bike', 'ev'
    radius_km: float = 5.0
    limit: int = 5

class RecommendationResponse(BaseModel):
    location_id: str
    name: str
    address: str
    distance_km: float
    eta_minutes: int
    total_slots: int
    free_slots: int
    availability_percentage: int
    availability_score: float
    distance_score: float
    final_score: float
    price_per_hour: float
    google_maps_link: Optional[str] = None
    rating: Optional[float] = None
    image_url: Optional[str] = None


def haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    R = 6371.0 # Earth radius in kilometers
    dLat = math.radians(lat2 - lat1)
    dLon = math.radians(lon2 - lon1)
    a = math.sin(dLat/2)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dLon/2)**2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
    return R * c


@app.post("/recommend", response_model=List[RecommendationResponse])
def recommend_parking(req: RecommendationRequest):
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase client not initialized.")

    # 1. Fetch all parking locations
    locations_res = supabase.table('parking_locations').select('*').execute()
    locations = locations_res.data

    # Filter locations by distance first to optimize
    nearby_locations = []
    for loc in locations:
        if loc.get('lat') is None or loc.get('lng') is None:
            continue
        dist = haversine_distance(req.user_lat, req.user_lng, loc['lat'], loc['lng'])
        if dist <= req.radius_km:
            loc['distance_km'] = dist
            nearby_locations.append(loc)
    
    if not nearby_locations:
        return []

    loc_ids_set = set(loc['id'] for loc in nearby_locations)

    # 2. Fetch slots for the specified vehicle type
    slots_res = supabase.table('parking_slots').select('*')\
        .eq('slot_type', req.vehicle_type).execute()
    
    slots = [s for s in slots_res.data if s.get('location_id') in loc_ids_set]

    # Group slots by location
    loc_total_slots = {loc_id: 0 for loc_id in loc_ids_set}
    loc_slot_ids = {loc_id: set() for loc_id in loc_ids_set}
    
    for slot in slots:
        l_id = slot['location_id']
        loc_total_slots[l_id] += 1
        loc_slot_ids[l_id].add(slot['id'])

    # 3. Fetch active bookings for today to calculate real-time availability
    today_str = datetime.now().strftime('%Y-%m-%d')
    current_time_str = datetime.now().strftime('%H:%M')

    bookings_res = supabase.table('bookings').select('slot_id, start_time, end_time')\
        .eq('booking_date', today_str)\
        .neq('status', 'cancelled').execute()

    bookings = bookings_res.data

    # Calculate occupied slots per location
    loc_occupied_slots = {loc_id: 0 for loc_id in loc_ids_set}
    
    for b in bookings:
        if b.get('start_time') and b.get('end_time') and b['start_time'] <= current_time_str <= b['end_time']:
            slot_id = b.get('slot_id')
            if slot_id:
                for l_id, s_ids in loc_slot_ids.items():
                    if slot_id in s_ids:
                        loc_occupied_slots[l_id] += 1
                        break

    # 4. Calculate scores and build response
    results = []
    for loc in nearby_locations:
        l_id = loc['id']
        total = loc_total_slots.get(l_id, 0)
        
        # If no slots of requested type, skip
        if total == 0:
            continue
            
        occupied = loc_occupied_slots.get(l_id, 0)
        free = max(0, total - occupied)
        
        availability_score = free / total
        availability_percentage = int(availability_score * 100)
        
        distance_km = loc['distance_km']
        distance_score = 1 / (distance_km + 0.1)
        
        distance_weight = 0.60
        availability_weight = 0.40
        final_score = (distance_weight * distance_score) + (availability_weight * availability_score)
        
        eta_minutes = max(1, int(round((distance_km / 25.0) * 60))) # assume 25 km/h
        
        results.append(RecommendationResponse(
            location_id=l_id,
            name=loc['name'],
            address=loc['address'],
            distance_km=round(distance_km, 2),
            eta_minutes=eta_minutes,
            total_slots=total,
            free_slots=free,
            availability_percentage=availability_percentage,
            availability_score=round(availability_score, 2),
            distance_score=round(distance_score, 2),
            final_score=round(final_score, 2),
            price_per_hour=float(loc.get('price_per_hour', 0)),
            google_maps_link=loc.get('google_maps_link'),
            rating=float(loc.get('rating')) if loc.get('rating') is not None else None,
            image_url=loc.get('image_url')
        ))
    
    # Sort by final score descending
    results.sort(key=lambda x: x.final_score, reverse=True)
    
    return results[:req.limit]

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
