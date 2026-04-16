import '../../models/bike.dart';
import '../../models/bike_station.dart';
import '../../models/slot.dart';

abstract class BikeStationRepository {
  Future<List<BikeStation>> getAllStations();
  Future<BikeStation?> getStation(String stationId);
  Future<List<Slot>> getSlotsForStation(String stationId);
  Future<void> updateSlot(String stationId, Slot slot);
  Future<Bike?> getBike(String bikeId);
}
