-- =========================================================
-- ParkSafe - 50 Parking Locations & Slots SQL Script
-- Copy & Run this script in Supabase Dashboard > SQL Editor
-- (Adds 50 Diverse Parking Locations across Major Indian Cities)
-- =========================================================

-- =========================================================
-- STEP 1: INSERT 50 PARKING LOCATIONS ACROSS CITIES
-- =========================================================
INSERT INTO public.parking_locations (id, name, address, total_slots, price_per_hour, rating, lat, lng, amenities)
VALUES
  -- 1. PUNE
  ('b0000000-0000-0000-0000-000000000001', 'Phoenix Marketcity Mall', 'Phoenix Marketcity, Viman Nagar, Pune, MH 411014', 60, 60.00, 4.8, 18.5623, 73.9167, ARRAY['CCTV', 'EV Charging', 'Car Wash', 'Accessible', '24/7 Security']),
  ('b0000000-0000-0000-0000-000000000002', 'Central Business Hub', 'Baner Road, Baner, Pune, MH 411045', 40, 50.00, 4.5, 18.5590, 73.7868, ARRAY['CCTV', 'Accessible', '24/7 Security']),
  ('b0000000-0000-0000-0000-000000000003', 'Koregaon Park Plaza', 'Lane 7, Koregaon Park, Pune, MH 411001', 30, 40.00, 4.3, 18.5362, 73.8940, ARRAY['CCTV', 'Bike Parking']),
  ('b0000000-0000-0000-0000-000000000004', 'Pune Airport Smart Park', 'Near International Airport, Yerwada, Pune, MH 411006', 80, 80.00, 4.7, 18.5793, 73.9089, ARRAY['CCTV', 'EV Charging', 'Luggage Storage', 'Accessible', '24/7 Security']),
  ('b0000000-0000-0000-0000-000000000005', 'Hinjewadi IT Park Hub', 'Phase 1, Hinjewadi, Pune, MH 411057', 100, 30.00, 4.2, 18.5912, 73.7389, ARRAY['CCTV', 'EV Charging', 'Accessible']),

  -- 2. MUMBAI
  ('b0000000-0000-0000-0000-000000000006', 'Jio World Drive Plaza', 'Bandra Kurla Complex (BKC), Mumbai, MH 400051', 120, 100.00, 4.9, 19.0657, 72.8687, ARRAY['CCTV', 'EV Charging', 'Valet', 'Car Wash', 'Accessible', '24/7 Security']),
  ('b0000000-0000-0000-0000-000000000007', 'Phoenix Palladium Park', 'Senapati Bapat Marg, Lower Parel, Mumbai, MH 400013', 90, 90.00, 4.8, 18.9950, 72.8258, ARRAY['CCTV', 'EV Charging', 'Valet', 'Accessible']),
  ('b0000000-0000-0000-0000-000000000008', 'Infiniti Mall Plaza', 'New Link Road, Malad West, Mumbai, MH 400064', 70, 60.00, 4.6, 19.1843, 72.8347, ARRAY['CCTV', 'Car Wash', 'Accessible', '24/7 Security']),
  ('b0000000-0000-0000-0000-000000000009', 'Mumbai Airport T2 Parking', 'Chhatrapati Shivaji Terminal 2, Vile Parle, Mumbai, MH 400099', 150, 120.00, 4.7, 19.0896, 72.8656, ARRAY['CCTV', 'EV Charging', 'Luggage Storage', '24/7 Security']),
  ('b0000000-0000-0000-0000-000000000010', 'Hiranandani Business Park', 'Central Avenue, Powai, Mumbai, MH 400076', 50, 50.00, 4.5, 19.1197, 72.9051, ARRAY['CCTV', 'Accessible', '24/7 Security']),
  ('b0000000-0000-0000-0000-000000000011', 'R-City Mall Square', 'LBS Marg, Ghatkopar West, Mumbai, MH 400086', 80, 60.00, 4.6, 19.0997, 72.9161, ARRAY['CCTV', 'EV Charging', 'Car Wash']),
  ('b0000000-0000-0000-0000-000000000012', 'Inorbit Mall Malad', 'Mindspace, Malad West, Mumbai, MH 400064', 65, 50.00, 4.4, 19.1730, 72.8361, ARRAY['CCTV', 'Accessible']),

  -- 3. DELHI & NCR
  ('b0000000-0000-0000-0000-000000000013', 'DLF Cyber City Hub', 'Phase 2, Sector 24, Gurgaon, HR 122002', 110, 80.00, 4.8, 28.4950, 77.0895, ARRAY['CCTV', 'EV Charging', 'Valet', '24/7 Security']),
  ('b0000000-0000-0000-0000-000000000014', 'Select CITYWALK Plaza', 'Saket District Centre, Saket, New Delhi 110017', 95, 70.00, 4.9, 28.5286, 77.2194, ARRAY['CCTV', 'EV Charging', 'Valet', 'Accessible']),
  ('b0000000-0000-0000-0000-000000000015', 'Connaught Place Smart Park', 'Inner Circle, Block C, New Delhi 110001', 85, 60.00, 4.4, 28.6328, 77.2197, ARRAY['CCTV', 'Covered Parking', '24/7 Security']),
  ('b0000000-0000-0000-0000-000000000016', 'Delhi Airport T3 Parking', 'Indira Gandhi International T3, New Delhi 110037', 140, 110.00, 4.7, 28.5562, 77.0999, ARRAY['CCTV', 'EV Charging', 'Luggage Storage', '24/7 Security']),
  ('b0000000-0000-0000-0000-000000000017', 'DLF Mall of India', 'Sector 18, Noida, UP 201301', 100, 60.00, 4.7, 28.5677, 77.3211, ARRAY['CCTV', 'EV Charging', 'Car Wash', 'Accessible']),
  ('b0000000-0000-0000-0000-000000000018', 'Pacific Mall Tagor Garden', 'Najafgarh Road, Subhash Nagar, New Delhi 110027', 75, 50.00, 4.5, 28.6432, 77.1129, ARRAY['CCTV', 'Covered Parking']),

  -- 4. BENGALURU
  ('b0000000-0000-0000-0000-000000000019', 'Forum South City Mall', 'Konanakunte Cross, Kanakapura Rd, Bengaluru, KA 560062', 80, 60.00, 4.7, 12.8887, 77.5645, ARRAY['CCTV', 'EV Charging', 'Accessible', '24/7 Security']),
  ('b0000000-0000-0000-0000-000000000020', 'Phoenix Marketcity Whitefield', 'Whitefield Main Rd, Mahadevapura, Bengaluru, KA 560048', 110, 70.00, 4.8, 12.9959, 77.6964, ARRAY['CCTV', 'EV Charging', 'Valet', 'Car Wash']),
  ('b0000000-0000-0000-0000-000000000021', 'UB City Luxury Plaza', '24 Vittal Mallya Road, Bengaluru, KA 560001', 90, 100.00, 4.9, 12.9716, 77.5958, ARRAY['CCTV', 'EV Charging', 'Valet', '24/7 Security']),
  ('b0000000-0000-0000-0000-000000000022', 'Bengaluru Airport Parking', 'Kempegowda Airport, Devanahalli, Bengaluru, KA 560300', 130, 100.00, 4.6, 13.1986, 77.7066, ARRAY['CCTV', 'EV Charging', 'Luggage Storage', '24/7 Security']),
  ('b0000000-0000-0000-0000-000000000023', 'Manyata Tech Park Hub', 'Outer Ring Road, Thanisandra, Bengaluru, KA 560045', 100, 40.00, 4.4, 13.0458, 77.6208, ARRAY['CCTV', 'EV Charging', 'Accessible']),
  ('b0000000-0000-0000-0000-000000000024', 'Orion Mall Gateway', 'Dr Rajkumar Rd, Malleshwaram, Bengaluru, KA 560055', 85, 60.00, 4.7, 13.0111, 77.5549, ARRAY['CCTV', 'Covered Parking', 'Car Wash']),

  -- 5. HYDERABAD
  ('b0000000-0000-0000-0000-000000000025', 'Inorbit Mall Hitec City', 'Mindspace, Madhapur, Hyderabad, TS 500081', 95, 50.00, 4.7, 17.4375, 78.3813, ARRAY['CCTV', 'EV Charging', 'Accessible', '24/7 Security']),
  ('b0000000-0000-0000-0000-000000000026', 'GVK One Mall Square', 'Road No 1, Banjara Hills, Hyderabad, TS 500034', 70, 60.00, 4.6, 17.4194, 78.4484, ARRAY['CCTV', 'Valet', 'Covered Parking']),
  ('b0000000-0000-0000-0000-000000000027', 'Hyderabad Airport Smart Park', 'Rajiv Gandhi Airport, Shamshabad, Hyderabad, TS 501218', 120, 90.00, 4.7, 17.2403, 78.4294, ARRAY['CCTV', 'EV Charging', 'Luggage Storage']),
  ('b0000000-0000-0000-0000-000000000028', 'Mindspace IT Park Plaza', 'Cyberabad, Madhapur, Hyderabad, TS 500081', 90, 40.00, 4.5, 17.4435, 78.3772, ARRAY['CCTV', 'EV Charging', '24/7 Security']),
  ('b0000000-0000-0000-0000-000000000029', 'Forum Sujana Mall', 'KPHB Phase 6, Kukatpally, Hyderabad, TS 500072', 80, 50.00, 4.5, 17.4842, 78.3889, ARRAY['CCTV', 'Car Wash', 'Accessible']),

  -- 6. AHMEDABAD & SURAT
  ('b0000000-0000-0000-0000-000000000030', 'Alpha One Nexus Mall', 'Near Vastrapur Lake, Vastrapur, Ahmedabad, GJ 380054', 85, 40.00, 4.6, 23.0396, 72.5312, ARRAY['CCTV', 'EV Charging', 'Accessible', '24/7 Security']),
  ('b0000000-0000-0000-0000-000000000031', 'CG Road Shopping Square', 'CG Road, Navrangpura, Ahmedabad, GJ 380009', 50, 30.00, 4.3, 23.0287, 72.5562, ARRAY['CCTV', 'Covered Parking']),
  ('b0000000-0000-0000-0000-000000000032', 'SG Highway Corporate Park', 'Bodakdev, SG Highway, Ahmedabad, GJ 380054', 75, 40.00, 4.5, 23.0489, 72.5117, ARRAY['CCTV', 'EV Charging', '24/7 Security']),
  ('b0000000-0000-0000-0000-000000000033', 'Palladium Ahmedabad', 'Sarkhej - Gandhinagar Hwy, Thaltej, Ahmedabad, GJ 380059', 110, 50.00, 4.8, 23.0543, 72.5132, ARRAY['CCTV', 'EV Charging', 'Valet', 'Car Wash']),
  ('b0000000-0000-0000-0000-000000000034', 'VR Surat Commercial Hub', 'Dumas Road, Magdalla, Surat, GJ 395007', 90, 40.00, 4.7, 21.1458, 72.7725, ARRAY['CCTV', 'EV Charging', 'Car Wash', 'Accessible']),
  ('b0000000-0000-0000-0000-000000000035', 'Union Heights Plaza', 'Maharana Pratap Road, Vesu, Surat, GJ 395007', 60, 30.00, 4.4, 21.1394, 72.7791, ARRAY['CCTV', 'Accessible', '24/7 Security']),
  ('b0000000-0000-0000-0000-000000000036', 'World Trade Centre Surat', 'Ring Road, Near Sahara Gate, Surat, GJ 395002', 70, 40.00, 4.5, 21.1959, 72.8422, ARRAY['CCTV', '24/7 Security']),

  -- 7. CHENNAI
  ('b0000000-0000-0000-0000-000000000037', 'Express Avenue Mall', 'Whites Road, Royapettah, Chennai, TN 600014', 90, 50.00, 4.7, 13.0587, 80.2642, ARRAY['CCTV', 'EV Charging', 'Valet', 'Accessible']),
  ('b0000000-0000-0000-0000-000000000038', 'Phoenix Marketcity Chennai', 'Velachery Road, Velachery, Chennai, TN 600042', 100, 60.00, 4.8, 12.9915, 80.2170, ARRAY['CCTV', 'EV Charging', 'Car Wash', '24/7 Security']),
  ('b0000000-0000-0000-0000-000000000039', 'Chennai Airport Smart Park', 'GST Road, Meenambakkam, Chennai, TN 600027', 110, 80.00, 4.6, 12.9816, 80.1638, ARRAY['CCTV', 'EV Charging', 'Luggage Storage']),
  ('b0000000-0000-0000-0000-000000000040', 'T. Nagar Shopping Plaza', 'Pondy Bazaar, T. Nagar, Chennai, TN 600017', 60, 40.00, 4.3, 13.0405, 80.2337, ARRAY['CCTV', 'Covered Parking']),

  -- 8. KOLKATA
  ('b0000000-0000-0000-0000-000000000041', 'South City Mall Complex', '375 Prince Anwar Shah Rd, Kolkata, WB 700068', 95, 50.00, 4.7, 22.5015, 88.3615, ARRAY['CCTV', 'EV Charging', 'Car Wash', '24/7 Security']),
  ('b0000000-0000-0000-0000-000000000042', 'Quest Mall Plaza', '33 Syed Amir Ali Ave, Park Circus, Kolkata, WB 700017', 80, 60.00, 4.6, 22.5392, 88.3657, ARRAY['CCTV', 'Valet', 'Accessible']),
  ('b0000000-0000-0000-0000-000000000043', 'Salt Lake Sector V Tech Hub', 'Sector V, Bidhannagar, Kolkata, WB 700091', 85, 35.00, 4.4, 22.5726, 88.4331, ARRAY['CCTV', 'EV Charging', '24/7 Security']),

  -- 9. OTHER CITIES (JAIPUR, CHANDIGARH, LUCKNOW, KOCHI, INDORE, BHOPAL, NAGPUR, GOA)
  ('b0000000-0000-0000-0000-000000000044', 'World Trade Park Jaipur', 'JLN Marg, Malviya Nagar, Jaipur, RJ 302017', 85, 40.00, 4.7, 26.8530, 75.8048, ARRAY['CCTV', 'EV Charging', 'Accessible', '24/7 Security']),
  ('b0000000-0000-0000-0000-000000000045', 'Pink City Heritage Square', 'MI Road, Near Panch Batti, Jaipur, RJ 302001', 50, 30.00, 4.3, 26.9154, 75.8143, ARRAY['CCTV', 'Covered Parking']),
  ('b0000000-0000-0000-0000-000000000046', 'Elante Mall Chandigarh', 'Industrial Area Phase I, Chandigarh 160002', 100, 50.00, 4.8, 30.7052, 76.8013, ARRAY['CCTV', 'EV Charging', 'Car Wash', 'Accessible']),
  ('b0000000-0000-0000-0000-000000000047', 'Phoenix Palassio Lucknow', 'Sector 7, Gomti Nagar Extension, Lucknow, UP 226010', 95, 40.00, 4.8, 26.8242, 81.0112, ARRAY['CCTV', 'EV Charging', 'Valet', '24/7 Security']),
  ('b0000000-0000-0000-0000-000000000048', 'Lulu Mall Edappally', 'NH 66, Edappally, Kochi, KL 682024', 110, 50.00, 4.9, 10.0270, 76.3080, ARRAY['CCTV', 'EV Charging', 'Car Wash', 'Accessible', '24/7 Security']),
  ('b0000000-0000-0000-0000-000000000049', 'C21 Mall Indore', 'AB Road, Vijay Nagar, Indore, MP 452010', 75, 40.00, 4.5, 22.7533, 75.8937, ARRAY['CCTV', 'EV Charging', '24/7 Security']),
  ('b0000000-0000-0000-0000-000000000050', 'DB City Mall Bhopal', 'Arera Hills, Maharana Pratap Nagar, Bhopal, MP 462011', 85, 40.00, 4.6, 23.2333, 77.4325, ARRAY['CCTV', 'Accessible', 'Car Wash'])
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  address = EXCLUDED.address,
  total_slots = EXCLUDED.total_slots,
  price_per_hour = EXCLUDED.price_per_hour,
  rating = EXCLUDED.rating,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  amenities = EXCLUDED.amenities;

