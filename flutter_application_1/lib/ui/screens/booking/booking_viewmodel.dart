import 'package:flutter/material.dart';
import '../../../data/repositories/bike_station_repository.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/firebase_bike_station_repository.dart';
import '../../../data/repositories/firebase_booking_repository.dart';
import '../../../data/repositories/firebase_user_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../models/bike.dart';
import '../../../models/bike_station.dart';
import '../../../models/booking.dart';
import '../../../models/enums.dart';
import '../../../models/slot.dart';
import '../../../models/user.dart';

class BookingViewModel extends ChangeNotifier {
  final BikeStation station;
  final Slot slot;
  final Bike bike;

  final UserRepository _userRepo;
  final BookingRepository _bookingRepo;
  final BikeStationRepository _stationRepo;

  AppUser? user;
  bool isLoading = true;
  bool isSubmitting = false;
  String? errorMessage;

  BookingViewModel({
    required this.station,
    required this.slot,
    required this.bike,
    UserRepository? userRepo,
    BookingRepository? bookingRepo,
    BikeStationRepository? stationRepo,
  })  : _userRepo = userRepo ?? FirebaseUserRepository(),
        _bookingRepo = bookingRepo ?? FirebaseBookingRepository(),
        _stationRepo = stationRepo ?? FirebaseBikeStationRepository();

  bool get hasActivePlan => user?.hasActivePlan() ?? false;

  Future<void> loadUser() async {
    user = await _userRepo.getCurrentUser();
    isLoading = false;
    notifyListeners();
  }

  Future<String?> confirmBooking() async {
    if (!hasActivePlan || user == null) return null;

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final orderId = 'ORD-${now.millisecondsSinceEpoch}';

      final booking = Booking(
        id: '',
        orderId: orderId,
        userId: user!.id,
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
