class FeedbackModel {
  final String id;
  final String userId;
  final String? bookingId;
  final String? locationId;
  final int rating; // 1 to 5 stars
  final String? comments;
  final DateTime createdAt;

  FeedbackModel({
    required this.id,
    required this.userId,
    this.bookingId,
    this.locationId,
    required this.rating,
    this.comments,
    required this.createdAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      bookingId: json['booking_id'] as String?,
      locationId: json['location_id'] as String?,
      rating: (json['rating'] as num).toInt(),
      comments: json['comments'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'booking_id': bookingId,
      'location_id': locationId,
      'rating': rating,
      'comments': comments,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }
}
