import os
import re
import pptx
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
from pptx.enum.shapes import MSO_SHAPE

def build_complete_presentation():
    pptx_path = r'C:/Users/isida/Desktop/ParkSafe_College_Presentation.pptx'
    logo_path = r'C:/Users/isida/Desktop/Parksafe/assets/images/parksafe_logo_clean.png'
    watermark_path = r'C:/Users/isida/Desktop/Parksafe/assets/images/parksafe_watermark.png'
    img_dir = r'C:/Users/isida/Desktop/Parksafe/assets/images'

    prs = Presentation()
    prs.slide_width = Inches(13.333) # 16:9 Widescreen
    prs.slide_height = Inches(7.5)

    # Color Palette
    COLOR_WHITE = RGBColor(255, 255, 255)
    COLOR_PRIMARY_GREEN = RGBColor(15, 81, 50) # #0F5132
    COLOR_DARK_TEXT = RGBColor(20, 24, 27) # #14181B
    COLOR_MUTED_TEXT = RGBColor(91, 102, 96) # #5B6660
    COLOR_CARD_BG = RGBColor(248, 250, 249) # Clean white-tint container
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
        p1.font.size = Pt(32) # Main heading size
        p1.font.bold = True
        p1.font.color.rgb = COLOR_PRIMARY_GREEN
        p1.space_before = Pt(3)

    def clean_heading_text(title):
        cleaned = re.sub(r'^[^\w\s]+', '', title).strip()
        return cleaned

    def add_card(slide, left, top, width, height, title, points, font_body_size=20, font_title_size=25):
        # Card Shape
        shape = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, left, top, width, height)
        shape.fill.solid()
        shape.fill.fore_color.rgb = COLOR_CARD_BG
        shape.line.color.rgb = COLOR_BORDER
        shape.line.width = Pt(1.5)

        # Content Text Box inside Container
        tbox = slide.shapes.add_textbox(left + Inches(0.25), top + Inches(0.2), width - Inches(0.5), height - Inches(0.4))
        tf = tbox.text_frame
        tf.word_wrap = True
        tf.margin_left = tf.margin_top = tf.margin_right = tf.margin_bottom = 0

        # Card Title
        clean_title = clean_heading_text(title)
        p0 = tf.paragraphs[0]
        p0.text = clean_title
        p0.font.name = FONT_HEADING
        p0.font.size = Pt(font_title_size) # 25-28pt
        p0.font.bold = True
        p0.font.color.rgb = COLOR_PRIMARY_GREEN
        p0.space_after = Pt(8)

        # Card Points
        for idx, pt in enumerate(points):
            p = tf.add_paragraph()
            p.text = f"• {pt}"
            p.font.name = FONT_BODY
            p.font.size = Pt(font_body_size) # 20-22pt perfectly calculated to stay 100% inside card
            p.font.color.rgb = COLOR_DARK_TEXT
            p.space_after = Pt(6)
            p.line_spacing = 1.12

    # Helper to add demo screenshot slide
    def add_screenshot_slide(prs, title_text, subtitle_text, explanation_points, img_filename, is_left_img=False):
        slide = prs.slides.add_slide(prs.slide_layouts[6])
        set_white_background(slide)
        add_watermark(slide)
        add_slide_header(slide, title_text, category_text="PARKSAFE - APPLICATION DEMONSTRATION")

        img_path = os.path.join(img_dir, img_filename)
        has_img = os.path.exists(img_path)

        if is_left_img:
            card_left, card_top, card_width, card_height = Inches(6.4), Inches(1.6), Inches(6.1), Inches(5.3)
            img_left, img_top, img_width, img_height = Inches(0.8), Inches(1.6), Inches(5.3), Inches(5.3)
        else:
            card_left, card_top, card_width, card_height = Inches(0.8), Inches(1.6), Inches(5.8), Inches(5.3)
            img_left, img_top, img_width, img_height = Inches(6.9), Inches(1.6), Inches(5.6), Inches(5.3)

        # Text Explanation Card
        add_card(slide, card_left, card_top, card_width, card_height, subtitle_text, explanation_points, font_body_size=20, font_title_size=25)

        # Screenshot Frame Container
        if has_img:
            frame = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, img_left, img_top, img_width, img_height)
            frame.fill.solid()
            frame.fill.fore_color.rgb = COLOR_CARD_BG
            frame.line.color.rgb = COLOR_BORDER
            frame.line.width = Pt(1.5)

            # Insert Image
            slide.shapes.add_picture(img_path, img_left + Inches(0.1), img_top + Inches(0.1), width=img_width - Inches(0.2))

        return slide

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
    # SLIDE 4: PROPOSED SOLUTION
    # =========================================================================
    slide4 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide4)
    add_watermark(slide4)
    add_slide_header(slide4, "3. Proposed Solution: The ParkSafe Platform")

    add_card(slide4, Inches(0.8), Inches(1.6), Inches(3.6), Inches(5.3),
             "Pre-Booking System",
             ["Reserve guaranteed parking slots ahead of arrival.",
              "Filter slots specifically for Car, Bike, or EV charging.",
              "Single-page scrollable visual floor grid."],
             font_body_size=20, font_title_size=25)

    add_card(slide4, Inches(4.8), Inches(1.6), Inches(3.6), Inches(5.3),
             "AI Recommendation",
             ["Calculates distance using Haversine formula.",
              "Combines proximity + real-time slot availability ratio.",
              "Fast Python FastAPI backend scoring engine."],
             font_body_size=20, font_title_size=25)

    add_card(slide4, Inches(8.8), Inches(1.6), Inches(3.7), Inches(5.3),
             "Digital Gatekeeping",
             ["Contactless QR code ticket pass generation.",
              "Instant Admin scanner for entry & exit check-out.",
              "Firebase FCM real-time push notifications."],
             font_body_size=20, font_title_size=25)

    # =========================================================================
    # SLIDE 5: OBJECTIVES & SCOPE
    # =========================================================================
    slide5 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide5)
    add_watermark(slide5)
    add_slide_header(slide5, "4. Key Objectives & Project Scope")

    add_card(slide5, Inches(0.8), Inches(1.6), Inches(5.6), Inches(5.3),
             "Core Technical Objectives",
             ["Zero Double-Booking: Enforce datetime overlap check in database.",
              "Multi-Floor Architecture: Support dynamic floor-level slot management.",
              "Real-Time Sync: Cloud database sync between app & admin panel.",
              "Cross-Platform: Single Flutter codebase for Web, Android & iOS."],
             font_body_size=20, font_title_size=25)

    add_card(slide5, Inches(6.8), Inches(1.6), Inches(5.7), Inches(5.3),
             "Project Scope & Boundaries",
             ["Customer App: Search, AI recommendation, vehicle slot reservation, QR ticket.",
              "Admin Panel: Add locations, floor slot management, QR scanner, live stats.",
              "Backend: Python FastAPI microservice for AI scoring & notification worker."],
             font_body_size=20, font_title_size=25)

    # =========================================================================
    # SLIDE 6: USER ROLES
    # =========================================================================
    slide6 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide6)
    add_watermark(slide6)
    add_slide_header(slide6, "5. User Roles & System Operations")

    add_card(slide6, Inches(0.8), Inches(1.6), Inches(5.6), Inches(5.3),
             "Customer (Vehicle Owner)",
             ["Account Registration & Secure Login.",
              "AI Nearest & Available Location Search.",
              "Date & Time Range Selection for Guaranteed Slot Booking.",
              "Floor & Slot Selection (Car, Bike, EV filtered).",
              "Digital QR Ticket Storage & Push Notification Alerts."],
             font_body_size=20, font_title_size=25)

    add_card(slide6, Inches(6.8), Inches(1.6), Inches(5.7), Inches(5.3),
             "Admin (Garage Operator)",
             ["Parking Location Creation & Maps Link Integration.",
              "Multi-Floor Setup & Vehicle Slot Allocation.",
              "QR Code Camera Scanner for Entry Check-In & Exit.",
              "Manual License Plate Search for Rapid Lookup.",
              "Live Revenue & Occupancy Dashboard."],
             font_body_size=20, font_title_size=25)

    # =========================================================================
    # SLIDE 7: MAIN FEATURES OVERVIEW
    # =========================================================================
    slide7 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide7)
    add_watermark(slide7)
    add_slide_header(slide7, "6. Main Core Features Overview")

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
    # SLIDE 8: CUSTOMER BOOKING PROCESS
    # =========================================================================
    slide8 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide8)
    add_watermark(slide8)
    add_slide_header(slide8, "7. Customer Booking Process & User Flow")

    steps = [
        ("Step 1: Location & Time", "Select parking location, date, check-in time, and check-out time."),
        ("Step 2: Vehicle Type", "Choose vehicle category: Car, Bike, or EV Charging."),
        ("Step 3: Floor & Slot", "View available slots grouped by floor on a single scrollable grid."),
        ("Step 4: QR Ticket Pass", "Instant payment confirmation & QR ticket generated for gate entry.")
    ]

    for idx, (stitle, sdesc) in enumerate(steps):
        left = Inches(0.8 + idx * 2.95)
        add_card(slide8, left, Inches(1.6), Inches(2.75), Inches(5.3), stitle, [sdesc], font_body_size=20, font_title_size=24)

    # =========================================================================
    # SLIDE 9: MULTI-FLOOR PARKING
    # =========================================================================
    slide9 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide9)
    add_watermark(slide9)
    add_slide_header(slide9, "8. Multi-Floor Parking & Slot Management")

    add_card(slide9, Inches(0.8), Inches(1.6), Inches(5.6), Inches(5.3),
             "Admin Multi-Floor Setup",
             ["Multi-Floor Toggle: Enable multi-floor setup when creating a place.",
              "Dynamic Floor Forms: Admin enters number of floors (e.g. 5 floors).",
              "Independent Capacities: Set Car, Bike, and EV slots per floor.",
              "Strict Validation: Enforces Car + Bike + EV = Total Slots for each floor.",
              "Automated Slot Generation: Auto-generates slots (e.g., C-01, E-01) with floor attributes."],
             font_body_size=20, font_title_size=25)

    add_card(slide9, Inches(6.8), Inches(1.6), Inches(5.7), Inches(5.3),
             "Customer Floor Layout",
             ["Single Scrollable Screen: All floors displayed on one screen.",
              "Floor Headings: Clear section headers (e.g. 'Floor 1', 'Floor 2').",
              "Live Availability Badges: Displays available count per floor.",
              "Vehicle Filter: Displays requested vehicle type slots.",
              "Ticket Sync: Tickets & My Bookings show 'Floor 2 → Slot C-24'."],
             font_body_size=20, font_title_size=25)

    # =========================================================================
    # SLIDE 10: REAL-TIME AVAILABILITY
    # =========================================================================
    slide10 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide10)
    add_watermark(slide10)
    add_slide_header(slide10, "9. Real-Time Availability & Overlap Logic")

    add_card(slide10, Inches(0.8), Inches(1.6), Inches(5.6), Inches(5.3),
             "Database Overlap Formula",
             ["Queries active non-cancelled bookings for requested slot.",
              "Mathematical Overlap Condition: (NewStart < ExistEnd) AND (NewEnd > ExistStart).",
              "If overlap is detected, slot is marked Unavailable.",
              "Cancelled bookings immediately release slot back to pool."],
             font_body_size=20, font_title_size=25)

    add_card(slide10, Inches(6.8), Inches(1.6), Inches(5.7), Inches(5.3),
             "Same-Day Bookings Rule",
             ["Supports multiple bookings for the same slot on the same day.",
              "Example: Slot C-01 can be booked from 1:00–2:00 PM and 2:00–4:00 PM.",
              "Prevents partial time collisions (e.g., 1:30–2:30 PM blocked).",
              "Guarantees 100% reservation accuracy with zero double bookings."],
             font_body_size=20, font_title_size=25)

    # =========================================================================
    # SLIDE 11: AI RECOMMENDATION ENGINE
    # =========================================================================
    slide11 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide11)
    add_watermark(slide11)
    add_slide_header(slide11, "10. AI Nearest & Available Recommendation")

    add_card(slide11, Inches(0.8), Inches(1.6), Inches(3.6), Inches(5.3),
             "Geospatial Calculation",
             ["Uses Haversine distance formula based on GPS lat/lng.",
              "Calculates precise distance in km from user position.",
              "Estimates driving ETA minutes."],
             font_body_size=20, font_title_size=25)

    add_card(slide11, Inches(4.8), Inches(1.6), Inches(3.6), Inches(5.3),
             "Availability Scoring",
             ["Queries live slot occupancy for vehicle type.",
              "Score = Free Slots / Total Slots.",
              "Filters out locations with zero available slots."],
             font_body_size=20, font_title_size=25)

    add_card(slide11, Inches(8.8), Inches(1.6), Inches(3.7), Inches(5.3),
             "Weighted Hybrid Score",
             ["Formula: 0.60 * Distance Score + 0.40 * Availability Score.",
              "Ranks top recommendation results dynamically.",
              "Exposed via Python FastAPI REST endpoint."],
             font_body_size=20, font_title_size=25)

    # =========================================================================
    # SLIDE 12: AI/ML & FRAUD DETECTION
    # =========================================================================
    slide12 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide12)
    add_watermark(slide12)
    add_slide_header(slide12, "11. AI/ML Analytics & Fraud Detection")

    add_card(slide12, Inches(0.8), Inches(1.6), Inches(5.6), Inches(5.3),
             "Predictive Peak Analytics",
             ["Analyzes historical booking trends by location and hour.",
              "Provides percentage prediction insight for future hours.",
              "Helps customers plan ahead for peak shopping hours."],
             font_body_size=20, font_title_size=25)

    add_card(slide12, Inches(6.8), Inches(1.6), Inches(5.7), Inches(5.3),
             "Fraud Prevention",
             ["Cryptographic QR Ticket Signature: Prevents QR code tampering.",
              "Duplicate Pass Guard: Prevents reuse of completed passes.",
              "License Match: Admin verifies vehicle number plate on check-in.",
              "Audit Trail: Logs check-in/out timestamps and admin IDs."],
             font_body_size=20, font_title_size=25)

    # =========================================================================
    # SLIDE 13: QR CHECK-IN & CHECK-OUT
    # =========================================================================
    slide13 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide13)
    add_watermark(slide13)
    add_slide_header(slide13, "12. QR Check-In & Check-Out Verification")

    add_card(slide13, Inches(0.8), Inches(1.6), Inches(5.6), Inches(5.3),
             "Admin QR Scanner Flow",
             ["Camera Scanner: Built-in high speed QR reader in Admin panel.",
              "Instant Lookup: Fetches customer profile & slot details.",
              "Manual Plate Search: Fallback search by vehicle plate.",
              "Status Transition: Updates state to 'Checked In' or 'Completed'."],
             font_body_size=20, font_title_size=25)

    add_card(slide13, Inches(6.8), Inches(1.6), Inches(5.7), Inches(5.3),
             "Early Check-In Protection",
             ["Early Check-In Rule: Prevents check-in prior to start time.",
              "Clear UI Feedback: Alerts admin if customer arrives early.",
              "Timestamp Precision: Stores exact check-in & check-out DateTime."],
             font_body_size=20, font_title_size=25)

    # =========================================================================
    # SLIDE 14: OVERTIME & PENALTY SYSTEM
    # =========================================================================
    slide14 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide14)
    add_watermark(slide14)
    add_slide_header(slide14, "13. Booking Status, Overtime & Penalty Fee")

    add_card(slide14, Inches(0.8), Inches(1.6), Inches(5.6), Inches(5.3),
             "Booking Lifecycle States",
             ["Pending: Booking created, awaiting arrival.",
              "Checked In: Vehicle scanned & parked inside garage.",
              "Completed: Vehicle checked out & total payment settled.",
              "Cancelled: Booking cancelled prior to check-in."],
             font_body_size=20, font_title_size=25)

    add_card(slide14, Inches(6.8), Inches(1.6), Inches(5.7), Inches(5.3),
             "Automated Overtime Engine",
             ["Overtime Condition: Triggered when checkout > scheduled end.",
              "Penalty Calculation: Extra Hours = ceil(overtime_minutes / 60).",
              "Fee Formula: Overtime Fee = Extra Hours * Hourly Rate.",
              "Real-Time Sync: Overtime fee automatically added to total invoice."],
             font_body_size=20, font_title_size=25)

    # =========================================================================
    # SLIDE 15: FIREBASE PUSH NOTIFICATIONS
    # =========================================================================
    slide15 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide15)
    add_watermark(slide15)
    add_slide_header(slide15, "14. Firebase Push Notifications & Reminders")

    add_card(slide15, Inches(0.8), Inches(1.6), Inches(3.6), Inches(5.3),
             "15-Min Check-In Reminder",
             ["Pushed 15 minutes before scheduled start time.",
              "Alerts customer to navigate to parking location.",
              "Delivered even when app is closed in background."],
             font_body_size=20, font_title_size=25)

    add_card(slide15, Inches(4.8), Inches(1.6), Inches(3.6), Inches(5.3),
             "15-Min Check-Out Reminder",
             ["Pushed 15 minutes before scheduled end time.",
              "Reminds customer to return to vehicle or extend.",
              "Helps avoid unexpected overtime fees."],
             font_body_size=20, font_title_size=25)

    add_card(slide15, Inches(8.8), Inches(1.6), Inches(3.7), Inches(5.3),
             "Overtime & In-App Sync",
             ["Pushes warning alert if vehicle stays past end time.",
              "Saves notification record to Supabase database.",
              "Synchronized in real-time with Notification page."],
             font_body_size=20, font_title_size=25)

    # =========================================================================
    # SLIDE 16: PAYMENT & REFUND MANAGEMENT
    # =========================================================================
    slide16 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide16)
    add_watermark(slide16)
    add_slide_header(slide16, "15. Payment & Refund Management")

    add_card(slide16, Inches(0.8), Inches(1.6), Inches(5.6), Inches(5.3),
             "Payment Integration",
             ["Digital Payment Gateways: Supports Card, UPI, and Wallet payments.",
              "Instant Receipt: Generates transaction reference ID.",
              "Transparent Pricing: Displays clear breakdown of hourly rate."],
             font_body_size=20, font_title_size=25)

    add_card(slide16, Inches(6.8), Inches(1.6), Inches(5.7), Inches(5.3),
             "Refund Workflow",
             ["Customer Cancellation: Request refund before check-in.",
              "Admin Approval Dashboard: Admin reviews & processes refund.",
              "Status Tracking: 'Requested', 'Approved', 'Refunded', 'Rejected'.",
              "Automated Push Alert when refund status updates."],
             font_body_size=20, font_title_size=25)

    # =========================================================================
    # SLIDE 17: GOOGLE MAPS INTEGRATION
    # =========================================================================
    slide17 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide17)
    add_watermark(slide17)
    add_slide_header(slide17, "16. Google Maps & Location Navigation")

    add_card(slide17, Inches(0.8), Inches(1.6), Inches(5.6), Inches(5.3),
             "Google Maps Integration",
             ["Direct Navigation Link: Opens native Google Maps app with destination.",
              "Admin Link Management: Admins can update Google Maps URL for any location.",
              "Distance & Route: Displays distance in km and estimated driving time."],
             font_body_size=20, font_title_size=25)

    add_card(slide17, Inches(6.8), Inches(1.6), Inches(5.7), Inches(5.3),
             "Parking Facilities",
             ["Custom Amenity Chips: 24/7 CCTV, EV Charging, Valet Parking, Car Wash.",
              "Filter & Badges: Highlights premium features on location details page.",
              "Admin Control: Easily toggle amenities when configuring place."],
             font_body_size=20, font_title_size=25)

    # =========================================================================
    # SLIDE 18: TECHNOLOGY STACK
    # =========================================================================
    slide18 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide18)
    add_watermark(slide18)
    add_slide_header(slide18, "17. Technology Stack & Architecture")

    add_card(slide18, Inches(0.8), Inches(1.6), Inches(3.6), Inches(5.3),
             "Frontend (Flutter)",
             ["Flutter SDK (Dart) for Web, Android & iOS.",
              "Provider State Management for reactive UI.",
              "Custom Dark & Light Theme system.",
              "Flutter Local Notifications & Mobile Scanner."],
             font_body_size=20, font_title_size=25)

    add_card(slide18, Inches(4.8), Inches(1.6), Inches(3.6), Inches(5.3),
             "Cloud (Supabase)",
             ["Supabase PostgreSQL Relational Database.",
              "Row Level Security (RLS) policies.",
              "Supabase Auth & Storage integration.",
              "Real-time database listener channels."],
             font_body_size=20, font_title_size=25)

    add_card(slide18, Inches(8.8), Inches(1.6), Inches(3.7), Inches(5.3),
             "Backend (Python)",
             ["FastAPI REST framework with Uvicorn.",
              "APScheduler for background notification worker.",
              "Firebase Admin SDK for FCM push notifications.",
              "NumPy & Haversine AI calculation engine."],
             font_body_size=20, font_title_size=25)

    # =========================================================================
    # SLIDE 19: BENEFITS & FUTURE SCOPE
    # =========================================================================
    slide19 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide19)
    add_watermark(slide19)
    add_slide_header(slide19, "18. Project Benefits & Future Scope")

    add_card(slide19, Inches(0.8), Inches(1.6), Inches(5.6), Inches(5.3),
             "Key Achievements & Benefits",
             ["Driver Convenience: Eliminates parking hunting time & guarantees slots.",
              "Operator Efficiency: Automates gate check-ins and revenue collection.",
              "Environmental Impact: Reduces fuel waste & urban carbon emissions.",
              "Eco-Friendly: 100% paperless digital QR tickets."],
             font_body_size=20, font_title_size=25)

    add_card(slide19, Inches(6.8), Inches(1.6), Inches(5.7), Inches(5.3),
             "Future Innovations",
             ["ANPR / ALPR Integration: Automatic License Plate Recognition at gate barriers.",
              "Dynamic Surge Pricing: AI price adjustment during peak demand hours.",
              "IoT Sensor Integration: Real-time ultrasonic slot detection hardware.",
              "EV Smart Charging Auto-Pay: Automated charging billing upon checkout."],
             font_body_size=20, font_title_size=25)

    # =========================================================================
    # SLIDE 20: CONCLUSION & SUMMARY
    # =========================================================================
    slide20 = prs.slides.add_slide(prs.slide_layouts[6])
    set_white_background(slide20)
    add_watermark(slide20)
    add_slide_header(slide20, "20. Conclusion & Project Summary")

    add_card(slide20, Inches(0.8), Inches(1.6), Inches(5.6), Inches(5.3),
             "Project Summary",
             ["Complete End-to-End Digital Transformation for Smart Urban Parking.",
              "Eliminates Traffic Congestion by offering guaranteed advance reservations.",
              "Bridges Customer Mobile App with powerful Admin Operational Dashboard.",
              "High Performance, Scalable Architecture built with Flutter, Supabase & Python."],
             font_body_size=20, font_title_size=25)

    add_card(slide20, Inches(6.8), Inches(1.6), Inches(5.7), Inches(5.3),
             "Evaluation & Q/A",
             ["Open for Viva Examination & Technical Evaluation.",
              "Developed for B.Voc (Bachelor of Vocation) Software Development.",
              "Team: Sayyed Mashhuda, Sidat Ibrahim, Patel Dhruvil."],
             font_body_size=20, font_title_size=25)

    # =========================================================================
    # SLIDES 21+: APPLICATION DEMONSTRATION & SCREENSHOTS SECTION
    # =========================================================================

    add_screenshot_slide(
        prs,
        "Customer Journey — Account & Security",
        "Authentication & Onboarding",
        ["Customers log in or create a new account securely.",
         "Password-protected credentials stored with Supabase Auth.",
         "Personalized profile profile data synced in real-time."],
        "shot_login.png",
        is_left_img=False
    )

    add_screenshot_slide(
        prs,
        "Customer Journey — Home & Location Search",
        "Interactive Dashboard",
        ["Explore parking locations across the city.",
         "View live hourly rates, ratings, distance, and nearby amenities.",
         "One-tap search and vehicle category filters (Car, Bike, EV)."],
        "media__1786547982017.png",
        is_left_img=False
    )

    add_screenshot_slide(
        prs,
        "Customer Journey — Slot Selection",
        "Floor-Wise Slot Selection Grid",
        ["Displays available slots organized floor-wise (Floor 1, Floor 2, Basement).",
         "Real-time database overlap check prevents double bookings.",
         "Customers pick exact slot number (e.g. 2nd Floor → Slot C-24)."],
        "media__1786551703078.png",
        is_left_img=False
    )

    add_screenshot_slide(
        prs,
        "Admin Panel — Multi-Floor Configuration",
        "Multi-Floor Setup & Allocation",
        ["Garage admins toggle multi-floor setup when creating a place.",
         "Specify number of floors and allocate Car, Bike, and EV capacity.",
         "System automatically generates individual floor-linked slots."],
        "media__1786550463774.png",
        is_left_img=False
    )

    add_screenshot_slide(
        prs,
        "Admin Panel — QR Pass Verification Scanner",
        "Digital Gate Check-In & Check-Out",
        ["High-speed camera QR code scanner for entry & exit validation.",
         "Calculates overstay duration and dynamic overtime fees.",
         "Fallback manual license plate lookup for fast access."],
        "media__1786548691237.png",
        is_left_img=False
    )

    add_screenshot_slide(
        prs,
        "Customer Journey — Booking Management & Refunds",
        "My Bookings & Cancellation System",
        ["View active and past bookings with QR ticket passes.",
         "Request cancellation and refund before check-in time.",
         "Receive real-time push notification updates on refund status."],
        "media__1786548190098.png",
        is_left_img=False
    )

    # =========================================================================
    # FINAL SLIDE: REFERENCES & TECHNOLOGIES USED
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
        
        # Mini tech card
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
    print(f"Presentation saved successfully with {len(prs.slides)} slides to: {pptx_path}")

if __name__ == "__main__":
    build_complete_presentation()
