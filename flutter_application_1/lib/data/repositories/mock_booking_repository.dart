import '../../models/booking.dart';
import '../../models/slot.dart';
import 'booking_repository.dart';

class MockBookingRepository implements BookingRepository {
  final Map<String, Booking> _store = {};
  int _sequence = 0;

  @override
  Future<Booking?> getBooking(String bookingId) async => _store[bookingId];

  @override
  Future<String> createBookingWithSlotUpdate(
    Booking booking,
    String stationId,
    Slot slot,
  ) async {
    // In mock, simulate the transactional behavior by validating the slot has a bike
    if (slot.bike == null) {
      throw Exception(
          'Slot is empty - bike has already been booked by another user');
    }

    // Create the booking
    final id = 'mock-bk-${++_sequence}';
    _store[id] = Booking(
      id: id,
      orderId: booking.orderId,
      userId: booking.userId,
      bikeId: booking.bikeId,
      stationId: booking.stationId,
      slotId: booking.slotId,
      bookingTime: booking.bookingTime,
      status: booking.status,
    );
    return id;
  }
}