import 'bike.dart';

class Slot {
  final String id;
  final int slotNumber;
  final Bike? bike;

  Slot({
    required this.id,
    required this.slotNumber,
    this.bike,
  });

  bool isEmpty() => bike == null;

  bool hasBike() => bike != null;
}
