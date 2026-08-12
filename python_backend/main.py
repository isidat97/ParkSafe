import os
from fastapi import FastAPI, Query
from fastapi.middleware.cors import CORSMiddleware
from supabase import create_client, Client
from pydantic import BaseModel
from typing import Optional
from datetime import datetime, timedelta
import pandas as pd
import numpy as np

import math

# For a basic time-series model (e.g., Simple Exponential Smoothing)
# If statsmodels is available, we'd use:
# from statsmodels.tsa.holtwinters import SimpleExpSmoothing

def haversine(lat1, lon1, lat2, lon2):
    R = 6371.0 # Radius of earth in km
    dLat = math.radians(lat2 - lat1)
    dLon = math.radians(lon2 - lon1)
    a = (math.sin(dLat / 2) * math.sin(dLat / 2) +
         math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) *
         math.sin(dLon / 2) * math.sin(dLon / 2))
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return R * c

app = FastAPI(title="ParkSafe Predictive Slot Availability")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

SUPABASE_URL = "https://pgmzyatqzqdtdbtxodez.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBnbXp5YXRxenFkdGRidHhvZGV6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY0MTgxMTQsImV4cCI6MjEwMTk5NDExNH0.Fa1o7NTj8Fg_qB56U7NEFlxuLTTR1pJdsdzvQ38X9EI"
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

class PredictionResponse(BaseModel):
    location_id: str
    target_hour: int
    predicted_availability_percentage: float
    total_slots: int
    historical_data_points: int

@app.get("/predict", response_model=PredictionResponse)
def predict_availability(
    location_id: str = Query(..., description="UUID of the parking location"),
    hour: int = Query(..., ge=0, le=23, description="Hour of the day (0-23)")
):
    # 1. Fetch total slots for the location
    loc_res = supabase.table("parking_locations").select("total_slots").eq("id", location_id).execute()
    total_slots = 0
    if loc_res.data:
        total_slots = loc_res.data[0].get("total_slots", 50)
    
    if total_slots == 0:
        return PredictionResponse(
            location_id=location_id,
            target_hour=hour,
            predicted_availability_percentage=100.0,
            total_slots=0,
            historical_data_points=0
        )

    # 2. Fetch past bookings (e.g., last 30 days) to build a time-series
    # We will look at bookings that span across the requested 'hour'.
    thirty_days_ago = (datetime.utcnow() - timedelta(days=30)).isoformat()
    
    # We fetch all bookings for this location from the past 30 days
    # (Since we just need slot occupancy, we'll fetch start_time, end_time, booking_date)
    # Note: Our bookings table has location data implicitly via slot_id, but it might be easier
    # to query all bookings and filter by location if Supabase doesn't easily support nested filtering here.
    # We will fetch slots for this location first.
    slots_res = supabase.table("parking_slots").select("id").eq("location_id", location_id).execute()
    slot_ids = [s["id"] for s in slots_res.data]
    
    if not slot_ids:
        return PredictionResponse(
            location_id=location_id,
            target_hour=hour,
            predicted_availability_percentage=100.0,
            total_slots=total_slots,
            historical_data_points=0
        )
    
    # Supabase Python client limits `in_` list sizes, but assuming it's manageable:
    bookings_res = supabase.table("bookings").select("booking_date, start_time, end_time, status").in_("slot_id", slot_ids).neq("status", "cancelled").execute()
    bookings = bookings_res.data
    
    if not bookings:
        # No history, assume mostly free
        return PredictionResponse(
            location_id=location_id,
            target_hour=hour,
            predicted_availability_percentage=95.0,
            total_slots=total_slots,
            historical_data_points=0
        )
        
    # 3. Time Series Construction
    # We want to find the historical occupancy for 'target_hour' across all days
    occupancy_by_day = {}
    
    for b in bookings:
        b_date = b.get("booking_date")
        if not b_date: continue
        
        # Some bookings are "YYYY-MM-DD to YYYY-MM-DD", we take the first part
        actual_date = b_date.split(" to ")[0].strip()
        
        st_str = b.get("start_time", "12:00 PM")
        et_str = b.get("end_time", "1:00 PM")
        
        # Parse times (rough approximation)
        try:
            st = pd.to_datetime(f"{actual_date} {st_str}").hour
            et = pd.to_datetime(f"{actual_date} {et_str}").hour
            # Adjust for overnight
            if et < st:
                et += 24
        except Exception:
            continue
            
        # Does it overlap with our target hour?
        # A booking overlaps if st <= target_hour < et
        target_eval = hour
        if target_eval < st and target_eval + 24 < et:
            # Handle cross-midnight logic simply
            target_eval += 24
            
        if st <= target_eval < et:
            occupancy_by_day[actual_date] = occupancy_by_day.get(actual_date, 0) + 1
            
    if not occupancy_by_day:
        return PredictionResponse(
            location_id=location_id,
            target_hour=hour,
            predicted_availability_percentage=95.0,
            total_slots=total_slots,
            historical_data_points=len(bookings)
        )
        
    # Build series
    # Sort dates
    sorted_dates = sorted(list(occupancy_by_day.keys()))
    series = [occupancy_by_day[d] for d in sorted_dates]
    
    # Basic moving average prediction (last 3 occurrences)
    if len(series) >= 3:
        predicted_occupancy = sum(series[-3:]) / 3.0
    else:
        predicted_occupancy = sum(series) / len(series)
        
    # Availability percentage = max(0, min(100, (total - occupied) / total * 100))
    availability_pct = ((total_slots - predicted_occupancy) / total_slots) * 100
    availability_pct = max(0.0, min(100.0, availability_pct))
    
    return PredictionResponse(
        location_id=location_id,
        target_hour=hour,
        predicted_availability_percentage=round(availability_pct, 1),
        total_slots=total_slots,
        historical_data_points=len(bookings)
    )