-- =========================================================
-- STEP 2: AUTO-GENERATE PARKING SLOTS FOR ALL 50 LOCATIONS
-- =========================================================
DO $$
DECLARE
  rec RECORD;
  i INT;
BEGIN
  FOR rec IN SELECT id FROM public.parking_locations LOOP
    -- Generate Car Slots (A1..A15)
    FOR i IN 1..15 LOOP
      INSERT INTO public.parking_slots (location_id, slot_number, slot_type)
      VALUES (rec.id, 'A' || i, 'car')
      ON CONFLICT (location_id, slot_number) DO NOTHING;
    END LOOP;
    
    -- Generate Bike Slots (B1..B10)
    FOR i IN 1..10 LOOP
      INSERT INTO public.parking_slots (location_id, slot_number, slot_type)
      VALUES (rec.id, 'B' || i, 'bike')
      ON CONFLICT (location_id, slot_number) DO NOTHING;
    END LOOP;
    
    -- Generate EV Charging Slots (EV1..EV5)
    FOR i IN 1..5 LOOP
      INSERT INTO public.parking_slots (location_id, slot_number, slot_type)
      VALUES (rec.id, 'EV' || i, 'ev')
      ON CONFLICT (location_id, slot_number) DO NOTHING;
    END LOOP;
  END LOOP;
