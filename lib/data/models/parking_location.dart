class ParkingLocation {
  final String id;
  final String name;
  final String address;
  final int totalSlots;
  final double pricePerHour;
  final String? imageUrl;
  final double? lat;
  final double? lng;
  final int? availableSlots;
  final double? rating;
  final List<String>? amenities;
  final String? googleMapsLink;

  ParkingLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.totalSlots,
    required this.pricePerHour,
    this.imageUrl,
    this.lat,
    this.lng,
    this.availableSlots,
    this.rating,
    this.amenities,
    this.googleMapsLink,
  });

  factory ParkingLocation.fromJson(Map<String, dynamic> json) {
    return ParkingLocation(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      totalSlots: json['total_slots'] as int,
      pricePerHour: (json['price_per_hour'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
      lat: json['lat'] != null ? (json['lat'] as num).toDouble() : null,
      lng: json['lng'] != null ? (json['lng'] as num).toDouble() : null,
      availableSlots: json['available_slots'] as int?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      amenities: json['amenities'] != null
          ? List<String>.from(json['amenities'] as List)
          : null,
      googleMapsLink: json['google_maps_link'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'total_slots': totalSlots,
      'price_per_hour': pricePerHour,
      'image_url': imageUrl,
      'lat': lat,
      'lng': lng,
      'rating': rating,
      'amenities': amenities,
      'google_maps_link': googleMapsLink,
    };
  }
}

