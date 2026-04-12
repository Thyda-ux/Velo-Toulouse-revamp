import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/bike.dart';
import '../../models/bike_station.dart';
import '../../models/slot.dart';
import '../dtos/bike_dto.dart';
import '../dtos/bike_station_dto.dart';
import '../dtos/slot_dto.dart';

class BikeStationRepository {
  final _db = FirebaseFirestore.instance;

  // Get all stations with their slots loaded
  Future<List<BikeStation>> getAllStations() async {
    final result = await _db.collection('bikeStations').get();

    final stations = <BikeStation>[];
    for (final doc in result.docs) {
      final slots = await getSlotsForStation(doc.id);
      stations.add(BikeStationDTO.fromSnapshot(doc, slots: slots));
    }
    return stations;
  }

  // Get a single station by ID
  Future<BikeStation?> getStation(String stationId) async {
    final doc = await _db.collection('bikeStations').doc(stationId).get();
    if (!doc.exists) return null;

    final slots = await getSlotsForStation(stationId);
    return BikeStationDTO.fromSnapshot(doc, slots: slots);
  }

  // Listen to station changes in real-time
  Stream<List<BikeStation>> watchAllStations() {
    return _db.collection('bikeStations').snapshots().asyncMap((result) async {
      final stations = <BikeStation>[];
      for (final doc in result.docs) {
        final slots = await getSlotsForStation(doc.id);
        stations.add(BikeStationDTO.fromSnapshot(doc, slots: slots));
      }
      return stations;
    });
  }

  // Get all slots for a station (slots are stored as a subcollection)
  Future<List<Slot>> getSlotsForStation(String stationId) async {
    final result = await _db
        .collection('bikeStations')
        .doc(stationId)
        .collection('slots')
        .get();

    final slots = <Slot>[];
    for (final doc in result.docs) {
      final data = doc.data();
      Bike? bike;
      if (data['bikeId'] != null) {
        bike = await getBike(data['bikeId'] as String);
      }
      slots.add(SlotDTO.fromSnapshot(doc, bike: bike));
    }
    return slots;
  }

  // Update a slot within a station
  Future<void> updateSlot(String stationId, Slot slot) async {
    await _db
        .collection('bikeStations')
        .doc(stationId)
        .collection('slots')
        .doc(slot.id)
        .update(SlotDTO.toMap(slot));
  }

  // Get a single bike by ID
  Future<Bike?> getBike(String bikeId) async {
    final doc = await _db.collection('bikes').doc(bikeId).get();
    if (!doc.exists) return null;
    return BikeDTO.fromSnapshot(doc);
  }

  // Create a new bike
  Future<void> createBike(Bike bike) async {
    await _db.collection('bikes').doc(bike.id).set(BikeDTO.toMap(bike));
  }
}