END $$;

-- =========================================================
-- STEP 3: ADD ACTUAL CHECK-IN, CHECK-OUT & OVERTIME COLUMNS
-- =========================================================
ALTER TABLE public.bookings
  ADD COLUMN IF NOT EXISTS actual_check_in TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS actual_check_out TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS overtime_fee NUMERIC(10, 2) DEFAULT 0.00;

-- =========================================================
-- STEP 4: ADD GOOGLE MAPS LOCATION LINK COLUMN
-- =========================================================
ALTER TABLE public.parking_locations
  ADD COLUMN IF NOT EXISTS google_maps_link TEXT;

-- Update sample Google Maps link for VR Surat Commercial Hub (VR Mall, Surat)
UPDATE public.parking_locations
SET google_maps_link = 'https://maps.google.com/?q=VR+Mall,+Dumas+Road,+Magdalla,+Surat,+Gujarat'
WHERE name ILIKE '%VR Surat%' OR name ILIKE '%VR Mall%';

-- =========================================================
-- STEP 5: ADD REFUND TRACKING COLUMNS TO BOOKINGS
-- =========================================================
ALTER TABLE public.bookings
  ADD COLUMN IF NOT EXISTS refund_status TEXT DEFAULT 'none',
  ADD COLUMN IF NOT EXISTS refund_amount NUMERIC(10, 2) DEFAULT 0.00,
  ADD COLUMN IF NOT EXISTS refund_reason TEXT;

