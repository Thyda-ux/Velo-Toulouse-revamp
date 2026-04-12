import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/booking.dart';
import '../../models/enums.dart';
import '../dtos/booking_dto.dart';

class BookingRepository {
  final _db = FirebaseFirestore.instance;

  // Create a new booking and return its auto-generated ID
  Future<String> createBooking(Booking booking) async {
    final doc = await _db.collection('bookings').add(BookingDTO.toMap(booking));
    return doc.id;
  }

  // Get a single booking by ID
  Future<Booking?> getBooking(String bookingId) async {
    final doc = await _db.collection('bookings').doc(bookingId).get();
    if (!doc.exists) return null;
    return BookingDTO.fromSnapshot(doc);
  }

  // Find the current active booking for a user (if any)
  Future<Booking?> getActiveBookingForUser(String userId) async {
    final result = await _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: BookingStatus.active.toMap())
        .limit(1)
        .get();

    if (result.docs.isEmpty) return null;
    return BookingDTO.fromSnapshot(result.docs.first);
  }

  // Get all bookings for a user, newest first
  Future<List<Booking>> getBookingsForUser(String userId) async {
    final result = await _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('bookingTime', descending: true)
        .get();

    return result.docs.map((doc) => BookingDTO.fromSnapshot(doc)).toList();
  }

  // Update the status of a booking
  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': status.toMap(),
    });
  }

  // Cancel a booking
  Future<void> cancelBooking(String bookingId) async {
    await updateBookingStatus(bookingId, BookingStatus.cancelled);
  }
}