class RecommendRequest(BaseModel):
    user_lat: float
    user_lng: float
    vehicle_type: str
    radius_km: float = 5.0
    limit: int = 5

@app.post("/recommend")
def recommend_parking(req: RecommendRequest):
    # 1. Fetch all locations
    loc_res = supabase.table("parking_locations").select("*").execute()
    locations = loc_res.data
    
    if not locations:
        return []
        
    candidates = []
    
    for loc in locations:
        lat = loc.get("lat")
        lng = loc.get("lng")
        if lat is None or lng is None:
            continue
            
        dist = haversine(req.user_lat, req.user_lng, lat, lng)
        if dist > req.radius_km:
            continue
            
        candidates.append({
            "location": loc,
            "distance_km": dist
        })
        
    if not candidates:
        return []
        
    # 2. For each candidate, fetch slots of vehicle_type
    results = []
    
    # We only care about current active bookings
    now_local = datetime.utcnow() + timedelta(hours=5, minutes=30) # Assuming IST for simple check, or just rely on status
    current_date_str = now_local.strftime("%Y-%m-%d")
    
    for cand in candidates:
        loc = cand["location"]
        loc_id = loc["id"]
        dist = cand["distance_km"]
        
        # Get slots
        slots_res = supabase.table("parking_slots").select("id").eq("location_id", loc_id).eq("slot_type", req.vehicle_type).eq("is_active", True).execute()
        slot_ids = [s["id"] for s in slots_res.data]
        total_slots = len(slot_ids)
        
        if total_slots == 0:
            continue
            
        # Get active bookings for these slots (simplification: status not cancelled, completed)
        # For a truly robust check, we'd check overlapping time.
        bookings_res = supabase.table("bookings").select("id, status").in_("slot_id", slot_ids).in_("status", ["pending", "confirmed"]).execute()
        active_bookings = len(bookings_res.data)
        
        free_slots = max(0, total_slots - active_bookings)
        availability_score = free_slots / total_slots
        availability_pct = round(availability_score * 100)
        
        distance_score = 1 / (dist + 0.1)
        
        # 60% distance, 40% availability
        final_score = (0.6 * distance_score) + (0.4 * availability_score)
        
        # ETA calculation (avg speed 25 km/h)
        eta_minutes = round((dist / 25.0) * 60)
        
        results.append({
            "location_id": loc_id,
            "name": loc.get("name"),
            "address": loc.get("address"),
            "distance_km": round(dist, 2),
            "eta_minutes": eta_minutes,
            "total_slots": total_slots,
            "free_slots": free_slots,
            "availability_percentage": availability_pct,
            "availability_score": round(availability_score, 2),
            "distance_score": round(distance_score, 2),
            "final_score": round(final_score, 3),
            "price_per_hour": loc.get("price_per_hour"),
            "google_maps_link": loc.get("google_maps_link")
        })
        
    # Sort by final score descending
    results.sort(key=lambda x: x["final_score"], reverse=True)
    return results[:req.limit]

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
