import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/bike.dart';
import '../../models/bike_station.dart';
import '../../models/slot.dart';
import '../dtos/bike_dto.dart';
import '../dtos/bike_station_dto.dart';
import '../dtos/slot_dto.dart';
import 'bike_station_repository.dart';

class FirebaseBikeStationRepository implements BikeStationRepository {
  final FirebaseFirestore _db;

  FirebaseBikeStationRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _stations =>
      _db.collection('bikeStations');

  CollectionReference<Map<String, dynamic>> _slotsOf(String stationId) =>
      _stations.doc(stationId).collection('slots');

  Future<BikeStation> _hydrate(
      DocumentSnapshot<Map<String, dynamic>> doc) async {
    final slots = await getSlotsForStation(doc.id);
    return BikeStationDTO.fromSnapshot(doc, slots: slots);
  }

  @override
  Future<List<BikeStation>> getAllStations() async {
    final result = await _stations.get();
    return Future.wait(result.docs.map(_hydrate));
  }

  @override
  Future<BikeStation?> getStation(String stationId) async {
    final doc = await _stations.doc(stationId).get();
    if (!doc.exists) return null;
    return _hydrate(doc);
  }

  @override
  Future<List<Slot>> getSlotsForStation(String stationId) async {
    final result = await _slotsOf(stationId).get();
    return Future.wait(result.docs.map((doc) async {
      final bikeId = doc.data()['bikeId'] as String?;
      final bike = bikeId != null ? await getBike(bikeId) : null;
      return SlotDTO.fromSnapshot(doc, bike: bike);
    }));
  }

  @override
  Future<void> updateSlot(String stationId, Slot slot) {
    return _slotsOf(stationId).doc(slot.id).update(SlotDTO.toMap(slot));
  }

  @override
  Future<Bike?> getBike(String bikeId) async {
    final doc = await _db.collection('bikes').doc(bikeId).get();
    if (!doc.exists) return null;
    return BikeDTO.fromSnapshot(doc);
  }
}
