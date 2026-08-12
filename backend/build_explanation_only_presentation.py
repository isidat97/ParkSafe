import os
import re
import pptx
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
from pptx.enum.shapes import MSO_SHAPE

def build_explanation_only_presentation():
    pptx_path = r'C:/Users/isida/Desktop/ParkSafe_College_Presentation.pptx'
    logo_path = r'C:/Users/isida/Desktop/Parksafe/assets/images/parksafe_logo_clean.png'
    watermark_path = r'C:/Users/isida/Desktop/Parksafe/assets/images/parksafe_watermark.png'

    prs = Presentation()
    prs.slide_width = Inches(13.333) # 16:9 Widescreen
    prs.slide_height = Inches(7.5)

    # Color Palette
    COLOR_WHITE = RGBColor(255, 255, 255)
    COLOR_PRIMARY_GREEN = RGBColor(15, 81, 50) # #0F5132
    COLOR_DARK_TEXT = RGBColor(20, 24, 27) # #14181B
    COLOR_MUTED_TEXT = RGBColor(91, 102, 96) # #5B6660
    COLOR_CARD_BG = RGBColor(248, 250, 249) # Clean white-tint card
    COLOR_BORDER = RGBColor(226, 232, 240) # Light border

    FONT_HEADING = 'Walbaum Display'
    FONT_BODY = 'Aptos Light'

    def set_white_background(slide):
        background = slide.background
        fill = background.fill
        fill.solid()
        fill.fore_color.rgb = COLOR_WHITE

    def add_watermark(slide):
        if os.path.exists(watermark_path):
            slide.shapes.add_picture(
                watermark_path,
                left=Inches(9.6),
                top=Inches(5.1),
                width=Inches(3.3)
            )

    def add_slide_header(slide, title_text, category_text="PARKSAFE PROJECT PRESENTATION"):
        header_box = slide.shapes.add_textbox(Inches(0.8), Inches(0.4), Inches(11.7), Inches(1.1))
        tf = header_box.text_frame
        tf.word_wrap = True
        tf.margin_left = tf.margin_top = tf.margin_right = tf.margin_bottom = 0

        p0 = tf.paragraphs[0]
        p0.text = category_text.upper()
        p0.font.name = FONT_BODY
        p0.font.size = Pt(11)
        p0.font.bold = True
        p0.font.color.rgb = COLOR_MUTED_TEXT

        p1 = tf.add_paragraph()
        p1.text = title_text
        p1.font.name = FONT_HEADING
        p1.font.size = Pt(32) # Main title size
        p1.font.bold = True
        p1.font.color.rgb = COLOR_PRIMARY_GREEN
        p1.space_before = Pt(3)

    def clean_heading_text(title):
        cleaned = re.sub(r'^[^\w\s]+', '', title).strip()
        return cleaned

    def add_card(slide, left, top, width, height, title, points, font_body_size=20, font_title_size=25):
        shape = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, left, top, width, height)
        shape.fill.solid()
        shape.fill.fore_color.rgb = COLOR_CARD_BG
        shape.line.color.rgb = COLOR_BORDER
        shape.line.width = Pt(1.5)

        tbox = slide.shapes.add_textbox(left + Inches(0.25), top + Inches(0.2), width - Inches(0.5), height - Inches(0.4))
        tf = tbox.text_frame
        tf.word_wrap = True
        tf.margin_left = tf.margin_top = tf.margin_right = tf.margin_bottom = 0

        clean_title = clean_heading_text(title)
        p0 = tf.paragraphs[0]
        p0.text = clean_title
        p0.font.name = FONT_HEADING
        p0.font.size = Pt(font_title_size) # 25-28pt
        p0.font.bold = True
        p0.font.color.rgb = COLOR_PRIMARY_GREEN
        p0.space_after = Pt(8)

        for idx, pt in enumerate(points):
            p = tf.add_paragraph()
            p.text = f"• {pt}"
            p.font.name = FONT_BODY
            p.font.size = Pt(font_body_size) # 20-22pt perfectly calculated to stay inside card
            p.font.color.rgb = COLOR_DARK_TEXT
            p.space_after = Pt(6)
            p.line_spacing = 1.12

    # =========================================================================
    # SLIDE 1: TITLE SLIDE
    # =========================================================================
    slide1 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide1)

    if os.path.exists(logo_path):
        slide1.shapes.add_picture(logo_path, Inches(0.8), Inches(0.6), width=Inches(4.2))

    tbox1 = slide1.shapes.add_textbox(Inches(0.8), Inches(2.1), Inches(11.7), Inches(2.4))
    tf1 = tbox1.text_frame
    tf1.word_wrap = True
    tf1.margin_left = tf1.margin_top = tf1.margin_right = tf1.margin_bottom = 0

    p_title = tf1.paragraphs[0]
    p_title.text = "ParkSafe"
    p_title.font.name = FONT_HEADING
    p_title.font.size = Pt(48)
    p_title.font.bold = True
    p_title.font.color.rgb = COLOR_PRIMARY_GREEN

    p_sub = tf1.add_paragraph()
    p_sub.text = "Smart Vehicle Parking & Online Slot Booking Application"
    p_sub.font.name = FONT_BODY
    p_sub.font.size = Pt(24)
    p_sub.font.bold = True
    p_sub.font.color.rgb = COLOR_DARK_TEXT
    p_sub.space_before = Pt(6)

    p_tag = tf1.add_paragraph()
    p_tag.text = "FIND. BOOK. PARK SAFE."
    p_tag.font.name = FONT_BODY
    p_tag.font.size = Pt(16)
    p_tag.font.bold = True
    p_tag.font.color.rgb = COLOR_PRIMARY_GREEN
    p_tag.space_before = Pt(6)

    team_box = slide1.shapes.add_textbox(Inches(0.8), Inches(4.7), Inches(5.5), Inches(2.2))
    tf_team = team_box.text_frame
    tf_team.word_wrap = True

    pt0 = tf_team.paragraphs[0]
    pt0.text = "TEAM MEMBERS:"
    pt0.font.name = FONT_BODY
    pt0.font.size = Pt(16)
    pt0.font.bold = True
    pt0.font.color.rgb = COLOR_PRIMARY_GREEN
    pt0.space_after = Pt(6)

    for name in ["Sayyed Mashhuda", "Sidat Ibrahim", "Patel Dhruvil"]:
        pt = tf_team.add_paragraph()
        pt.text = f"• {name}"
        pt.font.name = FONT_BODY
        pt.font.size = Pt(18)
        pt.font.color.rgb = COLOR_DARK_TEXT
        pt.space_after = Pt(4)

    dept_box = slide1.shapes.add_textbox(Inches(6.8), Inches(4.7), Inches(5.5), Inches(2.2))
    tf_dept = dept_box.text_frame
    tf_dept.word_wrap = True

    pd0 = tf_dept.paragraphs[0]
    pd0.text = "DEPARTMENT:"
    pd0.font.name = FONT_BODY
    pd0.font.size = Pt(16)
    pd0.font.bold = True
    pd0.font.color.rgb = COLOR_PRIMARY_GREEN
    pd0.space_after = Pt(6)

    pd1 = tf_dept.add_paragraph()
    pd1.text = "B.Voc (Bachelor of Vocation)"
    pd1.font.name = FONT_BODY
    pd1.font.size = Pt(20)
    pd1.font.bold = True
    pd1.font.color.rgb = COLOR_DARK_TEXT
    pd1.space_after = Pt(4)

    pd2 = tf_dept.add_paragraph()
    pd2.text = "Software Development / Computer Applications"
    pd2.font.name = FONT_BODY
    pd2.font.size = Pt(16)
    pd2.font.color.rgb = COLOR_MUTED_TEXT

    # =========================================================================
    # SLIDE 2: INTRODUCTION & PROJECT BACKGROUND
    # =========================================================================
    slide2 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide2)
    add_watermark(slide2)
    add_slide_header(slide2, "1. Introduction & Project Background")

    add_card(slide2, Inches(0.8), Inches(1.6), Inches(3.6), Inches(5.3),
             "Urbanization Crisis",
             ["Rapid growth in private vehicle ownership in cities.",
              "Severe congestion caused by drivers searching for open slots.",
              "Need for smart transportation & digital infrastructure."],
             font_body_size=20, font_title_size=25)

    add_card(slide2, Inches(4.8), Inches(1.6), Inches(3.6), Inches(5.3),
             "The Digital Shift",
             ["Transitioning from paper tokens to digital reservations.",
              "Eliminating uncertainty prior to starting a trip.",
              "Providing real-time visibility into multi-floor parking."],
             font_body_size=20, font_title_size=25)

    add_card(slide2, Inches(8.8), Inches(1.6), Inches(3.7), Inches(5.3),
             "The ParkSafe Vision",
             ["Unified cross-platform solution (Flutter + Supabase).",
              "AI recommendation engine for nearest available slots.",
              "Contactless check-in via secure QR pass verification."],
             font_body_size=20, font_title_size=25)

    # =========================================================================
    # SLIDE 3: PROBLEM STATEMENT
    # =========================================================================
    slide3 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide3)
    add_watermark(slide3)
    add_slide_header(slide3, "2. Problem Statement: Urban Parking Crises")

    add_card(slide3, Inches(0.8), Inches(1.6), Inches(5.6), Inches(2.55),
             "Time & Fuel Wastage",
             ["Drivers spend 15–20 minutes searching for parking.",
              "Causes 30% of unnecessary city traffic congestion."],
             font_body_size=20, font_title_size=25)

    add_card(slide3, Inches(6.8), Inches(1.6), Inches(5.7), Inches(2.55),
             "Lack of Information",
             ["Drivers arrive blindly without knowing slot availability.",
              "No distinction between vehicle types (Car, Bike, EV)."],
             font_body_size=20, font_title_size=25)

    add_card(slide3, Inches(0.8), Inches(4.35), Inches(5.6), Inches(2.55),
             "Manual Operations",
             ["Paper ticket loss causes administrative disputes.",
              "Lack of automated overstay tracking and fee collection."],
             font_body_size=20, font_title_size=25)

    add_card(slide3, Inches(6.8), Inches(4.35), Inches(5.7), Inches(2.55),
             "Security Risks",
             ["Difficulty verifying ticket ownership without digital credentials.",
              "No automated push notifications for booking expiry."],
             font_body_size=20, font_title_size=25)

    # =========================================================================
    # SLIDE 4: EXISTING PARKING PROBLEMS VS PARKSAFE SOLUTION
    # =========================================================================
    slide4 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide4)
    add_watermark(slide4)
    add_slide_header(slide4, "3. Existing Problems vs. ParkSafe Solution")

    add_card(slide4, Inches(0.8), Inches(1.6), Inches(5.6), Inches(5.3),
             "Traditional Manual Systems",
             ["Blind Arrival: Drivers search aimlessly for open spots.",
              "Paper Tokens: High risk of lost tickets & manual entry delays.",
              "No Floor Visibility: Garage operators lack real-time slot tracking.",
              "Unrecorded Overtime: Overstaying vehicles are rarely penalized accurately."],
             font_body_size=20, font_title_size=25)

    add_card(slide4, Inches(6.8), Inches(1.6), Inches(5.7), Inches(5.3),
             "ParkSafe Smart Platform",
             ["Guaranteed Pre-Booking: Reserve slots ahead of departure.",
              "Contactless Digital Pass: Encrypted QR ticket pass on smartphone.",
              "Multi-Floor Slot Grid: Real-time visual availability per floor.",
              "Automated Overtime Engine: Automatic penalty calculation upon exit."],
             font_body_size=20, font_title_size=25)

    # =========================================================================
    # SLIDE 5: PROPOSED SOLUTION - THE PARKSAFE ECOSYSTEM
    # =========================================================================
    slide5 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide5)
    add_watermark(slide5)
    add_slide_header(slide5, "4. Proposed Solution: The ParkSafe Ecosystem")

    add_card(slide5, Inches(0.8), Inches(1.6), Inches(3.6), Inches(5.3),
             "Pre-Booking System",
             ["Reserve guaranteed parking slots ahead of arrival.",
              "Filter slots specifically for Car, Bike, or EV charging.",
              "Single-page scrollable visual floor grid."],
             font_body_size=20, font_title_size=25)

    add_card(slide5, Inches(4.8), Inches(1.6), Inches(3.6), Inches(5.3),
             "AI Recommendation",
             ["Calculates distance using Haversine formula.",
              "Combines proximity + real-time slot availability ratio.",
              "Fast Python FastAPI backend scoring engine."],
             font_body_size=20, font_title_size=25)

    add_card(slide5, Inches(8.8), Inches(1.6), Inches(3.7), Inches(5.3),
             "Digital Gatekeeping",
             ["Contactless QR code ticket pass generation.",
              "Instant Admin scanner for entry & exit check-out.",
              "Firebase FCM real-time push notifications."],
             font_body_size=20, font_title_size=25)

    # =========================================================================
    # SLIDE 6: PROJECT OBJECTIVES & SCOPE
    # =========================================================================
    slide6 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide6)
    add_watermark(slide6)
    add_slide_header(slide6, "5. Key Objectives & Project Scope")

    add_card(slide6, Inches(0.8), Inches(1.6), Inches(5.6), Inches(5.3),
             "Core Technical Objectives",
             ["Zero Double-Booking: Enforce datetime overlap check in database.",
              "Multi-Floor Architecture: Support dynamic floor-level slot management.",
              "Real-Time Sync: Cloud database sync between app & admin panel.",
              "Cross-Platform: Single Flutter codebase for Web, Android & iOS."],
             font_body_size=20, font_title_size=25)

    add_card(slide6, Inches(6.8), Inches(1.6), Inches(5.7), Inches(5.3),
             "Project Scope & Boundaries",
             ["Customer App: Search, AI recommendation, vehicle slot reservation, QR ticket.",
              "Admin Panel: Add locations, floor slot management, QR scanner, live stats.",
              "Backend: Python FastAPI microservice for AI scoring & notification worker."],
             font_body_size=20, font_title_size=25)

    # =========================================================================
    # SLIDE 7: KEY FEATURES & CAPABILITIES OVERVIEW
    # =========================================================================
    slide7 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide7)
    add_watermark(slide7)
    add_slide_header(slide7, "6. Key Features & Capabilities Overview")

    features = [
        ("Multi-Floor Setup", "Dynamic floor setup (Floor 1, 2, Basement) with custom Car/Bike/EV limits."),
        ("AI Recommender", "Ranks locations using distance + real-time slot availability score."),
        ("Overlap Check", "Database overlap query prevents any overlapping booking collisions."),
        ("QR Pass Scanner", "Instant gate entry/exit verification with early check-in protection."),
        ("FCM Notifications", "Automated 15-min check-in, 15-min check-out, and overtime alerts."),
        ("Overtime & Refunds", "Automatic penalty fee calculation for overstaying and refund management.")
    ]

    for idx, (ftitle, fdesc) in enumerate(features):
        r = idx // 3
        c = idx % 3
        left = Inches(0.8 + c * 3.9)
        top = Inches(1.6 + r * 2.7)
        add_card(slide7, left, top, Inches(3.6), Inches(2.55), ftitle, [fdesc], font_body_size=19, font_title_size=24)

    # =========================================================================
    # SLIDE 8: CUSTOMER APPLICATION FEATURES
    # =========================================================================
    slide8 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide8)
    add_watermark(slide8)
    add_slide_header(slide8, "7. Customer Application Features")

    add_card(slide8, Inches(0.8), Inches(1.6), Inches(5.6), Inches(5.3),
             "Search & Location Discovery",
             ["Account Registration & Secure Mobile Login.",
              "Interactive Parking Search & Google Maps Direction Link.",
              "Filter locations by Amenities (24/7 CCTV, EV Charging, Valet).",
              "AI-powered nearest and available parking recommendation."],
             font_body_size=20, font_title_size=25)

    add_card(slide8, Inches(6.8), Inches(1.6), Inches(5.7), Inches(5.3),
             "Reservation & Ticket Management",
             ["Date, Check-In, and Check-Out Time Range Selection.",
              "Vehicle Category Filter: Car, Bike, or EV Charging.",
              "Single-Page Scrollable Visual Floor & Slot Selection Grid.",
              "Digital QR Ticket Pass with Active & Past Booking Tracking."],
             font_body_size=20, font_title_size=25)

    # =========================================================================
    # SLIDE 9: ADMIN PANEL OPERATIONAL SUITE FEATURES
    # =========================================================================
    slide9 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide9)
    add_watermark(slide9)
    add_slide_header(slide9, "8. Admin Panel Operational Suite Features")

    add_card(slide9, Inches(0.8), Inches(1.6), Inches(5.6), Inches(5.3),
             "Facility & Capacity Setup",
             ["Add/Edit Parking Places with Google Maps Location URLs.",
              "Multi-Floor Toggle: Configure total floors and per-floor counts.",
              "Vehicle Slot Breakdown: Allocate Car, Bike, and EV slots per floor.",
              "Live Dashboard: Total Revenue, Occupancy Rate & Today's Bookings."],
             font_body_size=20, font_title_size=25)

    add_card(slide9, Inches(6.8), Inches(1.6), Inches(5.7), Inches(5.3),
             "Gatekeeping & Customer Support",
             ["High-Speed Camera QR Scanner for Gate Check-In & Check-Out.",
              "Manual License Plate Search fallback for rapid lookup.",
              "Early Check-In Protection: Prevents entry prior to start time.",
              "Refund Management: Accept or reject customer refund requests."],
             font_body_size=20, font_title_size=25)

    # =========================================================================
    # SLIDE 10: PARKING LOCATION & MULTI-FLOOR MANAGEMENT
    # =========================================================================
    slide10 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide10)
    add_watermark(slide10)
    add_slide_header(slide10, "9. Multi-Floor Parking & Slot Management")

    add_card(slide10, Inches(0.8), Inches(1.6), Inches(5.6), Inches(5.3),
             "Admin Multi-Floor Configuration",
             ["Multi-Floor Hierarchy: Location -> Floor -> Slot -> Vehicle Type.",
              "Dynamic Floor Form: Admin enters total floors (e.g. 5 floors).",
              "Independent Capacities: Floor 1 (20 slots), Floor 2 (25 slots).",
              "Strict Validation: Enforces Car + Bike + EV = Total Floor Capacity.",
              "Auto-Slot Generator: Auto-creates slots (e.g., C-01, E-01) with floor tags."],
             font_body_size=20, font_title_size=25)

    add_card(slide10, Inches(6.8), Inches(1.6), Inches(5.7), Inches(5.3),
             "Customer Floor Layout",
             ["Single Scrollable Screen: All floors displayed on one screen.",
              "Floor Headings: Clear section headers ('Floor 1', 'Floor 2', 'Basement').",
              "Live Availability Badges: Displays available count per floor.",
              "Vehicle Filter: Displays requested vehicle type slots.",
              "Ticket Sync: Tickets & My Bookings show 'Floor 2 → Slot C-24'."],
             font_body_size=20, font_title_size=25)

    # =========================================================================
    # SLIDE 11: SLOT BOOKING & REAL-TIME AVAILABILITY SYSTEM
    # =========================================================================
    slide11 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide11)
    add_watermark(slide11)
    add_slide_header(slide11, "10. Slot Booking & Real-Time Availability")

    add_card(slide11, Inches(0.8), Inches(1.6), Inches(5.6), Inches(5.3),
             "Real-Time Query Mechanism",
             ["Queries active non-cancelled bookings for requested slot.",
              "Instant Status Badges: Slots marked 'Available' or 'Booked'.",
              "Immediate Release: Cancelled bookings instantly release slots back.",
              "Cloud Synchronization: Live Supabase database state across all users."],
             font_body_size=20, font_title_size=25)

    add_card(slide11, Inches(6.8), Inches(1.6), Inches(5.7), Inches(5.3),
             "Same-Day Non-Overlapping Bookings",
             ["Supports multiple bookings for the same slot on the same day.",
              "Example: Slot C-01 can be booked from 1:00–2:00 PM and 2:00–4:00 PM.",
              "Prevents partial time collisions (e.g., 1:30–2:30 PM blocked).",
              "Guarantees 100% reservation accuracy with zero double bookings."],
             font_body_size=20, font_title_size=25)

    # =========================================================================
    # SLIDE 12: BOOKING VALIDATION & OVERLAPPING BOOKING PREVENTION
    # =========================================================================
    slide12 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide12)
    add_watermark(slide12)
    add_slide_header(slide12, "11. Booking Validation & Overlap Prevention")

    add_card(slide12, Inches(0.8), Inches(1.6), Inches(5.6), Inches(5.3),
             "Database Mathematical Overlap Formula",
             ["Evaluates overlap condition: (NewStart < ExistEnd) AND (NewEnd > ExistStart).",
              "Strict Collision Guard: Database blocks overlapping booking attempt.",
              "Prevents double booking across all vehicle types (Car, Bike, EV).",
              "Guarantees 100% reservation accuracy at database level."],
             font_body_size=20, font_title_size=25)

    add_card(slide12, Inches(6.8), Inches(1.6), Inches(5.7), Inches(5.3),
             "Validation Example",
             ["Existing Booking: 12 August 2026 (1:00 PM – 2:00 PM).",
              "ALLOWED: 12 August 2026 (3:00 PM – 4:00 PM) -> No time overlap.",
              "BLOCKED: 12 August 2026 (1:30 PM – 2:30 PM) -> Time overlap detected.",
              "Rule: System prevents overlapping bookings for the same vehicle while allowing separate non-overlapping bookings on the same day."],
             font_body_size=20, font_title_size=25)

    # =========================================================================
    # SLIDE 13: QR-BASED CHECK-IN & CHECK-OUT VERIFICATION FLOW
    # =========================================================================
    slide13 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide13)
    add_watermark(slide13)
    add_slide_header(slide13, "12. QR-Based Check-In & Check-Out Flow")

    add_card(slide13, Inches(0.8), Inches(1.6), Inches(5.6), Inches(5.3),
             "Pass Verification & State Flow",
             ["Booking Confirmed -> Customer arrives at garage.",
              "Admin Scans QR -> System verifies booking credentials.",
              "Check-In -> Booking state becomes 'Active / Checked In'.",
              "Check-Out -> Admin scans on exit, recording exact UTC exit time.",
              "State Transition: Booking moves from 'Active' to 'Past'."],
             font_body_size=20, font_title_size=25)

    add_card(slide13, Inches(6.8), Inches(1.6), Inches(5.7), Inches(5.3),
             "Early Check-In Rule & Fallback",
             ["Early Check-In Protection: Prevents check-in prior to start time.",
              "Clear UI Feedback: Displays countdown minutes if customer arrives early.",
              "Manual Plate Search: Fallback search by vehicle number plate if QR fails.",
              "Audit Trail: Logs check-in/out timestamps and admin IDs in database."],
             font_body_size=20, font_title_size=25)

    # =========================================================================
    # SLIDE 14: NOTIFICATIONS, REMINDERS & OVERTIME MANAGEMENT
    # =========================================================================
    slide14 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide14)
    add_watermark(slide14)
    add_slide_header(slide14, "13. Notifications & Overtime Management")

    add_card(slide14, Inches(0.8), Inches(1.6), Inches(5.6), Inches(5.3),
             "Firebase FCM Background Push Alerts",
             ["Check-In Reminder: Pushed 15 minutes before scheduled start time.",
              "Check-Out Reminder: Pushed 15 minutes before scheduled end time.",
              "Overtime Alert: Warning push notification when customer exceeds checkout time.",
              "In-App Sync: Notifications stored in database & synced live."],
             font_body_size=20, font_title_size=25)

    add_card(slide14, Inches(6.8), Inches(1.6), Inches(5.7), Inches(5.3),
             "Automated Overtime Fee Engine",
             ["Condition: Compares Actual Check-Out vs Scheduled Check-Out.",
              "Example: Scheduled 10:00 PM, Actual Check-Out 10:15 PM (15 mins late).",
              "Extra Hours Calculation: Extra Hours = ceil(overtime_minutes / 60).",
              "Fee Calculation: Overtime Fee = Extra Hours * Hourly Rate.",
              "Invoice Update: Overtime fee automatically added to final payment."],
             font_body_size=20, font_title_size=25)

    # =========================================================================
    # SLIDE 15: REFUND & CUSTOMER ACCOUNT MANAGEMENT
    # =========================================================================
    slide15 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide15)
    add_watermark(slide15)
    add_slide_header(slide15, "14. Refund & Customer Account Management")

    add_card(slide15, Inches(0.8), Inches(1.6), Inches(5.6), Inches(5.3),
             "Customer Refund Workflow",
             ["Cancellation Policy: Customer requests refund before check-in.",
              "Admin Review Dashboard: Admin inspects request reason.",
              "Status Audit: 'Requested' -> 'Approved' / 'Rejected' -> 'Refunded'.",
              "Real-Time Alert: Customer receives instant push alert on status update."],
             font_body_size=20, font_title_size=25)

    add_card(slide15, Inches(6.8), Inches(1.6), Inches(5.7), Inches(5.3),
             "Customer Profile Management",
             ["Profile Editing: Customers can edit Full Name & Mobile Number.",
              "No Avatar Upload: Kept clean & focused on basic account info.",
              "Record Preservation: Updates existing customer record in Supabase using ID without creating duplicates.",
              "Data Consistency: Updated info instantly reflects in Customer app & Admin panel."],
             font_body_size=20, font_title_size=25)

    # =========================================================================
    # SLIDE 16: AI NEAREST & AVAILABLE PARKING RECOMMENDATION
    # =========================================================================
    slide16 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide16)
    add_watermark(slide16)
    add_slide_header(slide16, "15. AI Nearest & Available Recommendation")

    add_card(slide16, Inches(0.8), Inches(1.6), Inches(3.6), Inches(5.3),
             "Geospatial Calculation",
             ["Uses Haversine distance formula based on GPS lat/lng.",
              "Calculates precise distance in km from user position.",
              "Estimates driving ETA minutes."],
             font_body_size=20, font_title_size=25)

    add_card(slide16, Inches(4.8), Inches(1.6), Inches(3.6), Inches(5.3),
             "Availability Scoring",
             ["Queries live slot occupancy for requested vehicle type.",
              "Score = Free Slots / Total Slots.",
              "Filters out locations with zero available slots."],
             font_body_size=20, font_title_size=25)

    add_card(slide16, Inches(8.8), Inches(1.6), Inches(3.7), Inches(5.3),
             "Hybrid Formula & Status",
             ["Formula: 0.60 * Distance Score + 0.40 * Availability Score.",
              "Ranks top recommendation results dynamically.",
              "Implementation: Microservice via Python FastAPI (Prototype)."],
             font_body_size=20, font_title_size=25)

    # =========================================================================
    # SLIDE 17: SYSTEM ARCHITECTURE & TECHNOLOGY STACK
    # =========================================================================
    slide17 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide17)
    add_watermark(slide17)
    add_slide_header(slide17, "16. System Architecture & Tech Stack")

    add_card(slide17, Inches(0.8), Inches(1.6), Inches(5.6), Inches(5.3),
             "System Layer Architecture",
             ["Client Layer: Flutter App (Dart) for Web, Android & iOS.",
              "State Layer: Provider Pattern for reactive UI updates.",
              "Database & Auth: Supabase PostgreSQL with RLS policies.",
              "Push Layer: Firebase Cloud Messaging (FCM).",
              "Microservice: Python FastAPI REST API with APScheduler worker."],
             font_body_size=20, font_title_size=25)

    add_card(slide17, Inches(6.8), Inches(1.6), Inches(5.7), Inches(5.3),
             "Third-Party Integrations",
             ["Google Maps API: Direct turn-by-turn navigation links.",
              "Geolocator: Live GPS location tracking & distance calculation.",
              "Mobile Scanner: High-speed camera QR code reader.",
              "Figma & GitHub: Prototyping & source version control."],
             font_body_size=20, font_title_size=25)

    # =========================================================================
    # SLIDE 18: DATABASE SCHEMA & SUPABASE BACKEND
    # =========================================================================
    slide18 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide18)
    add_watermark(slide18)
    add_slide_header(slide18, "17. Database Schema & Supabase Backend")

    add_card(slide18, Inches(0.8), Inches(1.6), Inches(5.6), Inches(5.3),
             "Core Database Tables",
             ["Profiles: id, full_name, mobile_number, fcm_token, role.",
              "Parking Locations: id, name, address, lat, lng, price, google_maps_link.",
              "Parking Slots: id, location_id, slot_number, slot_type, floor.",
              "Bookings: id, user_id, slot_id, booking_date, start_time, end_time, status, overtime_fee."],
             font_body_size=20, font_title_size=25)

    add_card(slide18, Inches(6.8), Inches(1.6), Inches(5.7), Inches(5.3),
             "Relational Entity Structure",
             ["Location -> contains Floors & Slots.",
              "Slot -> belongs to Parking Location.",
              "Booking -> connects Customer + Parking Location + Slot.",
              "Supabase Row Level Security (RLS) ensures secure user data privacy."],
             font_body_size=20, font_title_size=25)

    # =========================================================================
    # SLIDE 19: COMPLETE BOOKING WORKFLOW / SYSTEM FLOW
    # =========================================================================
    slide19 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide19)
    add_watermark(slide19)
    add_slide_header(slide19, "18. Complete System End-to-End Workflow")

    add_card(slide19, Inches(0.8), Inches(1.6), Inches(5.6), Inches(5.3),
             "Customer Journey Sequence",
             ["1. Customer Registration / Login.",
              "2. Search Parking & View Details / Google Maps.",
              "3. Select Vehicle Type (Car, Bike, EV) & Date/Time.",
              "4. Select Floor & Slot on single-page visual grid.",
              "5. Enter Vehicle Number & Pay -> QR Ticket generated."],
             font_body_size=20, font_title_size=25)

    add_card(slide19, Inches(6.8), Inches(1.6), Inches(5.7), Inches(5.3),
             "Admin Gatekeeping Sequence",
             ["6. Arrival: Admin scans QR ticket at entry gate.",
              "7. Check-In: Status becomes 'Active / Checked In'.",
              "8. Exit: Admin scans QR on checkout.",
              "9. Overtime Check: Calculates extra hours if late.",
              "10. Completion: Status moves from 'Active' to 'Past'."],
             font_body_size=20, font_title_size=25)

    # =========================================================================
    # SLIDE 20: BENEFITS, FUTURE SCOPE & CONCLUSION
    # =========================================================================
    slide20 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide20)
    add_watermark(slide20)
    add_slide_header(slide20, "19. Benefits, Future Scope & Conclusion")

    add_card(slide20, Inches(0.8), Inches(1.6), Inches(5.6), Inches(5.3),
             "Key Achievements & Impact",
             ["Driver Convenience: Eliminates 15-20 min parking search time.",
              "Operator Efficiency: Automates gate check-ins and overtime tracking.",
              "Eco-Friendly: 100% paperless digital QR tickets.",
              "Environmental Impact: Reduces urban traffic & carbon emissions."],
             font_body_size=20, font_title_size=25)

    add_card(slide20, Inches(6.8), Inches(1.6), Inches(5.7), Inches(5.3),
             "Future Innovations & Conclusion",
             ["ANPR Integration: Automatic License Plate Recognition at barriers.",
              "Dynamic Surge Pricing: AI price adjustment during peak demand.",
              "IoT Sensor Integration: Real-time ultrasonic slot detection.",
              "Conclusion: Complete, scalable digital transformation for smart cities."],
             font_body_size=20, font_title_size=25)

    # =========================================================================
    # SLIDE 21 (FINAL): REFERENCES & TECHNOLOGIES USED
    # =========================================================================
    slide_ref = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide_ref)
    add_watermark(slide_ref)
    add_slide_header(slide_ref, "References & Technologies Used", category_text="PARKSAFE - PROJECT ARCHITECTURE & REFERENCES")

    tech_stack = [
        ("Flutter", "Cross-platform UI framework for Android, iOS & Web"),
        ("Dart", "Primary programming language for reactive mobile client"),
        ("Supabase", "Cloud PostgreSQL database, Auth & Realtime channels"),
        ("PostgreSQL", "Relational database engine with Row Level Security (RLS)"),
        ("Firebase FCM", "Push notification cloud messaging service for alerts"),
        ("Google Maps API", "Geospatial mapping & turn-by-turn navigation link"),
        ("Geolocator", "GPS location tracking & proximity distance calculation"),
        ("Python & FastAPI", "Microservice REST API for AI recommendation scoring"),
        ("APScheduler", "Background notification worker scheduler"),
        ("Figma", "UI/UX design, wireframing & logo branding assets"),
        ("Antigravity", "AI-assisted IDE & agentic coding development platform"),
        ("GitHub", "Version control, code repository & collaborative workflow")
    ]

    for idx, (tech_name, tech_desc) in enumerate(tech_stack):
        r = idx // 3
        c = idx % 3
        left = Inches(0.8 + c * 3.9)
        top = Inches(1.6 + r * 1.35)
        
        shape = slide_ref.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, left, top, Inches(3.6), Inches(1.2))
        shape.fill.solid()
        shape.fill.fore_color.rgb = COLOR_CARD_BG
        shape.line.color.rgb = COLOR_BORDER
        shape.line.width = Pt(1.2)

        tbox = slide_ref.shapes.add_textbox(left + Inches(0.15), top + Inches(0.12), Inches(3.3), Inches(0.95))
        tf = tbox.text_frame
        tf.word_wrap = True
        tf.margin_left = tf.margin_top = tf.margin_right = tf.margin_bottom = 0

        p0 = tf.paragraphs[0]
        p0.text = tech_name
        p0.font.name = FONT_HEADING
        p0.font.size = Pt(18)
        p0.font.bold = True
        p0.font.color.rgb = COLOR_PRIMARY_GREEN

        p1 = tf.add_paragraph()
        p1.text = tech_desc
        p1.font.name = FONT_BODY
        p1.font.size = Pt(12)
        p1.font.color.rgb = COLOR_DARK_TEXT
        p1.space_before = Pt(2)

    prs.save(pptx_path)
    print(f"Explanation-only presentation saved successfully with {len(prs.slides)} slides to: {pptx_path}")

if __name__ == "__main__":
    build_explanation_only_presentation()