-- =========================================================
-- STEP 6: CUSTOMER FEEDBACK TABLE
-- =========================================================
CREATE TABLE IF NOT EXISTS public.feedback (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL,
  booking_id TEXT,
  location_id TEXT,
  rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comments TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =========================================================
-- STEP 7: IN-APP & PUSH NOTIFICATIONS TABLE
-- =========================================================
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  type TEXT DEFAULT 'general',
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Grant RLS bypass & anon/authenticated permissions
ALTER TABLE public.feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public access feedback" ON public.feedback;
CREATE POLICY "Allow public access feedback" ON public.feedback FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public access notifications" ON public.notifications;
CREATE POLICY "Allow public access notifications" ON public.notifications FOR ALL USING (true) WITH CHECK (true);

-- =========================================================
-- STEP 8: NEW COLUMNS MIGRATION
-- =========================================================

-- 1. Add floor column to parking_slots
ALTER TABLE public.parking_slots 
ADD COLUMN IF NOT EXISTS floor TEXT;

-- 2. Add fcm_token column to profiles
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS fcm_token TEXT;

-- 3. Add notifications_sent column to bookings
ALTER TABLE public.bookings 
ADD COLUMN IF NOT EXISTS notifications_sent JSONB DEFAULT '{}'::jsonb;

-- =========================================================
-- STEP 9: ADMIN-SPECIFIC LOCATION MAPPING & QR VALIDATION
-- =========================================================

-- 1. Create profiles table if not exists and add all required columns
CREATE TABLE IF NOT EXISTS public.profiles (
  id TEXT PRIMARY KEY,
  phone TEXT UNIQUE,
  full_name TEXT,
  role TEXT DEFAULT 'customer',
  password TEXT,
  assigned_location_id TEXT,
  avatar_url TEXT,
  fcm_token TEXT,
  vehicle_number TEXT,
  vehicle_type TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS phone TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS full_name TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'customer';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS password TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS assigned_location_id TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS avatar_url TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS fcm_token TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS vehicle_number TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS vehicle_type TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();

-- 2. Insert Surat RR Mall into parking_locations if not exists
INSERT INTO public.parking_locations (id, name, address, total_slots, price_per_hour, rating, lat, lng, amenities)
VALUES
  ('b0000000-0000-0000-0000-000000000051', 'Surat RR Mall', 'RR Mall Road, Piplod, Surat, GJ 395007', 80, 40.00, 4.6, 21.1520, 72.7810, ARRAY['CCTV', 'EV Charging', 'Accessible', '24/7 Security'])
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  address = EXCLUDED.address,
  total_slots = EXCLUDED.total_slots,
  price_per_hour = EXCLUDED.price_per_hour;

-- 3. Auto-generate slots for Surat RR Mall
DO $$
DECLARE
  i INT;
BEGIN
  FOR i IN 1..15 LOOP
    INSERT INTO public.parking_slots (location_id, slot_number, slot_type)
    VALUES ('b0000000-0000-0000-0000-000000000051', 'A' || i, 'car')
    ON CONFLICT (location_id, slot_number) DO NOTHING;
  END LOOP;
  FOR i IN 1..10 LOOP
    INSERT INTO public.parking_slots (location_id, slot_number, slot_type)
    VALUES ('b0000000-0000-0000-0000-000000000051', 'B' || i, 'bike')
    ON CONFLICT (location_id, slot_number) DO NOTHING;
  END LOOP;
END $$;

-- 4. Create Dedicated admin_accounts Table & Seed Location Admins
CREATE TABLE IF NOT EXISTS public.admin_accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  password TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'admin',
  assigned_location_id TEXT,
  status TEXT DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.admin_accounts ADD COLUMN IF NOT EXISTS phone TEXT UNIQUE;
ALTER TABLE public.admin_accounts ADD COLUMN IF NOT EXISTS full_name TEXT;
ALTER TABLE public.admin_accounts ADD COLUMN IF NOT EXISTS password TEXT;
ALTER TABLE public.admin_accounts ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'admin';
ALTER TABLE public.admin_accounts ADD COLUMN IF NOT EXISTS assigned_location_id TEXT;
ALTER TABLE public.admin_accounts ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'active';
ALTER TABLE public.admin_accounts ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();

ALTER TABLE public.admin_accounts ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public access to admin_accounts" ON public.admin_accounts;
CREATE POLICY "Allow public access to admin_accounts" ON public.admin_accounts FOR ALL USING (true) WITH CHECK (true);

-- Main Admin / Super Admin (Access to ALL Locations)
INSERT INTO public.admin_accounts (id, phone, full_name, role, password, assigned_location_id)
VALUES ('a0000000-0000-0000-0000-000000000001', '9999988888', 'Main Admin (All Locations)', 'super_admin', '123456', NULL)
ON CONFLICT (phone) DO UPDATE SET
  role = 'super_admin',
  full_name = EXCLUDED.full_name,
  password = EXCLUDED.password,
  assigned_location_id = NULL;

-- Surat VR Mall Admin
INSERT INTO public.admin_accounts (id, phone, full_name, role, password, assigned_location_id)
VALUES ('a0000000-0000-0000-0000-000000000002', '9999911111', 'Surat VR Mall Admin', 'admin', '123456', 'b0000000-0000-0000-0000-000000000034')
ON CONFLICT (phone) DO UPDATE SET
  role = 'admin',
  full_name = EXCLUDED.full_name,
  password = EXCLUDED.password,
  assigned_location_id = 'b0000000-0000-0000-0000-000000000034';

-- Mumbai Airport Admin
INSERT INTO public.admin_accounts (id, phone, full_name, role, password, assigned_location_id)
VALUES ('a0000000-0000-0000-0000-000000000003', '9999922222', 'Mumbai Airport Admin', 'admin', '123456', 'b0000000-0000-0000-0000-000000000009')
ON CONFLICT (phone) DO UPDATE SET
  role = 'admin',
  full_name = EXCLUDED.full_name,
  password = EXCLUDED.password,
  assigned_location_id = 'b0000000-0000-0000-0000-000000000009';

-- Surat RR Mall Admin
INSERT INTO public.admin_accounts (id, phone, full_name, role, password, assigned_location_id)
VALUES ('a0000000-0000-0000-0000-000000000004', '9999933333', 'Surat RR Mall Admin', 'admin', '123456', 'b0000000-0000-0000-0000-000000000051')
ON CONFLICT (phone) DO UPDATE SET
  role = 'admin',
  full_name = EXCLUDED.full_name,
  password = EXCLUDED.password,
  assigned_location_id = 'b0000000-0000-0000-0000-000000000051';

-- Reload schema cache
NOTIFY pgrst, 'reload schema';