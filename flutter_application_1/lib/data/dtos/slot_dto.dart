import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/bike.dart';
import '../../models/slot.dart';

class SlotDTO {
  // Firestore document → Slot model
  static Slot fromMap(String id, Map<String, dynamic> map, {Bike? bike}) {
    return Slot(
      id: id,
      slotNumber: map['slotNumber'] as int,
      bike: bike,
    );
  }

  // Slot model → Firestore document
  static Map<String, dynamic> toMap(Slot slot) {
    return {
      'slotNumber': slot.slotNumber,
      'bikeId': slot.bike?.id,
    };
  }

  // Shortcut: DocumentSnapshot → Slot model
  static Slot fromSnapshot(DocumentSnapshot doc, {Bike? bike}) {
    return fromMap(doc.id, doc.data() as Map<String, dynamic>, bike: bike);
  }
}
