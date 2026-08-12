import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';


class AppHelpers {
  static String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  static String formatDate(DateTime date) {
    return DateFormat('EEE, dd MMM yyyy').format(date);
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatTime(String time) {
    // time is HH:mm:ss from Supabase
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final dt = DateTime(2000, 1, 1, hour, minute);
    return DateFormat('hh:mm a').format(dt);
  }

  static String formatTimeFromDateTime(DateTime dt) {
    return DateFormat('hh:mm a').format(dt);
  }

  static String formatDuration(double hours) {
    if (hours < 1) {
      return '${(hours * 60).toInt()} mins';
    } else if (hours == hours.truncateToDouble()) {
      return '${hours.toInt()} hr${hours > 1 ? 's' : ''}';
    } else {
      final h = hours.truncate();
      final m = ((hours - h) * 60).round();
      return '${h}h ${m}m';
    }
  }

  static double calculateHours(DateTime start, DateTime end) {
    final diff = end.difference(start);
    return diff.inMinutes / 60.0;
  }

  static String generateBookingId() {
    final now = DateTime.now();
    return 'PS${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.millisecondsSinceEpoch.toString().substring(7)}';
  }

  static String timeToString(DateTime dt) {
    return DateFormat('HH:mm:ss').format(dt);
  }

  static String getSlotTypeLabel(String type) {
    switch (type) {
      case 'car':
        return 'Car';
      case 'bike':
        return 'Bike';
      case 'ev':
        return 'EV';
      default:
        return type.toUpperCase();
    }
  }

  static String getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'cancelled':
        return 'Cancelled';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }

  /// Validates standard Indian Vehicle Number format:
  /// 2 Alphabets + 2 Numbers + 2 Alphabets + 4 Numbers (e.g. MH 12 AB 1234 or MH12AB1234)
  static bool isValidVehicleNumber(String vehicleNumber) {
    final clean = vehicleNumber.replaceAll(' ', '').toUpperCase();
    final regExp = RegExp(r'^[A-Z]{2}[0-9]{2}[A-Z]{2}[0-9]{4}$');
    return regExp.hasMatch(clean);
  }

  /// Opens Google Maps for navigation using the saved link or falls back to query/coords
  static Future<void> openGoogleMaps({
    String? googleMapsLink,
    required String locationName,
    required String locationAddress,
    double? lat,
    double? lng,
  }) async {
    String urlString;
    if (googleMapsLink != null && googleMapsLink.trim().isNotEmpty) {
      urlString = googleMapsLink.trim();
    } else if (lat != null && lng != null && lat != 0 && lng != 0) {
      urlString = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    } else {
      final query = Uri.encodeComponent('$locationName, $locationAddress');
      urlString = 'https://www.google.com/maps/search/?api=1&query=$query';
    }

    final Uri uri = Uri.parse(urlString);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }
}

/// Automatically converts input text to UPPERCASE as user types
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

