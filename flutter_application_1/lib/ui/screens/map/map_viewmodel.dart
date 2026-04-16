import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/bike_station_repository.dart';
import '../../../data/repositories/firebase_bike_station_repository.dart';
import '../../../models/bike_station.dart';

class MapViewModel extends ChangeNotifier {
  final BikeStationRepository _repo;

  MapViewModel({BikeStationRepository? repo})
      : _repo = repo ?? FirebaseBikeStationRepository();

  List<BikeStation> stations = [];
  bool isLoading = true;
  String? errorMessage;

  Future<void> loadStations() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      stations = await _repo.getAllStations();
    } catch (_) {
      errorMessage = 'Could not load stations. Please try again.';
      stations = [];
    }
    isLoading = false;
    notifyListeners();
  }

  Color markerColor(BikeStation station) {
    final available = station.getAvailableBikes();
    if (available >= 7) return AppColors.green;
    if (available >= 3) return AppColors.yellow;
    if (available >= 1) return AppColors.red;
    return AppColors.grey;
  }
}
