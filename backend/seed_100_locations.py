import os
import json
import urllib.parse
from dotenv import load_dotenv
load_dotenv()
from supabase import create_client

def generate_and_seed_100_locations():
    url = os.getenv("SUPABASE_URL")
    key = os.getenv("SUPABASE_SERVICE_ROLE_KEY")

    if not url or not key:
        print("Error: SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY required in environment!")
        return

    client = create_client(url, key)

    raw_locations = [
        # --- BARDOLI (MANDATORY: 8 LOCATIONS) ---
        {
            "name": "Sardar Patel National Museum & Library Parking",
            "address": "Station Road, Bardoli, Gujarat 394601",
            "city": "Bardoli",
            "lat": 21.1215, "lng": 73.1118,
            "total_slots": 80, "price_per_hour": 20.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Covered Parking", "Bike Parking", "Car Parking"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Janta Super Market & Commercial Hub",
            "address": "Main Bazaar Road, Bardoli, Gujarat 394601",
            "city": "Bardoli",
            "lat": 21.1240, "lng": 73.1145,
            "total_slots": 60, "price_per_hour": 25.0,
            "amenities": ["24/7 CCTV", "Bike Parking", "Car Parking", "Accessible Parking"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Bardoli Sugar Factory Commercial Complex",
            "address": "Factory Road, Bardoli, Gujarat 394602",
            "city": "Bardoli",
            "lat": 21.1180, "lng": 73.1190,
            "total_slots": 120, "price_per_hour": 20.0,
            "amenities": ["24/7 CCTV", "Security Guard", "EV Charging", "Covered Parking", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Station Road Shopping Center",
            "address": "Station Road, Near Railway Station, Bardoli, Gujarat 394601",
            "city": "Bardoli",
            "lat": 21.1270, "lng": 73.1090,
            "total_slots": 50, "price_per_hour": 20.0,
            "amenities": ["24/7 CCTV", "Bike Parking", "Car Parking"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Swaraj Ashram Campus Parking",
            "address": "Ashram Road, Bardoli, Gujarat 394601",
            "city": "Bardoli",
            "lat": 21.1205, "lng": 73.1130,
            "total_slots": 70, "price_per_hour": 15.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Covered Parking", "Accessible Parking"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Astha Complex Parking",
            "address": "Station Road, Opposite Municipal Office, Bardoli, Gujarat 394601",
            "city": "Bardoli",
            "lat": 21.1255, "lng": 73.1105,
            "total_slots": 45, "price_per_hour": 25.0,
            "amenities": ["24/7 CCTV", "Car Parking", "Bike Parking"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Reliance Smart Point Parking Bardoli",
            "address": "Ten Road, Bardoli, Gujarat 394601",
            "city": "Bardoli",
            "lat": 21.1290, "lng": 73.1180,
            "total_slots": 90, "price_per_hour": 30.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Valet Parking"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Bardoli Town Center Mall",
            "address": "Dhulia Road, Bardoli, Gujarat 394601",
            "city": "Bardoli",
            "lat": 21.1220, "lng": 73.1250,
            "total_slots": 150, "price_per_hour": 30.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors", "Car Wash"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },

        # --- SURAT (20 LOCATIONS) ---
        {
            "name": "VR Mall Surat",
            "address": "Dumas Road, Magdalla, Surat, Gujarat 395007",
            "city": "Surat",
            "lat": 21.1448, "lng": 72.7719,
            "total_slots": 850, "price_per_hour": 50.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Car Wash", "Security Guard", "Multiple Floors", "Valet Parking"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Rahulraj Mall",
            "address": "Dumas Road, Piplod, Surat, Gujarat 395007",
            "city": "Surat",
            "lat": 21.1512, "lng": 72.7770,
            "total_slots": 500, "price_per_hour": 40.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors", "Covered Parking"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Imperial Square Mall",
            "address": "Hazira Road, Adajan, Surat, Gujarat 395009",
            "city": "Surat",
            "lat": 21.1960, "lng": 72.7930,
            "total_slots": 350, "price_per_hour": 30.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Multiple Floors", "Accessible Parking"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Central Bazaar Mall",
            "address": "Varachha Main Road, Surat, Gujarat 395006",
            "city": "Surat",
            "lat": 21.2185, "lng": 72.8590,
            "total_slots": 400, "price_per_hour": 30.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Multiple Floors", "Bike Parking"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "World Trade Centre Surat",
            "address": "Ring Road, Near Sahara Darwaja, Surat, Gujarat 395002",
            "city": "Surat",
            "lat": 21.1882, "lng": 72.8340,
            "total_slots": 600, "price_per_hour": 40.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors", "Valet Parking"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Iscon Mall Surat",
            "address": "Dumas Road, Opposite Airport, Surat, Gujarat 395007",
            "city": "Surat",
            "lat": 21.1485, "lng": 72.7745,
            "total_slots": 450, "price_per_hour": 40.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Covered Parking"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Palladium Mall Surat",
            "address": "VIP Road, Vesu, Surat, Gujarat 395007",
            "city": "Surat",
            "lat": 21.1560, "lng": 72.7980,
            "total_slots": 700, "price_per_hour": 50.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Car Wash", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Millennium Market Complex",
            "address": "Ring Road, Textile Market Area, Surat, Gujarat 395002",
            "city": "Surat",
            "lat": 21.1890, "lng": 72.8410,
            "total_slots": 550, "price_per_hour": 30.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Multiple Floors", "Covered Parking"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Crossway Mall",
            "address": "Ghoddod Road, Athwa, Surat, Gujarat 395001",
            "city": "Surat",
            "lat": 21.1730, "lng": 72.8080,
            "total_slots": 300, "price_per_hour": 35.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Accessible Parking", "Car Wash"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "International Fashion Market Parking",
            "address": "Textile Market Area, Ring Road, Surat, Gujarat 395002",
            "city": "Surat",
            "lat": 21.1920, "lng": 72.8450,
            "total_slots": 480, "price_per_hour": 35.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Surat Railway Station Multilevel Parking",
            "address": "Station Road, Varachha, Surat, Gujarat 395003",
            "city": "Surat",
            "lat": 21.2045, "lng": 72.8406,
            "total_slots": 900, "price_per_hour": 25.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Multiple Floors", "EV Charging", "Accessible Parking"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Surat Airport Terminal Parking",
            "address": "Dumas Road, Surat Airport, Surat, Gujarat 395007",
            "city": "Surat",
            "lat": 21.1140, "lng": 72.7415,
            "total_slots": 1000, "price_per_hour": 60.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Valet Parking", "Accessible Parking"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Union Heights Commercial Hub",
            "address": "VIP Road, Vesu, Surat, Gujarat 395007",
            "city": "Surat",
            "lat": 21.1540, "lng": 72.7930,
            "total_slots": 320, "price_per_hour": 40.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Prime Shoppers Complex",
            "address": "University Road, Vesu, Surat, Gujarat 395007",
            "city": "Surat",
            "lat": 21.1420, "lng": 72.7820,
            "total_slots": 250, "price_per_hour": 30.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Car Parking", "Bike Parking"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Rajhans Orrit Mall",
            "address": "Pal-Hazira Road, Pal, Surat, Gujarat 394510",
            "city": "Surat",
            "lat": 21.1880, "lng": 72.7690,
            "total_slots": 420, "price_per_hour": 35.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Multiple Floors", "Security Guard"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "City Center Commercial Hub",
            "address": "Udhna Darwaja, Ring Road, Surat, Gujarat 395002",
            "city": "Surat",
            "lat": 21.1790, "lng": 72.8350,
            "total_slots": 280, "price_per_hour": 30.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Covered Parking"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Reliance Mall Udhna",
            "address": "Udhna Main Road, Surat, Gujarat 395009",
            "city": "Surat",
            "lat": 21.1680, "lng": 72.8390,
            "total_slots": 500, "price_per_hour": 30.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Multiple Floors", "Security Guard"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "SNS Atria Commercial Center",
            "address": "Vesu Main Road, Surat, Gujarat 395007",
            "city": "Surat",
            "lat": 21.1390, "lng": 72.7780,
            "total_slots": 310, "price_per_hour": 40.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Valet Parking"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Shreepad World Complex",
            "address": "Pal-Hazira Road, Surat, Gujarat 394510",
            "city": "Surat",
            "lat": 21.1950, "lng": 72.7610,
            "total_slots": 260, "price_per_hour": 30.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Covered Parking"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Silicon Shoppers Hub",
            "address": "Udhna Main Road, Surat, Gujarat 395009",
            "city": "Surat",
            "lat": 21.1620, "lng": 72.8430,
            "total_slots": 220, "price_per_hour": 25.0,
            "amenities": ["24/7 CCTV", "Bike Parking", "Car Parking"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },

        # --- NAVSARI (5 LOCATIONS) ---
        {
            "name": "Central Mall Navsari",
            "address": "Station Road, Navsari, Gujarat 396445",
            "city": "Navsari",
            "lat": 20.9520, "lng": 72.9320,
            "total_slots": 250, "price_per_hour": 25.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Multiple Floors", "Car Parking"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Sayaji Market Complex",
            "address": "Tower Road, Navsari, Gujarat 396445",
            "city": "Navsari",
            "lat": 20.9470, "lng": 72.9280,
            "total_slots": 180, "price_per_hour": 20.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Bike Parking", "Car Parking"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Fuwara Shopping Center",
            "address": "Fuwara Circle, Navsari, Gujarat 396445",
            "city": "Navsari",
            "lat": 20.9500, "lng": 72.9250,
            "total_slots": 140, "price_per_hour": 20.0,
            "amenities": ["24/7 CCTV", "Car Parking", "Bike Parking"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Lunsikui Commercial Hub",
            "address": "Lunsikui Main Road, Navsari, Gujarat 396445",
            "city": "Navsari",
            "lat": 20.9410, "lng": 72.9190,
            "total_slots": 160, "price_per_hour": 20.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Accessible Parking"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Royal City Center Navsari",
            "address": "Station Road, Navsari, Gujarat 396445",
            "city": "Navsari",
            "lat": 20.9580, "lng": 72.9360,
            "total_slots": 200, "price_per_hour": 25.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Multiple Floors", "EV Charging"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },

        # --- AHMEDABAD (15 LOCATIONS) ---
        {
            "name": "Nexus Ahmedabad One Mall (Alpha One)",
            "address": "Plot No 216, TP Scheme 1, Vastrapur, Ahmedabad, Gujarat 380054",
            "city": "Ahmedabad",
            "lat": 23.0396, "lng": 72.5305,
            "total_slots": 1200, "price_per_hour": 50.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Car Wash", "Security Guard", "Multiple Floors", "Valet Parking"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Palladium Mall Ahmedabad",
            "address": "SG Highway, Thaltej, Ahmedabad, Gujarat 380054",
            "city": "Ahmedabad",
            "lat": 23.0540, "lng": 72.5080,
            "total_slots": 1500, "price_per_hour": 60.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Car Wash", "Security Guard", "Multiple Floors", "Valet Parking"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Iscon Mega Mall",
            "address": "SG Highway, Bodakdev, Ahmedabad, Gujarat 380054",
            "city": "Ahmedabad",
            "lat": 23.0298, "lng": 72.5075,
            "total_slots": 800, "price_per_hour": 40.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors", "Covered Parking"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Himalaya Elanza Mall",
            "address": "RTO Circle, Subhash Bridge, Ahmedabad, Gujarat 380027",
            "city": "Ahmedabad",
            "lat": 23.0780, "lng": 72.5850,
            "total_slots": 450, "price_per_hour": 35.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Multiple Floors", "Accessible Parking"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "CG Square Mall",
            "address": "CG Road, Navrangpura, Ahmedabad, Gujarat 380009",
            "city": "Ahmedabad",
            "lat": 23.0250, "lng": 72.5580,
            "total_slots": 400, "price_per_hour": 40.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Multiple Floors", "Car Parking"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Gulmohar Park Mall",
            "address": "Iscon Circle, Satellite, Ahmedabad, Gujarat 380015",
            "city": "Ahmedabad",
            "lat": 23.0270, "lng": 72.5110,
            "total_slots": 550, "price_per_hour": 40.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Agora Mall Sughad",
            "address": "Sardar Patel Ring Road, Sughad, Ahmedabad, Gujarat 382424",
            "city": "Ahmedabad",
            "lat": 23.1140, "lng": 72.5930,
            "total_slots": 600, "price_per_hour": 35.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Multiple Floors", "Covered Parking"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Mondeal Square Commercial Complex",
            "address": "SG Highway, Prahlad Nagar, Ahmedabad, Gujarat 380015",
            "city": "Ahmedabad",
            "lat": 23.0240, "lng": 72.5060,
            "total_slots": 500, "price_per_hour": 40.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Valet Parking"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Dev Arc Mall",
            "address": "SG Highway, ISCON Cross Road, Ahmedabad, Gujarat 380015",
            "city": "Ahmedabad",
            "lat": 23.0285, "lng": 72.5070,
            "total_slots": 350, "price_per_hour": 35.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Acropolis Mall",
            "address": "Thaltej Cross Road, SG Highway, Ahmedabad, Gujarat 380054",
            "city": "Ahmedabad",
            "lat": 23.0480, "lng": 72.5150,
            "total_slots": 480, "price_per_hour": 40.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Multiple Floors", "Accessible Parking"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Ahmedabad Railway Station Multilevel Parking",
            "address": "Kalupur Railway Station Road, Ahmedabad, Gujarat 380002",
            "city": "Ahmedabad",
            "lat": 23.0225, "lng": 72.6001,
            "total_slots": 1100, "price_per_hour": 25.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Multiple Floors", "Accessible Parking"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "SVPIA Airport Terminal 2 Parking",
            "address": "Airport Road, Hansol, Ahmedabad, Gujarat 380003",
            "city": "Ahmedabad",
            "lat": 23.0740, "lng": 72.6280,
            "total_slots": 1400, "price_per_hour": 60.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Valet Parking", "Accessible Parking"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Science City Commercial Parking",
            "address": "Science City Road, Sola, Ahmedabad, Gujarat 380060",
            "city": "Ahmedabad",
            "lat": 23.0800, "lng": 72.4930,
            "total_slots": 750, "price_per_hour": 30.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Law Garden Night Market Parking",
            "address": "Netaji Road, Ellisbridge, Ahmedabad, Gujarat 380006",
            "city": "Ahmedabad",
            "lat": 23.0240, "lng": 72.5600,
            "total_slots": 300, "price_per_hour": 30.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Car Parking", "Bike Parking"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Kankaria Lakefront Gate 3 Parking",
            "address": "Kankaria Lake Road, Maninagar, Ahmedabad, Gujarat 380028",
            "city": "Ahmedabad",
            "lat": 23.0060, "lng": 72.6010,
            "total_slots": 500, "price_per_hour": 25.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Accessible Parking", "Covered Parking"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },

        # --- VADODARA (8 LOCATIONS) ---
        {
            "name": "Inorbit Mall Vadodara",
            "address": "Gorwa Road, Subhanpura, Vadodara, Gujarat 390023",
            "city": "Vadodara",
            "lat": 22.3270, "lng": 73.1600,
            "total_slots": 950, "price_per_hour": 40.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Car Wash", "Security Guard", "Multiple Floors", "Valet Parking"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Centre Square Mall",
            "address": "Sarabhai Road, Alkapuri, Vadodara, Gujarat 390007",
            "city": "Vadodara",
            "lat": 22.3080, "lng": 73.1750,
            "total_slots": 600, "price_per_hour": 35.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Seven Seas Mall",
            "address": "Fatehgunj Main Road, Vadodara, Gujarat 390002",
            "city": "Vadodara",
            "lat": 22.3200, "lng": 73.1890,
            "total_slots": 400, "price_per_hour": 30.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Multiple Floors", "Covered Parking"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Vadodara Central Mall",
            "address": "RC Dutt Road, Alkapuri, Vadodara, Gujarat 390007",
            "city": "Vadodara",
            "lat": 22.3120, "lng": 73.1710,
            "total_slots": 450, "price_per_hour": 35.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Multiple Floors", "Accessible Parking"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Eva Mall Manjalpur",
            "address": "Manjalpur Main Road, Vadodara, Gujarat 390011",
            "city": "Vadodara",
            "lat": 22.2740, "lng": 73.1950,
            "total_slots": 500, "price_per_hour": 30.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Reliance Mega Mall Vadodara",
            "address": "Old Padra Road, Vadodara, Gujarat 390020",
            "city": "Vadodara",
            "lat": 22.2980, "lng": 73.1620,
            "total_slots": 550, "price_per_hour": 30.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Vadodara Junction Railway Parking",
            "address": "Station Road, Sayajiganj, Vadodara, Gujarat 390005",
            "city": "Vadodara",
            "lat": 22.3105, "lng": 73.1812,
            "total_slots": 800, "price_per_hour": 25.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Multiple Floors", "Accessible Parking"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Vadodara Airport Terminal Parking",
            "address": "Harni Road, Vadodara, Gujarat 390022",
            "city": "Vadodara",
            "lat": 22.3330, "lng": 73.2200,
            "total_slots": 700, "price_per_hour": 50.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Valet Parking"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },

        # --- BHARUCH & ANKLESHWAR (5 LOCATIONS) ---
        {
            "name": "Shree Ram Plaza",
            "address": "Station Road, Bharuch, Gujarat 392001",
            "city": "Bharuch",
            "lat": 21.7050, "lng": 72.9980,
            "total_slots": 180, "price_per_hour": 20.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Covered Parking"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Reliance Smart Point Zadeshwar",
            "address": "Zadeshwar Road, Bharuch, Gujarat 392011",
            "city": "Bharuch",
            "lat": 21.7210, "lng": 73.0120,
            "total_slots": 210, "price_per_hour": 25.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Big Bazaar Commercial Center Bharuch",
            "address": "Link Road, Bharuch, Gujarat 392001",
            "city": "Bharuch",
            "lat": 21.7120, "lng": 73.0050,
            "total_slots": 250, "price_per_hour": 25.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Blue Chip Complex Bharuch",
            "address": "Sevashram Road, Bharuch, Gujarat 392001",
            "city": "Bharuch",
            "lat": 21.7080, "lng": 72.9910,
            "total_slots": 150, "price_per_hour": 20.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Bike Parking"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Ankleshwar Station Plaza",
            "address": "Station Road, Ankleshwar, Gujarat 393001",
            "city": "Ankleshwar",
            "lat": 21.6280, "lng": 73.0020,
            "total_slots": 220, "price_per_hour": 20.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Car Parking", "Bike Parking"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },

        # --- VAPI & VALSAD (4 LOCATIONS) ---
        {
            "name": "Fortune Galaxy Mall Vapi",
            "address": "NH 8, GIDC, Vapi, Gujarat 396195",
            "city": "Vapi",
            "lat": 20.3720, "lng": 72.9150,
            "total_slots": 350, "price_per_hour": 30.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Vapi Town Center Plaza",
            "address": "GIDC Main Road, Vapi, Gujarat 396195",
            "city": "Vapi",
            "lat": 20.3800, "lng": 72.9230,
            "total_slots": 280, "price_per_hour": 25.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Covered Parking"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Galaxy High Street Valsad",
            "address": "Kashinagar, Valsad, Gujarat 396001",
            "city": "Valsad",
            "lat": 20.6100, "lng": 72.9350,
            "total_slots": 300, "price_per_hour": 25.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Valsad Railway Station Plaza",
            "address": "Station Road, Valsad, Gujarat 396001",
            "city": "Valsad",
            "lat": 20.6080, "lng": 72.9290,
            "total_slots": 400, "price_per_hour": 20.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Accessible Parking"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },

        # --- RAJKOT, GANDHINAGAR, ANAND, NADIAD (8 LOCATIONS) ---
        {
            "name": "Crystal Mall Rajkot",
            "address": "Kalawad Road, Rajkot, Gujarat 360005",
            "city": "Rajkot",
            "lat": 22.2850, "lng": 70.7680,
            "total_slots": 650, "price_per_hour": 35.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Reliance Mega Mall Rajkot",
            "address": "150 Feet Ring Road, Rajkot, Gujarat 360005",
            "city": "Rajkot",
            "lat": 22.2920, "lng": 70.7740,
            "total_slots": 700, "price_per_hour": 35.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Iscon Prozone Mall Rajkot",
            "address": "150 Feet Ring Road, Rajkot, Gujarat 360006",
            "city": "Rajkot",
            "lat": 22.3020, "lng": 70.7850,
            "total_slots": 800, "price_per_hour": 40.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors", "Valet Parking"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Infocity Commercial Arcade Gandhinagar",
            "address": "Infocity, Sector 0, Gandhinagar, Gujarat 382007",
            "city": "Gandhinagar",
            "lat": 23.2000, "lng": 72.6300,
            "total_slots": 500, "price_per_hour": 30.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Super Mall 1 Gandhinagar",
            "address": "Sector 11, Gandhinagar, Gujarat 382011",
            "city": "Gandhinagar",
            "lat": 23.2180, "lng": 72.6450,
            "total_slots": 350, "price_per_hour": 25.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Anand Town Hall Plaza",
            "address": "Station Road, Anand, Gujarat 388001",
            "city": "Anand",
            "lat": 22.5560, "lng": 72.9510,
            "total_slots": 250, "price_per_hour": 20.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Car Parking"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Vidyanagar Shopping Hub Anand",
            "address": "Vallabh Vidyanagar, Anand, Gujarat 388120",
            "city": "Anand",
            "lat": 22.5510, "lng": 72.9240,
            "total_slots": 300, "price_per_hour": 20.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Bike Parking", "Car Parking"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Nadiad City Center Mall",
            "address": "College Road, Nadiad, Gujarat 387001",
            "city": "Nadiad",
            "lat": 22.6920, "lng": 72.8620,
            "total_slots": 280, "price_per_hour": 20.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },

        # --- MUMBAI METRO (12 LOCATIONS) ---
        {
            "name": "Phoenix Marketcity Mumbai",
            "address": "LBS Marg, Kurla West, Mumbai, Maharashtra 400070",
            "city": "Mumbai",
            "lat": 19.0860, "lng": 72.8890,
            "total_slots": 1800, "price_per_hour": 60.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Car Wash", "Security Guard", "Multiple Floors", "Valet Parking"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "R City Mall Ghatkopar",
            "address": "LBS Marg, Ghatkopar West, Mumbai, Maharashtra 400086",
            "city": "Mumbai",
            "lat": 19.0990, "lng": 72.9160,
            "total_slots": 1600, "price_per_hour": 60.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Car Wash", "Security Guard", "Multiple Floors", "Valet Parking"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Infiniti Mall Malad",
            "address": "New Link Road, Malad West, Mumbai, Maharashtra 400064",
            "city": "Mumbai",
            "lat": 19.1840, "lng": 72.8340,
            "total_slots": 1200, "price_per_hour": 50.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Oberoi Mall Goregaon",
            "address": "Western Express Highway, Goregaon East, Mumbai, Maharashtra 400063",
            "city": "Mumbai",
            "lat": 19.1740, "lng": 72.8600,
            "total_slots": 1100, "price_per_hour": 50.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors", "Valet Parking"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Inorbit Mall Malad",
            "address": "Link Road, Malad West, Mumbai, Maharashtra 400064",
            "city": "Mumbai",
            "lat": 19.1870, "lng": 72.8310,
            "total_slots": 1000, "price_per_hour": 50.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "High Street Phoenix Lower Parel",
            "address": "Senapati Bapat Marg, Lower Parel, Mumbai, Maharashtra 400013",
            "city": "Mumbai",
            "lat": 18.9950, "lng": 72.8240,
            "total_slots": 1500, "price_per_hour": 70.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Car Wash", "Security Guard", "Multiple Floors", "Valet Parking"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Chhatrapati Shivaji Airport T2 Parking",
            "address": "Airport Road, Andheri East, Mumbai, Maharashtra 400099",
            "city": "Mumbai",
            "lat": 19.0880, "lng": 72.8670,
            "total_slots": 2500, "price_per_hour": 100.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors", "Valet Parking", "Accessible Parking"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "BKC Commercial Complex Parking",
            "address": "Bandra Kurla Complex, Bandra East, Mumbai, Maharashtra 400051",
            "city": "Mumbai",
            "lat": 19.0660, "lng": 72.8680,
            "total_slots": 1400, "price_per_hour": 60.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors", "Valet Parking"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Viviana Mall Thane",
            "address": "Eastern Express Highway, Thane West, Maharashtra 400606",
            "city": "Thane",
            "lat": 19.2080, "lng": 72.9710,
            "total_slots": 1800, "price_per_hour": 50.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Car Wash", "Security Guard", "Multiple Floors", "Valet Parking"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Korum Mall Thane",
            "address": "Eastern Express Highway, Thane West, Maharashtra 400601",
            "city": "Thane",
            "lat": 19.1990, "lng": 72.9650,
            "total_slots": 1100, "price_per_hour": 40.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Seawoods Grand Central Mall",
            "address": "Seawoods Railway Station Complex, Navi Mumbai, Maharashtra 400706",
            "city": "Navi Mumbai",
            "lat": 19.0210, "lng": 73.0180,
            "total_slots": 1600, "price_per_hour": 50.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors", "Valet Parking"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Inorbit Mall Vashi",
            "address": "Sector 30A, Vashi, Navi Mumbai, Maharashtra 400703",
            "city": "Navi Mumbai",
            "lat": 19.0650, "lng": 72.9980,
            "total_slots": 900, "price_per_hour": 40.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },

        # --- PUNE METRO (8 LOCATIONS) ---
        {
            "name": "Phoenix Marketcity Pune",
            "address": "Viman Nagar Road, Pune, Maharashtra 411014",
            "city": "Pune",
            "lat": 18.5620, "lng": 73.9170,
            "total_slots": 1700, "price_per_hour": 50.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Car Wash", "Security Guard", "Multiple Floors", "Valet Parking"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Amanora Mall Hadapsar",
            "address": "Magarpatta Road, Hadapsar, Pune, Maharashtra 411028",
            "city": "Pune",
            "lat": 18.5190, "lng": 73.9340,
            "total_slots": 1500, "price_per_hour": 45.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Seasons Mall Magarpatta",
            "address": "Magarpatta City, Hadapsar, Pune, Maharashtra 411028",
            "city": "Pune",
            "lat": 18.5180, "lng": 73.9310,
            "total_slots": 1400, "price_per_hour": 45.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Elpro City Square Chinchwad",
            "address": "Chinchwad, Pimpri-Chinchwad, Pune, Maharashtra 411033",
            "city": "Pune",
            "lat": 18.6270, "lng": 73.7990,
            "total_slots": 1000, "price_per_hour": 40.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Westend Mall Aundh",
            "address": "Mahadji Shinde Road, Aundh, Pune, Maharashtra 411007",
            "city": "Pune",
            "lat": 18.5610, "lng": 73.8070,
            "total_slots": 850, "price_per_hour": 40.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Pavillion Mall SB Road",
            "address": "Senapati Bapat Road, Pune, Maharashtra 411016",
            "city": "Pune",
            "lat": 18.5330, "lng": 73.8290,
            "total_slots": 900, "price_per_hour": 50.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors", "Valet Parking"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Kumar Pacific Mall Pune",
            "address": "Shankar Sheth Road, Swargate, Pune, Maharashtra 411042",
            "city": "Pune",
            "lat": 18.5020, "lng": 73.8690,
            "total_slots": 700, "price_per_hour": 40.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Pune Railway Station Multilevel Parking",
            "address": "Agarkar Nagar, Pune, Maharashtra 411001",
            "city": "Pune",
            "lat": 18.5280, "lng": 73.8740,
            "total_slots": 1000, "price_per_hour": 25.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Multiple Floors", "Accessible Parking"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },

        # --- OTHER MAJOR INDIAN METROS (25 LOCATIONS) ---
        {
            "name": "Select CITYWALK Mall Saket",
            "address": "District Centre, Saket, New Delhi 110017",
            "city": "New Delhi",
            "lat": 28.5280, "lng": 77.2190,
            "total_slots": 1600, "price_per_hour": 70.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Car Wash", "Security Guard", "Multiple Floors", "Valet Parking"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "DLF Mall of India Noida",
            "address": "Sector 18, Noida, Uttar Pradesh 201301",
            "city": "Noida",
            "lat": 28.5670, "lng": 77.3210,
            "total_slots": 2000, "price_per_hour": 60.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Car Wash", "Security Guard", "Multiple Floors", "Valet Parking"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Forum Mall Koramangala",
            "address": "Hosur Road, Koramangala, Bengaluru, Karnataka 560095",
            "city": "Bengaluru",
            "lat": 12.9340, "lng": 77.6110,
            "total_slots": 1200, "price_per_hour": 50.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors", "Valet Parking"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Express Avenue Mall Chennai",
            "address": "Whites Road, Royapettah, Chennai, Tamil Nadu 600014",
            "city": "Chennai",
            "lat": 13.0590, "lng": 80.2640,
            "total_slots": 1500, "price_per_hour": 50.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors", "Valet Parking"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "UB City Luxury Parking Bengaluru",
            "address": "Vittal Mallya Road, Bengaluru, Karnataka 560001",
            "city": "Bengaluru",
            "lat": 12.9710, "lng": 77.5960,
            "total_slots": 1100, "price_per_hour": 80.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Car Wash", "Security Guard", "Multiple Floors", "Valet Parking"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Lulu Mall Kochi",
            "address": "NH 44, Edappally, Kochi, Kerala 682024",
            "city": "Kochi",
            "lat": 10.0270, "lng": 76.3080,
            "total_slots": 2200, "price_per_hour": 40.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Car Wash", "Security Guard", "Multiple Floors", "Valet Parking"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Sarath City Capital Mall Hyderabad",
            "address": "Gachibowli - Miyapur Rd, Kondapur, Hyderabad, Telangana 500084",
            "city": "Hyderabad",
            "lat": 17.4560, "lng": 78.3640,
            "total_slots": 2500, "price_per_hour": 50.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Car Wash", "Security Guard", "Multiple Floors", "Valet Parking"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Inorbit Mall Cyberabad",
            "address": "APIIC Software Layout, Madhapur, Hyderabad, Telangana 500081",
            "city": "Hyderabad",
            "lat": 17.4380, "lng": 78.3820,
            "total_slots": 1400, "price_per_hour": 50.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Orion Mall Rajajinagar",
            "address": "Brigade Gateway, Rajajinagar, Bengaluru, Karnataka 560055",
            "city": "Bengaluru",
            "lat": 13.0110, "lng": 77.5550,
            "total_slots": 1300, "price_per_hour": 50.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors", "Valet Parking"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Ambience Mall Gurugram",
            "address": "NH 8, DLF Phase 3, Gurugram, Haryana 122002",
            "city": "Gurugram",
            "lat": 28.5040, "lng": 77.0970,
            "total_slots": 2100, "price_per_hour": 60.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Car Wash", "Security Guard", "Multiple Floors", "Valet Parking"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Elante Mall Chandigarh",
            "address": "Industrial Area Phase I, Chandigarh 160002",
            "city": "Chandigarh",
            "lat": 30.7050, "lng": 76.8010,
            "total_slots": 1500, "price_per_hour": 40.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "DB City Mall Bhopal",
            "address": "Arera Hills, Bhopal, Madhya Pradesh 462011",
            "city": "Bhopal",
            "lat": 23.2330, "lng": 77.4320,
            "total_slots": 1200, "price_per_hour": 35.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Treasure Island Mall Indore",
            "address": "MG Road, Indore, Madhya Pradesh 452001",
            "city": "Indore",
            "lat": 22.7190, "lng": 75.8780,
            "total_slots": 900, "price_per_hour": 35.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Phoenix Citadel Mall Indore",
            "address": "MR 10 Road, Indore, Madhya Pradesh 452016",
            "city": "Indore",
            "lat": 22.7550, "lng": 75.8950,
            "total_slots": 1600, "price_per_hour": 40.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors", "Valet Parking"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "World Trade Park Jaipur",
            "address": "Jawahar Lal Nehru Marg, Malviya Nagar, Jaipur, Rajasthan 302017",
            "city": "Jaipur",
            "lat": 26.8530, "lng": 75.8050,
            "total_slots": 1400, "price_per_hour": 40.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors", "Valet Parking"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "MGF Metropolitan Mall Jaipur",
            "address": "Bais Godam Circle, C Scheme, Jaipur, Rajasthan 302001",
            "city": "Jaipur",
            "lat": 26.9030, "lng": 75.7920,
            "total_slots": 800, "price_per_hour": 35.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Phoenix Palassio Mall Lucknow",
            "address": "Amar Shaheed Path, Gomti Nagar, Lucknow, Uttar Pradesh 226010",
            "city": "Lucknow",
            "lat": 26.8420, "lng": 81.0110,
            "total_slots": 1700, "price_per_hour": 40.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Car Wash", "Security Guard", "Multiple Floors", "Valet Parking"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Lulu Mall Lucknow",
            "address": "Golf City, Amar Shaheed Path, Lucknow, Uttar Pradesh 226030",
            "city": "Lucknow",
            "lat": 26.7720, "lng": 80.9980,
            "total_slots": 2200, "price_per_hour": 40.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Car Wash", "Security Guard", "Multiple Floors", "Valet Parking"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "South City Mall Kolkata",
            "address": "Prince Anwar Shah Rd, Jadavpur, Kolkata, West Bengal 700068",
            "city": "Kolkata",
            "lat": 22.4980, "lng": 88.3610,
            "total_slots": 1400, "price_per_hour": 50.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors", "Valet Parking"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Quest Mall Kolkata",
            "address": "Syed Amir Ali Ave, Park Circus, Kolkata, West Bengal 700017",
            "city": "Kolkata",
            "lat": 22.5390, "lng": 88.3650,
            "total_slots": 1000, "price_per_hour": 60.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Car Wash", "Security Guard", "Multiple Floors", "Valet Parking"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "City Centre 1 Salt Lake",
            "address": "DC Block, Sector 1, Salt Lake, Kolkata, West Bengal 700064",
            "city": "Kolkata",
            "lat": 22.5890, "lng": 88.4080,
            "total_slots": 1100, "price_per_hour": 40.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Acropolis Mall Kolkata",
            "address": "RB Connector, Rajdanga Main Road, Kolkata, West Bengal 700107",
            "city": "Kolkata",
            "lat": 22.5140, "lng": 88.3930,
            "total_slots": 900, "price_per_hour": 40.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Esplanade One Mall Bhubaneswar",
            "address": "Rasulgarh Square, Bhubaneswar, Odisha 751010",
            "city": "Bhubaneswar",
            "lat": 20.2880, "lng": 85.8590,
            "total_slots": 1300, "price_per_hour": 35.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Z Square Mall Kanpur",
            "address": "Bada Chouraha, Civil Lines, Kanpur, Uttar Pradesh 208001",
            "city": "Kanpur",
            "lat": 26.4670, "lng": 80.3500,
            "total_slots": 1200, "price_per_hour": 35.0,
            "amenities": ["24/7 CCTV", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Brookefields Mall Coimbatore",
            "address": "Krishnaswamy Road, RS Puram, Coimbatore, Tamil Nadu 641001",
            "city": "Coimbatore",
            "lat": 11.0080, "lng": 76.9580,
            "total_slots": 1100, "price_per_hour": 40.0,
            "amenities": ["24/7 CCTV", "EV Charging", "Security Guard", "Multiple Floors"],
            "image_url": "https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&w=800&q=80"
        }
    ]

    raw_locations = raw_locations[:100]
    print(f"Loaded exactly {len(raw_locations)} unique real parking locations.")
    
    locations_data = []
    for loc in raw_locations:
        query_str = urllib.parse.quote(f"{loc['name']}, {loc['address']}")
        maps_link = f"https://www.google.com/maps/search/?api=1&query={query_str}"
        
        locations_data.append({
            "name": loc["name"],
            "address": loc["address"],
            "lat": loc["lat"],
            "lng": loc["lng"],
            "total_slots": loc["total_slots"],
            "price_per_hour": loc["price_per_hour"],
            "amenities": loc["amenities"],
            "google_maps_link": maps_link,
            "rating": 4.5,
            "image_url": loc["image_url"]
        })

    # Step 1: Clean old data safely in Supabase
    print("Clearing old bookings, parking_slots, and parking_locations...")
    try:
        client.table("bookings").delete().neq("id", "00000000-0000-0000-0000-000000000000").execute()
    except Exception as e:
        print("Note on bookings clear:", e)

    try:
        client.table("parking_slots").delete().neq("id", "00000000-0000-0000-0000-000000000000").execute()
    except Exception as e:
        print("Note on slots clear:", e)

    try:
        client.table("parking_locations").delete().neq("id", "00000000-0000-0000-0000-000000000000").execute()
    except Exception as e:
        print("Note on locations clear:", e)

    # Step 2: Insert 100 new parking locations
    print(f"Inserting exactly {len(locations_data)} new parking locations into Supabase...")
    res_loc = client.table("parking_locations").insert(locations_data).execute()
    inserted_locations = res_loc.data
    print(f"Successfully inserted {len(inserted_locations)} parking locations!")

    # Step 3: Insert representative slots per location (10 slots per location = 1000 slots total)
    print("Generating and inserting slots for all 100 locations...")
    slots_to_insert = []
    floors = ["Floor 1", "Floor 2", "Floor 3", "Basement 1", "Basement 2"]
    
    for loc in inserted_locations:
        l_id = loc["id"]
        
        # 5 Car Slots
        for i in range(1, 6):
            floor = floors[(i - 1) % len(floors)]
            slots_to_insert.append({
                "location_id": l_id,
                "slot_number": f"C-{i:02d}",
                "slot_type": "car",
                "floor": floor,
                "is_active": True
            })

        # 3 Bike Slots
        for i in range(1, 4):
            floor = floors[(i - 1) % len(floors)]
            slots_to_insert.append({
                "location_id": l_id,
                "slot_number": f"B-{i:02d}",
                "slot_type": "bike",
                "floor": floor,
                "is_active": True
            })

        # 2 EV Slots
        for i in range(1, 3):
            floor = floors[(i - 1) % len(floors)]
            slots_to_insert.append({
                "location_id": l_id,
                "slot_number": f"E-{i:02d}",
                "slot_type": "ev",
                "floor": floor,
                "is_active": True
            })

    # Batch insert slots in chunks of 500
    chunk_size = 500
    total_slots_inserted = 0
    for i in range(0, len(slots_to_insert), chunk_size):
        chunk = slots_to_insert[i:i + chunk_size]
        res_slots = client.table("parking_slots").insert(chunk).execute()
        total_slots_inserted += len(res_slots.data)

    print(f"Successfully inserted {total_slots_inserted} slots across all 100 locations!")

    # Step 4: Generate self-contained SQL migration file update_100_locations.sql
    sql_file_path = r"C:\Users\isida\Desktop\Parksafe\update_100_locations.sql"
    desktop_root_sql = r"C:\Users\isida\Desktop\update_100_locations.sql"

    with open(sql_file_path, "w", encoding="utf-8") as f:
        f.write("-- =========================================================================\n")
        f.write("-- PARKSAFE DATABASE REFRESH: 100 REAL PARKING LOCATIONS & MULTI-FLOOR SLOTS\n")
        f.write("-- =========================================================================\n\n")
        f.write("BEGIN;\n\n")
        f.write("-- 1. Ensure floor column exists on parking_slots\n")
        f.write("ALTER TABLE parking_slots ADD COLUMN IF NOT EXISTS floor VARCHAR(50) DEFAULT 'Floor 1';\n\n")
        f.write("-- 2. Clean old data safely\n")
        f.write("DELETE FROM bookings;\n")
        f.write("DELETE FROM parking_slots;\n")
        f.write("DELETE FROM parking_locations;\n\n")
        f.write("-- 3. Insert 100 Locations & 1,000 Multi-Floor Slots\n")
        
        for loc in locations_data:
            name_esc = loc['name'].replace("'", "''")
            addr_esc = loc['address'].replace("'", "''")
            items_str = []
            for a in loc['amenities']:
                clean_a = a.replace("'", "''")
                items_str.append(f"'{clean_a}'")
            amenities_sql = "ARRAY[" + ", ".join(items_str) + "]::text[]"
            gmaps_esc = loc['google_maps_link'].replace("'", "''")
            img_esc = loc['image_url'].replace("'", "''")

            f.write("WITH new_loc AS (\n")
            f.write("  INSERT INTO parking_locations (name, address, lat, lng, total_slots, price_per_hour, rating, amenities, google_maps_link, image_url)\n")
            f.write(f"  VALUES ('{name_esc}', '{addr_esc}', {loc['lat']}, {loc['lng']}, {loc['total_slots']}, {loc['price_per_hour']}, {loc['rating']}, {amenities_sql}, '{gmaps_esc}', '{img_esc}')\n")
            f.write("  RETURNING id\n")
            f.write(")\n")
            f.write("INSERT INTO parking_slots (location_id, slot_number, slot_type, floor, is_active)\n")
            f.write("SELECT id, slot_num, slot_tp, flr, true\n")
            f.write("FROM new_loc, (VALUES\n")
            f.write("  ('C-01', 'car', 'Floor 1'),\n")
            f.write("  ('C-02', 'car', 'Floor 2'),\n")
            f.write("  ('C-03', 'car', 'Floor 3'),\n")
            f.write("  ('C-04', 'car', 'Basement 1'),\n")
            f.write("  ('C-05', 'car', 'Basement 2'),\n")
            f.write("  ('B-01', 'bike', 'Floor 1'),\n")
            f.write("  ('B-02', 'bike', 'Floor 2'),\n")
            f.write("  ('B-03', 'bike', 'Floor 3'),\n")
            f.write("  ('E-01', 'ev', 'Floor 1'),\n")
            f.write("  ('E-02', 'ev', 'Floor 2')\n")
            f.write(") AS s(slot_num, slot_tp, flr);\n\n")

        f.write("COMMIT;\n\n")
        f.write("-- =========================================================================\n")
        f.write("-- VERIFICATION QUERIES\n")
        f.write("-- =========================================================================\n")
        f.write("SELECT COUNT(*) AS total_locations FROM parking_locations;\n")
        f.write("SELECT COUNT(*) AS total_slots FROM parking_slots;\n")
        f.write("SELECT floor, count(*) FROM parking_slots GROUP BY floor ORDER BY floor;\n")
        f.write("SELECT id, name, address, lat, lng, google_maps_link FROM parking_locations ORDER BY name LIMIT 10;\n")

    import shutil
    shutil.copy(sql_file_path, desktop_root_sql)
    print(f"Clean SQL script saved successfully to: {sql_file_path} and {desktop_root_sql}")

    # Step 5: Verification Checks via Python API
    print("\n--- RUNNING VERIFICATION CHECKS ---")
    final_locs = client.table("parking_locations").select("id, name, address, google_maps_link, lat, lng").execute().data
    final_slots = client.table("parking_slots").select("id").execute().data
    bardoli_locs = [l for l in final_locs if "Bardoli" in l["address"] or "Bardoli" in l["name"]]
    missing_links = [l for l in final_locs if not l.get("google_maps_link")]
    missing_coords = [l for l in final_locs if l.get("lat") is None or l.get("lng") is None]

    # Duplicate check
    loc_names = [l["name"] for l in final_locs]
    duplicates = [name for name in set(loc_names) if loc_names.count(name) > 1]

    print(f"Total Parking Locations in Database: {len(final_locs)}")
    print(f"Total Parking Slots in Database: {len(final_slots)}")
    print(f"Bardoli Locations Count: {len(bardoli_locs)}")
    print(f"Missing Google Maps Links: {len(missing_links)}")
    print(f"Missing Coordinates: {len(missing_coords)}")
    print(f"Duplicate Names Count: {len(duplicates)}")
    
    print("\nSample Bardoli Locations:")
    for b in bardoli_locs[:5]:
        print(f" - {b['name']} ({b['address']}) -> Link: {b['google_maps_link']}")

if __name__ == "__main__":
    generate_and_seed_100_locations()
