class AppConstants {
  // Supabase
  static const String supabaseUrl = 'https://pgmzyatqzqdtdbtxodez.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBnbXp5YXRxenFkdGRidHhvZGV6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY0MTgxMTQsImV4cCI6MjEwMTk5NDExNH0.Fa1o7NTj8Fg_qB56U7NEFlxuLTTR1pJdsdzvQ38X9EI';

  // Tables
  static const String tableProfiles = 'profiles';
  static const String tableParkingLocations = 'parking_locations';
  static const String tableParkingSlots = 'parking_slots';
  static const String tableBookings = 'bookings';

  // Slot Types
  static const String slotTypeCar = 'car';
  static const String slotTypeBike = 'bike';
  static const String slotTypeEV = 'ev';

  // Booking Status
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusCancelled = 'cancelled';
  static const String statusCompleted = 'completed';

  // Payment Status
  static const String paymentPending = 'pending';
  static const String paymentPaid = 'paid';
  static const String paymentFailed = 'failed';
  static const String paymentRefunded = 'refunded';

  // Prefs Keys
  static const String prefOnboardingDone = 'onboarding_done';
  static const String prefUserId = 'user_id';

  // App Info
  static const String appName = 'ParkSafe';
  static const String appVersion = '1.0.0';

  // Misc
  static const int minimumBookingHours = 1;
  static const int maximumBookingHours = 12;
}
