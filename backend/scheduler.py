import os
import json
import uuid
from datetime import datetime, timezone, timedelta
from apscheduler.schedulers.background import BackgroundScheduler
import firebase_admin
from firebase_admin import credentials, messaging

# Attempt to initialize Firebase Admin SDK
firebase_initialized = False
try:
    cred_path = os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json')
    if os.path.exists(cred_path):
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
        firebase_initialized = True
        print("Firebase Admin SDK initialized successfully.")
    else:
        print("WARNING: serviceAccountKey.json not found! FCM notifications will be mocked.")
except Exception as e:
    print(f"Failed to initialize Firebase Admin SDK: {e}")

def get_fcm_token(supabase, user_id):
    try:
        res = supabase.table('profiles').select('fcm_token').eq('id', user_id).limit(1).execute()
        if res.data and len(res.data) > 0:
            return res.data[0].get('fcm_token')
    except Exception as e:
        print(f"Error fetching fcm token: {e}")
    return None

def send_push_notification(token, title, body, payload=None):
    if not token:
        return
    
    if firebase_initialized:
        try:
            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                data=payload if payload else {},
                token=token,
            )
            response = messaging.send(message)
            print(f"Successfully sent FCM message: {response}")
        except Exception as e:
            print(f"Error sending FCM message: {e}")
    else:
        print(f"[MOCK PUSH NOTIFICATION] To: {token} | Title: {title} | Body: {body}")

def insert_app_notification(supabase, user_id, booking_id, title, message, type):
    try:
        notif_data = {
            'id': str(uuid.uuid4()),
            'user_id': user_id,
            'booking_id': booking_id,
            'title': title,
            'message': message,
            'type': type,
            'is_read': False,
            'created_at': datetime.now(timezone.utc).isoformat()
        }
        supabase.table('notifications').insert(notif_data).execute()
    except Exception as e:
        print(f"Error inserting notification: {e}")

def check_and_send_reminders(supabase):
    if not supabase:
        return
    
    today_str = datetime.now().strftime('%Y-%m-%d')
    try:
        # Fetch active bookings for today
        res = supabase.table('bookings').select('*, parking_locations(*)').eq('booking_date', today_str).in_('status', ['pending', 'checked_in']).execute()
        bookings = res.data

        now_utc = datetime.now(timezone.utc)

        for b in bookings:
            start_str = b.get('scheduled_start_date_time')
            end_str = b.get('scheduled_end_date_time')
            if not start_str or not end_str:
                continue

            try:
                start_dt = datetime.fromisoformat(start_str.replace('Z', '+00:00'))
                end_dt = datetime.fromisoformat(end_str.replace('Z', '+00:00'))
            except:
                continue

            sent_flags = b.get('notifications_sent') or {}
            user_id = b.get('user_id')
            booking_id = b.get('id')
            status = b.get('status')
            
            # Safe dict for updates
            new_flags = dict(sent_flags)
            updated = False

            location_name = b.get('parking_locations', {}).get('name', 'your booked parking')
            start_time_str = b.get('start_time', '')
            end_time_str = b.get('end_time', '')

            # 1. Check-In Reminder (15 mins before)
            if not new_flags.get('15m_before_start') and status == 'pending':
                time_diff = (start_dt - now_utc).total_seconds() / 60
                if 0 < time_diff <= 15:
                    token = get_fcm_token(supabase, user_id)
                    title = "🔔 Parking Reminder"
                    body = f"Your parking slot at {location_name} starts in 15 minutes at {start_time_str}. Please arrive on time for check-in."
                    
                    send_push_notification(token, title, body)
                    insert_app_notification(supabase, user_id, booking_id, title, body, "reminder")
                    
                    new_flags['15m_before_start'] = True
                    updated = True

            # 2. Check-Out Reminder (15 mins before)
            if not new_flags.get('15m_before_end') and status in ('pending', 'checked_in'):
                time_diff = (end_dt - now_utc).total_seconds() / 60
                if 0 < time_diff <= 15:
                    token = get_fcm_token(supabase, user_id)
                    title = "🔔 Check-Out Reminder"
                    body = f"Your parking booking at {location_name} ends in 15 minutes at {end_time_str}. Please check out on time to avoid additional overtime charges."
                    
                    send_push_notification(token, title, body)
                    insert_app_notification(supabase, user_id, booking_id, title, body, "reminder")
                    
                    new_flags['15m_before_end'] = True
                    updated = True

            # 3. Overtime Alert
            if not new_flags.get('overtime_alert') and status == 'checked_in':
                time_diff = (now_utc - end_dt).total_seconds() / 60
                if time_diff > 0:
                    token = get_fcm_token(supabase, user_id)
                    title = "⚠️ Parking Time Exceeded"
                    body = "Your scheduled parking time has ended. Additional overtime charges may apply until you check out."
                    
                    send_push_notification(token, title, body)
                    insert_app_notification(supabase, user_id, booking_id, title, body, "alert")
                    
                    new_flags['overtime_alert'] = True
                    updated = True
            
            if updated:
                supabase.table('bookings').update({'notifications_sent': new_flags}).eq('id', booking_id).execute()

    except Exception as e:
        print(f"Scheduler Error: {e}")

def start_scheduler(supabase_client):
    scheduler = BackgroundScheduler()
    scheduler.add_job(check_and_send_reminders, 'interval', minutes=1, args=[supabase_client])
    scheduler.start()
    print("Background notification scheduler started.")
