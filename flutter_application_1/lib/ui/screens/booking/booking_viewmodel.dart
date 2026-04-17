import 'package:flutter/material.dart';
import '../../../data/repositories/bike_station_repository.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/firebase_bike_station_repository.dart';
import '../../../data/repositories/firebase_booking_repository.dart';
import '../../../models/bike.dart';
import '../../../models/bike_station.dart';
import '../../../models/booking.dart';
import '../../../models/enums.dart';
import '../../../models/slot.dart';

class BookingViewModel extends ChangeNotifier {
  final BikeStation station;
  final Slot slot;
  final Bike bike;

  final BookingRepository _bookingRepo;
  final BikeStationRepository _stationRepo;

  bool isSubmitting = false;
  String? errorMessage;

  BookingViewModel({
    required this.station,
    required this.slot,
    required this.bike,
    BookingRepository? bookingRepo,
    BikeStationRepository? stationRepo,
  })  : _bookingRepo = bookingRepo ?? FirebaseBookingRepository(),
        _stationRepo = stationRepo ?? FirebaseBikeStationRepository();

  /// Confirms the booking using the [userId] from the shared MyPassViewModel.
  Future<String?> confirmBooking(String userId) async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final orderId = 'ORD-${now.millisecondsSinceEpoch}';

      final booking = Booking(
        id: '',
        orderId: orderId,
        userId: userId,
        bikeId: bike.id,
        stationId: station.id,
        slotId: slot.id,
        bookingTime: now,
        status: BookingStatus.active,
      );

      final id = await _bookingRepo.createBooking(booking);

      final emptiedSlot = Slot(
        id: slot.id,
        slotNumber: slot.slotNumber,
        bike: null,
      );
      await _stationRepo.updateSlot(station.id, emptiedSlot);

      isSubmitting = false;
      notifyListeners();
      return id;
    } catch (e) {
      errorMessage = 'Failed to create booking. Please try again.';
      isSubmitting = false;
      notifyListeners();
      return null;
    }
  }
}
