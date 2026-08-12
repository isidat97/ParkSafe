import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../firebase_options.dart';
import '../../data/models/booking.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  Future<void> init() async {
    if (_initialized) return;

    try {
      // 1. Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // 2. Initialize Timezone data for scheduled local notifications
      tz.initializeTimeZones();

      // 3. Setup Flutter Local Notifications
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );

      // Create Android Notification Channel
      const androidChannel = AndroidNotificationChannel(
        'parksafe_channel',
        'ParkSafe Notifications',
        description: 'Important parking alerts, check-in and check-out reminders',
        importance: Importance.max,
      );

      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(androidChannel);
      }

      // 4. Firebase Messaging Setup
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      try {
        _fcmToken = await messaging.getToken();
        debugPrint('FCM Token: $_fcmToken');
      } catch (e) {
        debugPrint('Failed to get FCM token: $e');
      }

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Listen for foreground FCM messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notification = message.notification;
        if (notification != null) {
          showNotification(
            title: notification.title ?? 'ParkSafe Alert',
            body: notification.body ?? '',
            payload: message.data.toString(),
          );
        }
      });

      _initialized = true;
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  /// Displays an immediate local notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'parksafe_channel',
        'ParkSafe Notifications',
        channelDescription: 'Important parking alerts',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }
  }

  /// Requirement 5: Schedules Check-In (15m before start) and Check-Out (15m before end) Reminders
  Future<void> scheduleBookingReminders(Booking booking) async {
    try {
      final startDt = booking.scheduledStartDateTime;
      final endDt = booking.scheduledEndDateTime;
      final locationName = booking.location?.name ?? 'your booked parking';

      final bookingHash = booking.id.hashCode.abs();

      // 1. Check-In Reminder (15 minutes before booking start)
      if (startDt != null) {
        final checkInReminderTime = startDt.subtract(const Duration(minutes: 15));
        if (checkInReminderTime.isAfter(DateTime.now())) {
          final tzTime = tz.TZDateTime.from(checkInReminderTime, tz.local);
          await _localNotifications.zonedSchedule(
            bookingHash % 100000 + 1,
            '🅿️ Upcoming Parking Check-In',
            'Reminder: Your booking at $locationName starts at ${booking.startTime} (in 15 mins). Get ready to check in!',
            tzTime,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'parksafe_channel',
                'ParkSafe Notifications',
                importance: Importance.max,
                priority: Priority.high,
              ),
              iOS: DarwinNotificationDetails(),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
          debugPrint('Scheduled Check-In Reminder at $checkInReminderTime');
        }
      }

      // 2. Check-Out Reminder (15 minutes before booking end)
      if (endDt != null) {
        final checkOutReminderTime = endDt.subtract(const Duration(minutes: 15));
        if (checkOutReminderTime.isAfter(DateTime.now())) {
          final tzTime = tz.TZDateTime.from(checkOutReminderTime, tz.local);
          await _localNotifications.zonedSchedule(
            bookingHash % 100000 + 2,
            '⏰ Parking Duration Ending Soon',
            'Reminder: Your booking at $locationName ends at ${booking.endTime} (in 15 mins). Please return to your vehicle or extend your booking to avoid overtime charges!',
            tzTime,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'parksafe_channel',
                'ParkSafe Notifications',
                importance: Importance.max,
                priority: Priority.high,
              ),
              iOS: DarwinNotificationDetails(),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
          debugPrint('Scheduled Check-Out Reminder at $checkOutReminderTime');
        }
      }
    } catch (e) {
      debugPrint('Error scheduling booking reminders: $e');
    }
  }

  /// Cancels scheduled reminders for a specific booking
  Future<void> cancelBookingReminders(String bookingId) async {
    try {
      final bookingHash = bookingId.hashCode.abs();
      await _localNotifications.cancel(bookingHash % 100000 + 1);
      await _localNotifications.cancel(bookingHash % 100000 + 2);
    } catch (_) {}
  }
}
