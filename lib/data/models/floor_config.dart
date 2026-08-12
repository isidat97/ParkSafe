class FloorConfig {
  String floorName;
  int carSlots;
  int bikeSlots;
  int evSlots;

  FloorConfig({
    required this.floorName,
    this.carSlots = 0,
    this.bikeSlots = 0,
    this.evSlots = 0,
  });

  int get totalSlots => carSlots + bikeSlots + evSlots;
}
