import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/bike_station.dart';
import '../../models/slot.dart';

class BikeStationDTO {
  // Firestore document → BikeStation model
  static BikeStation fromMap(String id, Map<String, dynamic> map,
      {List<Slot> slots = const []}) {
    return BikeStation(
      id: id,
      name: map['name'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      address: map['address'] as String,
      totalSlots: map['totalSlots'] as int,
      slots: slots,
    );
  }

  // BikeStation model → Firestore document
  static Map<String, dynamic> toMap(BikeStation station) {
    return {
      'name': station.name,
      'latitude': station.latitude,
      'longitude': station.longitude,
      'address': station.address,
      'totalSlots': station.totalSlots,
    };
  }

  // Shortcut: DocumentSnapshot → BikeStation model
  static BikeStation fromSnapshot(DocumentSnapshot doc,
      {List<Slot> slots = const []}) {
    return fromMap(doc.id, doc.data() as Map<String, dynamic>, slots: slots);
  }
}
