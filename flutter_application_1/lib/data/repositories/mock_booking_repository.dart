import '../../models/booking.dart';
import 'booking_repository.dart';

class MockBookingRepository implements BookingRepository {
  final Map<String, Booking> _store = {};
  int _sequence = 0;

  @override
  Future<String> createBooking(Booking booking) async {
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

  @override
  Future<Booking?> getBooking(String bookingId) async => _store[bookingId];
}
