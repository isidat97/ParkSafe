import os
import docx
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import nsdecls, qn

def create_parksafe_documentation():
    doc = Document()

    # Page Margins: 1 inch on all sides
    sections = doc.sections
    for section in sections:
        section.top_margin = Inches(1.0)
        section.bottom_margin = Inches(1.0)
        section.left_margin = Inches(1.0)
        section.right_margin = Inches(1.0)

    # Color Palette
    COLOR_PRIMARY = RGBColor(15, 81, 50)     # #0F5132 Dark Green
    COLOR_TEXT = RGBColor(20, 24, 27)        # #14181B Dark Charcoal
    COLOR_MUTED = RGBColor(91, 102, 96)      # #5B6660 Gray
    COLOR_BG_LIGHT = "F8FAF9"                # Off-white card background
    COLOR_HEADER_BG = "0F5132"               # Table header green fill

    # Helper Functions
    def set_cell_background(cell, color_hex):
        shading = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{color_hex}"/>')
        cell._tc.get_or_add_tcPr().append(shading)

    def set_cell_margins(cell, top=100, bottom=100, left=150, right=150):
        tcPr = cell._tc.get_or_add_tcPr()
        tcMar = parse_xml(f'<w:tcMar {nsdecls("w")}><w:top w:w="{top}" w:type="dxa"/><w:bottom w:w="{bottom}" w:type="dxa"/><w:left w:w="{left}" w:type="dxa"/><w:right w:w="{right}" w:type="dxa"/></w:tcMar>')
        tcPr.append(tcMar)

    def add_title(text):
        p = doc.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.paragraph_format.space_before = Pt(36)
        p.paragraph_format.space_after = Pt(12)
        run = p.add_run(text)
        run.font.name = 'Arial'
        run.font.size = Pt(28)
        run.font.bold = True
        run.font.color.rgb = COLOR_PRIMARY
        return p

    def add_subtitle(text):
        p = doc.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.paragraph_format.space_after = Pt(24)
        run = p.add_run(text)
        run.font.name = 'Arial'
        run.font.size = Pt(16)
        run.font.bold = True
        run.font.color.rgb = COLOR_TEXT
        return p

    def add_heading_1(text):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(18)
        p.paragraph_format.space_after = Pt(8)
        p.paragraph_format.keep_with_next = True
        run = p.add_run(text)
        run.font.name = 'Arial'
        run.font.size = Pt(18)
        run.font.bold = True
        run.font.color.rgb = COLOR_PRIMARY
        return p

    def add_heading_2(text):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(12)
        p.paragraph_format.space_after = Pt(6)
        p.paragraph_format.keep_with_next = True
        run = p.add_run(text)
        run.font.name = 'Arial'
        run.font.size = Pt(14)
        run.font.bold = True
        run.font.color.rgb = COLOR_PRIMARY
        return p

    def add_heading_3(text):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(8)
        p.paragraph_format.space_after = Pt(4)
        p.paragraph_format.keep_with_next = True
        run = p.add_run(text)
        run.font.name = 'Arial'
        run.font.size = Pt(12)
        run.font.bold = True
        run.font.color.rgb = COLOR_TEXT
        return p

    def add_body(text, bold_prefix="", italic=False):
        p = doc.add_paragraph()
        p.paragraph_format.space_after = Pt(6)
        p.paragraph_format.line_spacing = 1.15
        if bold_prefix:
            run_b = p.add_run(bold_prefix)
            run_b.font.name = 'Arial'
            run_b.font.size = Pt(11)
            run_b.font.bold = True
            run_b.font.color.rgb = COLOR_TEXT
        run = p.add_run(text)
        run.font.name = 'Arial'
        run.font.size = Pt(11)
        run.font.italic = italic
        run.font.color.rgb = COLOR_TEXT
        return p

    def add_bullet(text, bold_prefix=""):
        p = doc.add_paragraph(style='List Bullet')
        p.paragraph_format.space_after = Pt(4)
        p.paragraph_format.line_spacing = 1.15
        if bold_prefix:
            run_b = p.add_run(bold_prefix)
            run_b.font.name = 'Arial'
            run_b.font.size = Pt(11)
            run_b.font.bold = True
            run_b.font.color.rgb = COLOR_TEXT
        run = p.add_run(text)
        run.font.name = 'Arial'
        run.font.size = Pt(11)
        run.font.color.rgb = COLOR_TEXT
        return p

    def add_code_block(code_text):
        table = doc.add_table(rows=1, cols=1)
        table.alignment = WD_TABLE_ALIGNMENT.CENTER
        cell = table.cell(0, 0)
        set_cell_background(cell, "F0F4F2")
        set_cell_margins(cell, top=120, bottom=120, left=180, right=180)
        
        p = cell.paragraphs[0]
        p.paragraph_format.space_after = Pt(0)
        run = p.add_run(code_text)
        run.font.name = 'Consolas'
        run.font.size = Pt(9.5)
        run.font.color.rgb = COLOR_TEXT
        
        doc.add_paragraph().paragraph_format.space_after = Pt(6)

    def create_custom_table(headers, rows_data, col_widths=None):
        table = doc.add_table(rows=len(rows_data) + 1, cols=len(headers))
        table.alignment = WD_TABLE_ALIGNMENT.CENTER
        
        # Header Row
        hdr_cells = table.rows[0].cells
        for i, header_text in enumerate(headers):
            hdr_cells[i].text = header_text
            set_cell_background(hdr_cells[i], COLOR_HEADER_BG)
            set_cell_margins(hdr_cells[i], top=120, bottom=120, left=150, right=150)
            p = hdr_cells[i].paragraphs[0]
            p.alignment = WD_ALIGN_PARAGRAPH.LEFT
            for run in p.runs:
                run.font.name = 'Arial'
                run.font.size = Pt(10)
                run.font.bold = True
                run.font.color.rgb = RGBColor(255, 255, 255)

        # Data Rows
        for r_idx, row_values in enumerate(rows_data):
            row_cells = table.rows[r_idx + 1].cells
            bg_color = "FFFFFF" if r_idx % 2 == 0 else "F8FAF9"
            for c_idx, val in enumerate(row_values):
                row_cells[c_idx].text = str(val)
                set_cell_background(row_cells[c_idx], bg_color)
                set_cell_margins(row_cells[c_idx], top=100, bottom=100, left=150, right=150)
                p = row_cells[c_idx].paragraphs[0]
                p.alignment = WD_ALIGN_PARAGRAPH.LEFT
                for run in p.runs:
                    run.font.name = 'Arial'
                    run.font.size = Pt(9.5)
                    run.font.color.rgb = COLOR_TEXT
        
        # Column Widths
        if col_widths:
            for row in table.rows:
                for i, w in enumerate(col_widths):
                    row.cells[i].width = Inches(w)
                    
        doc.add_paragraph().paragraph_format.space_after = Pt(6)
        return table

    # =========================================================================
    # 1. TITLE PAGE
    # =========================================================================
    add_title("ParkSafe")
    add_subtitle("Smart Vehicle Parking & Online Slot Booking Application\nComplete Technical & Functional Project Documentation")

    p_meta = doc.add_paragraph()
    p_meta.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_meta.paragraph_format.space_before = Pt(40)
    p_meta.paragraph_format.space_after = Pt(12)
    run_meta = p_meta.add_run("B.Voc (Bachelor of Vocation) Final-Year Project Submission\nDepartment of Software Development / Computer Applications")
    run_meta.font.name = 'Arial'
    run_meta.font.size = Pt(13)
    run_meta.font.bold = True
    run_meta.font.color.rgb = COLOR_PRIMARY

    p_team = doc.add_paragraph()
    p_team.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_team.paragraph_format.space_after = Pt(40)
    run_team = p_team.add_run("PROJECT TEAM:\n• Sayyed Mashhuda\n• Sidat Ibrahim\n• Patel Dhruvil\n\nDate: August 2026")
    run_team.font.name = 'Arial'
    run_team.font.size = Pt(12)
    run_team.font.color.rgb = COLOR_TEXT

    doc.add_page_break()

    # =========================================================================
    # 2. TABLE OF CONTENTS OUTLINE
    # =========================================================================
    add_heading_1("Table of Contents Outline")
    toc_items = [
        "1. Title Page", "2. Table of Contents Outline", "3. Project Overview", "4. Problem Statement",
        "5. Project Objectives", "6. Proposed Solution", "7. User Roles", "8. Technology Stack",
        "9. Complete Project Folder Structure", "10. Application Startup Sequence", "11. Authentication Engine",
        "12. Customer Application Suite", "13. Admin Panel Operational Suite", "14. Navigation and Routing Map",
        "15. State Management Architecture", "16. Repository and Service Layer", "17. Database Structure & Schema",
        "18. Database Relationships", "19. Supabase Integration & Row Level Security (RLS)", "20. Parking Location Management",
        "21. Google Maps Navigation Integration", "22. Geolocation & Distance Calculation", "23. Multi-Floor Parking Architecture",
        "24. Parking Slot Management", "25. Booking System", "26. Booking Availability Engine",
        "27. Booking Validation & Collision Prevention", "28. Payment Gateway Workflow", "29. QR Code Generation",
        "30. QR Code Scanning", "31. QR Pass Verification", "32. Gate Check-In Logic",
        "33. Gate Check-Out Logic", "34. Automated Overtime Engine", "35. Push & In-App Notifications",
        "36. Background Scheduled Notifications", "37. Customer Profile Management", "38. Customer Refund System",
        "39. AI Recommendation Microservice", "40. Fraud & Overlap Detection", "41. Global Error Handling",
        "42. Security Architecture", "43. FastAPI REST API Documentation", "44. Supabase SQL Migration Scripts",
        "45. Package Dependencies (pubspec.yaml)", "46. Complete Customer Journey Flow", "47. Complete Admin Operational Flow",
        "48. End-to-End Data Flow Architecture", "49. Automated & Manual Test Cases", "50. Known Limitations",
        "51. Future Scope & Roadmap", "52. Technical Glossary", "53. Viva Quick Reference (Q&A)", "54. Conclusion"
    ]
    for item in toc_items:
        add_bullet(item)

    doc.add_page_break()

    # =========================================================================
    # 3. PROJECT OVERVIEW
    # =========================================================================
    add_heading_1("3. Project Overview")
    add_body("ParkSafe is a cross-platform mobile and web application designed to digitize and streamline urban vehicle parking management. Built with Flutter for the client app and Supabase (PostgreSQL) for backend cloud infrastructure, ParkSafe provides guaranteed pre-booking of parking slots across multi-floor commercial facilities.")
    add_bullet("Pre-Booking System: Allows drivers to reserve guaranteed parking slots for Cars, Bikes, or EV Charging stations ahead of departure.")
    add_bullet("AI Proximity & Availability Scoring: Recommends nearby parking locations using Haversine distance and real-time slot availability ratio.")
    add_bullet("Contactless QR Gatekeeping: Encrypted QR code ticket pass generated upon booking confirmation, scanned by admin camera at entrance and exit gates.")
    add_bullet("Automated Overtime & Refund Suite: Real-time calculation of late checkout fees and admin review workflow for customer refund requests.")

    # =========================================================================
    # 4. PROBLEM STATEMENT
    # =========================================================================
    add_heading_1("4. Problem Statement")
    add_body("Urban parking in modern cities suffers from severe inefficiencies that negatively impact citizens, businesses, and municipal traffic flow:")
    add_bullet("Time and Fuel Wastage: Drivers spend an average of 15 to 20 minutes searching for open parking spaces, accounting for up to 30% of urban traffic congestion.")
    add_bullet("Lack of Information: Motorists drive to parking facilities blindly, without knowing if slots are full or whether specialized slots (EV charging, bike parking) are available.")
    add_bullet("Manual Operations Friction: Paper ticket loss causes gate delays, administrative disputes, and unrecorded overstaying.")
    add_bullet("Security & Fraud Risks: Lack of digital verification makes it difficult to audit gate operations or track unauthorized overstays.")

    # =========================================================================
    # 5. PROJECT OBJECTIVES
    # =========================================================================
    add_heading_1("5. Project Objectives")
    add_bullet("Zero Double Booking: Enforce database mathematical overlap validation formula to prevent slot collisions.")
    add_bullet("Multi-Floor Visibility: Provide single-page visual grid displaying slots categorized across Floor 1, Floor 2, Floor 3, Basement 1, and Basement 2.")
    add_bullet("Cross-Platform Accessibility: Single codebase in Flutter serving Web, Android, and iOS clients.")
    add_bullet("Real-Time Synchronization: Instant cloud state updates between Customer App and Admin Panel using Supabase Realtime channels.")

    # =========================================================================
    # 6. PROPOSED SOLUTION
    # =========================================================================
    add_heading_1("6. Proposed Solution")
    add_body("ParkSafe delivers a unified smart mobility platform consisting of:")
    add_bullet("Customer Mobile/Web App: Real-time search, Google Maps direction link, floor slot picker, payment confirmation, QR ticket pass, notification history, profile management, and refund request.")
    add_bullet("Admin Management Panel: Add/edit parking places, multi-floor slot breakdown, camera QR scanner gatekeeper, today's bookings dashboard, revenue analytics, and refund processing.")
    add_bullet("Python FastAPI AI Microservice: Geospatial distance calculation and background notification scheduler for automated check-in/out push alerts.")

    # =========================================================================
    # 7. USER ROLES
    # =========================================================================
    add_heading_1("7. User Roles & Access Comparison")
    create_custom_table(
        ["Feature / Capability", "Customer Role", "Admin Role"],
        [
            ["Authentication & Login", "Email / Mobile Login", "Admin Credentials"],
            ["Parking Location Search", "View & Search Locations", "Add / Edit / Remove Locations"],
            ["Multi-Floor Slot View", "View Available / Booked Slots", "Configure Floors & Slot Capacities"],
            ["Slot Booking & Payment", "Reserve & Pay for Slots", "View All Customer Bookings"],
            ["QR Ticket Gatekeeping", "View Digital QR Ticket Pass", "Scan QR Code for Check-In / Out"],
            ["Overtime & Late Fees", "View Overtime Fee on Bill", "Automated Checkout Overtime Check"],
            ["Refund Requests", "Submit Refund Request", "Approve / Reject Refund Requests"],
            ["Customer Management", "Edit Personal Profile", "View Registered Customers Directory"]
        ],
        [2.5, 2.0, 2.0]
    )

    # =========================================================================
    # 8. TECHNOLOGY STACK
    # =========================================================================
    add_heading_1("8. Technology Stack")
    create_custom_table(
        ["Technology", "Purpose", "Implementation Where Used"],
        [
            ["Flutter (v3.x)", "UI Framework", "Cross-Platform Client (Android, Web, iOS)"],
            ["Dart", "Programming Language", "Frontend Logic & Provider State Management"],
            ["Supabase", "Backend Cloud Services", "PostgreSQL Database, Auth & Realtime"],
            ["PostgreSQL", "Database Engine", "Relational Tables, RLS Policies & Indexes"],
            ["Firebase FCM", "Push Messaging", "Background Push Notifications & Alerts"],
            ["Provider", "State Management", "Reactive UI State Synchronization"],
            ["GoRouter", "Navigation (Optional)", "Package available in pubspec.yaml"],
            ["Geolocator", "GPS Service", "Customer Location Distance Calculation"],
            ["Google Maps API", "Navigation Links", "Direct turn-by-turn navigation URLs"],
            ["QR Flutter", "QR Code Generation", "Encrypted QR Pass Ticket Rendering"],
            ["Mobile Scanner", "Camera Scanning", "Admin Gate QR Verification Scanner"],
            ["FastAPI (Python)", "AI Microservice", "Haversine Distance & Proximity Scoring"],
            ["APScheduler", "Background Worker", "15-min Reminder & Overtime Worker"],
            ["Figma", "UI Design", "Branding, Wireframes & Visual Prototypes"],
            ["GitHub", "Version Control", "Source Repository & Commit History"]
        ],
        [1.8, 1.8, 2.9]
    )

    # =========================================================================
    # 9. COMPLETE PROJECT FOLDER STRUCTURE
    # =========================================================================
    add_heading_1("9. Complete Project Folder Structure")
    add_code_block(
"""lib/
├── main.dart                          # Application Entry Point & Route Registry
├── firebase_options.dart              # Firebase Configuration Options
├── core/
│   ├── constants/app_constants.dart   # Supabase & API Environment Constants
│   ├── services/
│   │   ├── notification_service.dart # FCM & Local Notification Handler
│   │   └── prediction_service.dart   # FastAPI Recommendation Client
│   ├── theme/app_theme.dart           # Primary Green Theme Tokens & Typography
│   └── utils/
├── data/
│   ├── models/                        # UserProfile, ParkingLocation, ParkingSlot, Booking, etc.
│   ├── repositories/                  # AuthRepository, ParkingRepository, BookingRepository, etc.
│   └── supabase/supabase_client.dart  # Supabase Instance Wrapper
├── providers/                         # AuthProvider, ParkingProvider, BookingProvider, AdminProvider, etc.
├── screens/
│   ├── admin/                         # AdminShell, Dashboard, AddLocation, Slots, Scanner, Refunds, etc.
│   ├── auth/                          # LoginScreen, RegisterScreen
│   ├── booking/                       # BookingConfirmScreen, PaymentScreen, BookingSuccessScreen
│   ├── home/                          # HomeScreen, Parking Search & Hero Cards
│   ├── location_detail/               # LocationDetailScreen & Facilities Chips
│   ├── location_selection/            # City & Location Selection List
│   ├── my_bookings/                   # MyBookingsScreen, BookingDetailScreen, CustomerRefundsScreen
│   ├── notifications/                 # NotificationsScreen & History
│   ├── onboarding/                    # OnboardingScreen Slides
│   ├── profile/                       # ProfileScreen & EditProfileScreen
│   ├── recommendation/               # NearestAvailableSlotsScreen (AI List)
│   ├── scanner/                       # ScannerScreen Component
│   ├── slot_selection/                # SlotSelectionScreen (Multi-Floor Grid)
│   └── splash/                        # SplashScreen Session Validation
└── widgets/                           # Reusable UI Cards, Buttons & Number Plate Fields

backend/
├── main.py                            # FastAPI Server & /recommend Endpoint
├── scheduler.py                       # APScheduler Background Notification Worker
├── seed_100_locations.py              # Database Seeder & SQL File Generator
└── update_100_locations.sql           # Self-Contained Migration Script (100 Locs + 1000 Slots)"""
    )

    # =========================================================================
    # 10. APPLICATION STARTUP SEQUENCE
    # =========================================================================
    add_heading_1("10. Application Startup Sequence")
    add_body("When ParkSafe launches, the execution follows a strict initialization sequence defined in lib/main.dart:")
    add_bullet("1. WidgetsFlutterBinding.ensureInitialized(): Prepares Flutter framework bindings.")
    add_bullet("2. Supabase.initialize(): Connects to cloud Supabase PostgreSQL backend using AppConstants.supabaseUrl and anon key.")
    add_bullet("3. NotificationService().init(): Registers FCM push token and initializes local notification channels.")
    add_bullet("4. SystemChrome Configuration: Locks device orientation to portrait mode and applies transparent system status bars.")
    add_bullet("5. MultiProvider Creation: Instantiates AuthProvider, ParkingProvider, BookingProvider, AdminProvider, NotificationProvider, and RecommendationProvider.")
    add_bullet("6. SplashScreen Session Check: Validates active Supabase session. If logged in, redirects to /home (or /admin if role is admin). If logged out, redirects to /login.")

    # =========================================================================
    # 11. AUTHENTICATION ENGINE
    # =========================================================================
    add_heading_1("11. Authentication Engine")
    add_body("Authentication is handled by Supabase Auth with custom role management stored in the public.profiles database table:")
    add_bullet("Customer Registration: User inputs full name, email, mobile number, and password. AuthRepository calls Supabase signUp(), creating an auth record and inserting a row in public.profiles with role = 'customer'.")
    add_bullet("Login Verification: AuthRepository calls signInWithPassword(). Upon success, user profile is fetched to verify role ('customer' vs 'admin').")
    add_bullet("Session Persistence: Supabase SDK automatically stores JWT session tokens in secure local storage, keeping users logged in across app restarts.")

    # =========================================================================
    # 12. CUSTOMER APPLICATION SUITE
    # =========================================================================
    add_heading_1("12. Customer Application Suite")
    create_custom_table(
        ["Screen Name", "File Path", "Primary Purpose & User Actions"],
        [
            ["Splash Screen", "lib/screens/splash/splash_screen.dart", "Validates active session & redirects"],
            ["Onboarding Screen", "lib/screens/onboarding/onboarding_screen.dart", "Displays app introduction & benefits"],
            ["Login Screen", "lib/screens/auth/login_screen.dart", "Authenticates customer or admin credentials"],
            ["Register Screen", "lib/screens/auth/register_screen.dart", "Creates new customer account in Supabase"],
            ["Home Screen", "lib/screens/home/home_screen.dart", "Displays search, AI banner & popular spots"],
            ["Location Selection", "lib/screens/location_selection/location_selection_screen.dart", "Lists 100 real parking places with search filter"],
            ["Location Details", "lib/screens/location_detail/location_detail_screen.dart", "Displays pricing, amenities & Google Maps button"],
            ["Slot Selection", "lib/screens/slot_selection/slot_selection_screen.dart", "Single-page multi-floor slot grid (Car, Bike, EV)"],
            ["Booking Confirm", "lib/screens/booking/booking_confirm_screen.dart", "Inputs date, time range & vehicle number plate"],
            ["Payment Screen", "lib/screens/booking/payment_screen.dart", "Simulates digital payment gateway & invoice"],
            ["Booking Success", "lib/screens/booking/booking_success_screen.dart", "Displays success confirmation & QR ticket"],
            ["My Bookings", "lib/screens/my_bookings/my_bookings_screen.dart", "Tabs for Active Bookings and Past Bookings"],
            ["Booking Detail / QR", "lib/screens/my_bookings/booking_detail_screen.dart", "Displays full ticket details & scannable QR code"],
            ["Notifications", "lib/screens/notifications/notifications_screen.dart", "Lists 15-min check-in/out & overtime alerts"],
            ["Customer Refunds", "lib/screens/my_bookings/customer_refunds_screen.dart", "Allows customer to request booking cancellation"],
            ["Edit Profile", "lib/screens/profile/edit_profile_screen.dart", "Updates customer full name & mobile number"],
            ["AI Recommended Slots", "lib/screens/recommendation/nearest_available_slots_screen.dart", "Lists nearest parking sorted by AI score"]
        ],
        [1.5, 2.5, 2.5]
    )

    # =========================================================================
    # 13. ADMIN PANEL OPERATIONAL SUITE
    # =========================================================================
    add_heading_1("13. Admin Panel Operational Suite")
    create_custom_table(
        ["Admin Screen Name", "File Path", "Operational Functions"],
        [
            ["Admin Shell", "lib/screens/admin/admin_shell.dart", "Bottom navigation container for admin panel"],
            ["Admin Dashboard", "lib/screens/admin/admin_dashboard_screen.dart", "Displays live occupancy, total revenue & stats"],
            ["Add/Edit Location", "lib/screens/admin/admin_add_location_screen.dart", "Form to add parking location & Google Maps link"],
            ["Slot Configuration", "lib/screens/admin/admin_slots_screen.dart", "Sets total floors & Car/Bike/EV limits per floor"],
            ["QR Gate Scanner", "lib/screens/admin/admin_scan_screen.dart", "Camera QR scanner for gate check-in & check-out"],
            ["Today's Bookings", "lib/screens/admin/admin_todays_bookings_screen.dart", "Lists active check-in/out bookings for today"],
            ["All Bookings", "lib/screens/admin/admin_all_bookings_screen.dart", "Complete searchable booking transaction log"],
            ["Revenue Analytics", "lib/screens/admin/admin_revenue_screen.dart", "Financial revenue breakdowns and occupancy stats"],
            ["Refund Management", "lib/screens/admin/admin_refunds_screen.dart", "Approve or reject customer refund requests"],
            ["Customers Directory", "lib/screens/admin/admin_customers_screen.dart", "Lists registered customer profiles & contact info"]
        ],
        [1.5, 2.5, 2.5]
    )

    # =========================================================================
    # 14. DATABASE STRUCTURE & SCHEMA
    # =========================================================================
    add_heading_1("14. Database Structure & Schema")
    add_body("The Supabase PostgreSQL database consists of 7 interconnected relational tables:")

    add_heading_2("Table 1: profiles")
    create_custom_table(
        ["Column Name", "Data Type", "Constraints", "Description"],
        [
            ["id", "UUID", "PRIMARY KEY, REFERENCES auth.users", "User unique identifier"],
            ["full_name", "VARCHAR(255)", "NOT NULL", "Customer or admin full name"],
            ["mobile_number", "VARCHAR(20)", "NULLABLE", "Contact phone number"],
            ["fcm_token", "TEXT", "NULLABLE", "Firebase Cloud Messaging token"],
            ["role", "VARCHAR(20)", "DEFAULT 'customer'", "User role ('customer' or 'admin')"],
            ["created_at", "TIMESTAMPTZ", "DEFAULT NOW()", "Account creation timestamp"]
        ],
        [1.5, 1.2, 1.8, 2.0]
    )

    add_heading_2("Table 2: parking_locations")
    create_custom_table(
        ["Column Name", "Data Type", "Constraints", "Description"],
        [
            ["id", "UUID", "PRIMARY KEY", "Parking place unique ID"],
            ["name", "VARCHAR(255)", "NOT NULL", "Commercial parking name"],
            ["address", "TEXT", "NOT NULL", "Full address string"],
            ["lat", "FLOAT8", "NOT NULL", "Latitude GPS coordinate"],
            ["lng", "FLOAT8", "NOT NULL", "Longitude GPS coordinate"],
            ["total_slots", "INT", "NOT NULL", "Total slot capacity"],
            ["price_per_hour", "NUMERIC(10,2)", "NOT NULL", "Hourly parking rate (₹)"],
            ["rating", "FLOAT8", "DEFAULT 4.5", "Customer rating score"],
            ["amenities", "TEXT[]", "DEFAULT ARRAY[]", "Facilities list (CCTV, EV, etc.)"],
            ["google_maps_link", "TEXT", "NULLABLE", "Direct Google Maps URL"],
            ["image_url", "TEXT", "NULLABLE", "Facility photo URL"]
        ],
        [1.5, 1.2, 1.8, 2.0]
    )

    add_heading_2("Table 3: parking_slots")
    create_custom_table(
        ["Column Name", "Data Type", "Constraints", "Description"],
        [
            ["id", "UUID", "PRIMARY KEY", "Parking slot unique ID"],
            ["location_id", "UUID", "REFERENCES parking_locations(id)", "Parent parking facility ID"],
            ["slot_number", "VARCHAR(20)", "NOT NULL", "Slot code (e.g. 'C-01', 'B-02')"],
            ["slot_type", "VARCHAR(20)", "NOT NULL", "Vehicle category ('car', 'bike', 'ev')"],
            ["floor", "VARCHAR(50)", "NOT NULL", "Floor level ('Floor 1', 'Basement 1')"],
            ["is_active", "BOOLEAN", "DEFAULT TRUE", "Slot operational status"]
        ],
        [1.5, 1.2, 1.8, 2.0]
    )

    add_heading_2("Table 4: bookings")
    create_custom_table(
        ["Column Name", "Data Type", "Constraints", "Description"],
        [
            ["id", "UUID", "PRIMARY KEY", "Booking unique ID"],
            ["user_id", "UUID", "REFERENCES profiles(id)", "Customer account ID"],
            ["slot_id", "UUID", "REFERENCES parking_slots(id)", "Reserved parking slot ID"],
            ["booking_date", "DATE", "NOT NULL", "Reservation date (YYYY-MM-DD)"],
            ["start_time", "VARCHAR(10)", "NOT NULL", "Scheduled start time ('14:00')"],
            ["end_time", "VARCHAR(10)", "NOT NULL", "Scheduled end time ('16:00')"],
            ["vehicle_number", "VARCHAR(20)", "NOT NULL", "Vehicle license plate number"],
            ["vehicle_type", "VARCHAR(20)", "NOT NULL", "Vehicle category ('car', 'bike', 'ev')"],
            ["total_amount", "NUMERIC(10,2)", "NOT NULL", "Calculated reservation fee (₹)"],
            ["overtime_fee", "NUMERIC(10,2)", "DEFAULT 0.00", "Late checkout penalty fee (₹)"],
            ["status", "VARCHAR(20)", "DEFAULT 'pending'", "Status ('pending','checked_in','completed')"],
            ["qr_code_data", "TEXT", "NOT NULL", "Encrypted QR pass payload string"]
        ],
        [1.5, 1.2, 1.8, 2.0]
    )

    # =========================================================================
    # 15. MULTI-FLOOR PARKING ARCHITECTURE
    # =========================================================================
    add_heading_1("15. Multi-Floor Parking Architecture")
    add_body("ParkSafe implements multi-floor parking support by categorizing slots using the floor column in public.parking_slots:")
    add_bullet("Floor Levels: Supports Floor 1, Floor 2, Floor 3, Basement 1, and Basement 2.")
    add_bullet("Per-Floor Capacity Allocation: Admin configures custom slot limits per floor for Cars, Bikes, and EV Charging stations.")
    add_bullet("Single-Page Visual Grid: Customer app presents all floor levels on one scrollable screen with clear floor section headers.")
    add_bullet("Ticket & Pass Synchronization: Digital tickets and My Bookings display exact floor location (e.g. 'Floor 2 → Slot C-04').")

    # =========================================================================
    # 16. BOOKING VALIDATION & OVERLAP PREVENTION
    # =========================================================================
    add_heading_1("16. Booking Validation & Overlap Prevention")
    add_body("To prevent double bookings, ParkSafe enforces a mathematical overlap validation formula at the database level:")
    add_code_block("(NewStart < ExistingEnd) AND (NewEnd > ExistingStart)")
    add_body("Validation Examples:")
    add_bullet("Existing Booking: 12 August 2026 (1:00 PM – 2:00 PM)")
    add_bullet("ALLOWED: 12 August 2026 (3:00 PM – 4:00 PM) → Times do not overlap.")
    add_bullet("BLOCKED: 12 August 2026 (1:30 PM – 2:30 PM) → Overlaps by 30 minutes; database blocks reservation.")

    # =========================================================================
    # 17. QR CODE GENERATION & SCANNING GATEKEEPER
    # =========================================================================
    add_heading_1("17. QR Code Generation & Gatekeeping")
    add_body("The digital QR pass workflow operates as follows:")
    add_bullet("1. Generation: Upon booking confirmation, qr_flutter encodes a JSON payload containing booking_id, user_id, vehicle_number, slot_number, and start_time.")
    add_bullet("2. Display: Customer presents the QR pass screen upon arrival at the parking facility.")
    add_bullet("3. Scanning: Admin uses the Mobile Scanner camera feed in the Admin Panel to scan the QR pass.")
    add_bullet("4. Check-In Verification: Admin verifies vehicle plate number and taps Check-In. Status updates to 'checked_in'. Early check-in is blocked.")
    add_bullet("5. Check-Out Verification: Upon exit, Admin scans QR again. System calculates actual duration vs scheduled duration, adds overtime fee if late, and updates status to 'completed'.")

    # =========================================================================
    # 18. AUTOMATED OVERTIME ENGINE
    # =========================================================================
    add_heading_1("18. Automated Overtime Engine")
    add_body("When a vehicle checks out, the system compares actual check-out time against scheduled end time:")
    add_code_block("Overtime Minutes = ActualCheckOutTime - ScheduledEndTime\nExtra Hours = ceil(Overtime Minutes / 60)\nOvertime Fee = Extra Hours * Price Per Hour")
    add_body("If overtime is detected, the overtime fee is added to total_amount in public.bookings, and a push alert is dispatched to the customer.")

    # =========================================================================
    # 19. AI RECOMMENDATION MICROSERVICE
    # =========================================================================
    add_heading_1("19. AI Recommendation Microservice")
    add_body("ParkSafe incorporates a Python FastAPI microservice (/recommend) that ranks parking locations using geospatial proximity and availability scores:")
    add_code_block("Distance Score = 1 / (HaversineDistance_KM + 0.1)\nAvailability Score = Free Slots / Total Slots\nFinal Score = (0.60 * Distance Score) + (0.40 * Availability Score)")
    add_body("Status: Implemented as a functional Python FastAPI backend microservice (Prototype).")

    # =========================================================================
    # 20. VIVA QUICK REFERENCE (Q&A)
    # =========================================================================
    add_heading_1("20. Viva Quick Reference (Q&A)")
    viva_qa = [
        ("Q1: What is ParkSafe?", "A1: ParkSafe is a smart vehicle parking booking application built with Flutter and Supabase that allows users to pre-book parking slots across multi-floor facilities."),
        ("Q2: Why did you choose Flutter and Supabase?", "A2: Flutter allows compiling to Web, Android, and iOS from a single Dart codebase. Supabase provides a scalable cloud PostgreSQL database with authentication and real-time listeners."),
        ("Q3: How are overlapping bookings prevented?", "A3: The database executes an overlap validation query: (NewStart < ExistEnd) AND (NewEnd > ExistStart). If true, the database blocks the booking attempt."),
        ("Q4: How does the QR gatekeeper work?", "A4: Upon booking, a JSON payload is encoded into a QR code. At the gate, the Admin camera scanner decodes the QR, verifies booking status, and processes Check-In or Check-Out."),
        ("Q5: How is overtime calculated?", "A5: The system compares actual checkout time with scheduled end time. Extra hours are calculated using ceil(overtime_mins / 60) and multiplied by the hourly rate.")
    ]
    for q, a in viva_qa:
        add_bullet(q, bold_prefix="")
        add_body(a, italic=True)

    # =========================================================================
    # 21. CONCLUSION
    # =========================================================================
    add_heading_1("21. Conclusion")
    add_body("ParkSafe successfully addresses urban parking congestion by providing guaranteed pre-booking, multi-floor slot visibility, contactless QR gatekeeping, automated overtime tracking, and AI proximity recommendations. The complete application source code, cloud database, presentation deck, and migration scripts are fully operational.")

    # Save Document
    path1 = r"C:\Users\isida\Desktop\ParkSafe_Complete_Project_Documentation.docx"
    path2 = r"C:\Users\isida\Desktop\Parksafe\ParkSafe_Complete_Project_Documentation.docx"

    doc.save(path1)
    doc.save(path2)
    print(f"Documentation generated successfully at:\n - {path1}\n - {path2}")

if __name__ == "__main__":
    create_parksafe_documentation()
