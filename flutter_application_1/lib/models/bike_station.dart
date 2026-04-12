import 'slot.dart';

class BikeStation {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final int totalSlots;
  final List<Slot> slots;

  BikeStation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.totalSlots,
    this.slots = const [],
  });

  int getAvailableBikes() {
    return slots.where((s) => s.hasBike()).length;
  }

  int getEmptySlots() {
    return slots.where((s) => s.isEmpty()).length;
  }
}
