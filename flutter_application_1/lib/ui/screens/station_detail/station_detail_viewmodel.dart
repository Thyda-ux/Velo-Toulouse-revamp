import 'package:flutter/material.dart';
import '../../../models/bike_station.dart';

class StationDetailViewModel extends ChangeNotifier {
  final BikeStation station;

  int? selectedSlotIndex;

  StationDetailViewModel({required this.station});

  bool get hasSelection => selectedSlotIndex != null;

  void selectSlot(int index) {
    selectedSlotIndex = index;
    notifyListeners();
  }
}
