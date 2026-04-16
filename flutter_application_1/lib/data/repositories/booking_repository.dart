import '../../models/booking.dart';

abstract class BookingRepository {
  Future<String> createBooking(Booking booking);
  Future<Booking?> getBooking(String bookingId);
}
