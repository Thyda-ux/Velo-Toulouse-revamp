import '../../models/booking.dart';
import '../../models/slot.dart';

abstract class BookingRepository {
  Future<Booking?> getBooking(String bookingId);
  Future<String> createBookingWithSlotUpdate(
    Booking booking,
    String stationId,
    Slot slot,
  );
}
