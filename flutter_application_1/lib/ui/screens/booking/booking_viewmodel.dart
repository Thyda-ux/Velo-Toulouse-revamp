import 'package:flutter/material.dart';
import '../../../data/repositories/booking_repository.dart';
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

  bool isSubmitting = false;
  String? errorMessage;

  BookingViewModel({
    required this.station,
    required this.slot,
    required this.bike,
    BookingRepository? bookingRepo,
  }) : _bookingRepo = bookingRepo ?? FirebaseBookingRepository();

  /// Confirms the booking using the [userId] from the shared MyPassViewModel.
  /// 
  /// This uses a Firestore transaction to ensure that booking creation and slot
  /// update happen atomically. If either operation fails, both are rolled back.
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

      final id = await _bookingRepo.createBookingWithSlotUpdate(
        booking,
        station.id,
        slot,
      );

      isSubmitting = false;
      notifyListeners();
      return id;
    } catch (e) {
      isSubmitting = false;
      
      if (e.toString().contains('already been booked')) {
        errorMessage = 'This bike was just booked by another user. Please select a different bike.';
      } else if (e.toString().contains('Bike mismatch')) {
        errorMessage = 'The bike in this slot has changed. Please refresh and try again.';
      } else if (e.toString().contains('Slot not found')) {
        errorMessage = 'This slot no longer exists. Please refresh and try again.';
      } else {
        errorMessage = 'Failed to create booking. Please try again.';
      }
      
      notifyListeners();
      return null;
    }
  }
}
