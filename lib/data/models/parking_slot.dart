class ParkingSlot {
  final String id;
  final String locationId;
  final String slotNumber;
  final String slotType;
  final bool isActive;
  bool isAvailable;
  bool isSelected;

  ParkingSlot({
    required this.id,
    required this.locationId,
    required this.slotNumber,
    required this.slotType,
    required this.isActive,
    this.isAvailable = true,
    this.isSelected = false,
  });

  factory ParkingSlot.fromJson(Map<String, dynamic> json) {
    return ParkingSlot(
      id: json['id'] as String,
      locationId: json['location_id'] as String,
      slotNumber: json['slot_number'] as String,
      slotType: json['slot_type'] as String,
      isActive: json['is_active'] as bool? ?? true,
      isAvailable: json['is_available'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location_id': locationId,
      'slot_number': slotNumber,
      'slot_type': slotType,
      'is_active': isActive,
    };
  }

  ParkingSlot copyWith({bool? isAvailable, bool? isSelected}) {
    return ParkingSlot(
      id: id,
      locationId: locationId,
      slotNumber: slotNumber,
      slotType: slotType,
      isActive: isActive,
      isAvailable: isAvailable ?? this.isAvailable,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
