class RecommendationResult {
  final String locationId;
  final String name;
  final String address;
  final double distanceKm;
  final int etaMinutes;
  final int totalSlots;
  final int freeSlots;
  final int availabilityPercentage;
  final double availabilityScore;
  final double distanceScore;
  final double finalScore;
  final double pricePerHour;
  final String? googleMapsLink;
  final double? rating;
  final String? imageUrl;

  RecommendationResult({
    required this.locationId,
    required this.name,
    required this.address,
    required this.distanceKm,
    required this.etaMinutes,
    required this.totalSlots,
    required this.freeSlots,
    required this.availabilityPercentage,
    required this.availabilityScore,
    required this.distanceScore,
    required this.finalScore,
    required this.pricePerHour,
    this.googleMapsLink,
    this.rating,
    this.imageUrl,
  });

  factory RecommendationResult.fromJson(Map<String, dynamic> json) {
    return RecommendationResult(
      locationId: json['location_id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      distanceKm: (json['distance_km'] as num).toDouble(),
      etaMinutes: json['eta_minutes'] as int,
      totalSlots: json['total_slots'] as int,
      freeSlots: json['free_slots'] as int,
      availabilityPercentage: json['availability_percentage'] as int,
      availabilityScore: (json['availability_score'] as num).toDouble(),
      distanceScore: (json['distance_score'] as num).toDouble(),
      finalScore: (json['final_score'] as num).toDouble(),
      pricePerHour: (json['price_per_hour'] as num).toDouble(),
      googleMapsLink: json['google_maps_link'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      imageUrl: json['image_url'] as String?,
    );
  }
}
