import '../../models/bike.dart';
import '../../models/bike_station.dart';
import '../../models/slot.dart';
import 'bike_station_repository.dart';

class MockBikeStationRepository implements BikeStationRepository {
  final List<BikeStation> _stations = _buildFixture();

  @override
  Future<List<BikeStation>> getAllStations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_stations);
  }

  @override
  Future<BikeStation?> getStation(String stationId) async {
    return _stations.where((s) => s.id == stationId).firstOrNull;
  }

  @override
  Future<List<Slot>> getSlotsForStation(String stationId) async {
    final station = await getStation(stationId);
    return station?.slots ?? const [];
  }

  @override
  Future<void> updateSlot(String stationId, Slot slot) async {
    final index = _stations.indexWhere((s) => s.id == stationId);
    if (index == -1) return;
    final station = _stations[index];
    final newSlots = station.slots
        .map((existing) => existing.id == slot.id ? slot : existing)
        .toList();
    _stations[index] = BikeStation(
      id: station.id,
      name: station.name,
      latitude: station.latitude,
      longitude: station.longitude,
      address: station.address,
      totalSlots: station.totalSlots,
      slots: newSlots,
    );
  }

  @override
  Future<Bike?> getBike(String bikeId) async {
    for (final s in _stations) {
      for (final slot in s.slots) {
        if (slot.bike?.id == bikeId) return slot.bike;
      }
    }
    return null;
  }

  static List<BikeStation> _buildFixture() {
    return [
      BikeStation(
        id: 'st-1',
        name: 'Central Market',
        latitude: 11.5700,
        longitude: 104.9210,
        address: 'St. 126, Phnom Penh',
        totalSlots: 3,
        slots: [
          Slot(id: 'st-1-s1', slotNumber: 1, bike: Bike(id: 'b1', code: 'B01')),
          Slot(id: 'st-1-s2', slotNumber: 2, bike: Bike(id: 'b2', code: 'B02')),
          Slot(id: 'st-1-s3', slotNumber: 3),
        ],
      ),
      BikeStation(
        id: 'st-2',
        name: 'Wat Phnom',
        latitude: 11.5761,
        longitude: 104.9225,
        address: 'Street 96, Phnom Penh',
        totalSlots: 2,
        slots: [
          Slot(id: 'st-2-s1', slotNumber: 1, bike: Bike(id: 'b3', code: 'B03')),
          Slot(id: 'st-2-s2', slotNumber: 2),
        ],
      ),
    ];
  }
}
