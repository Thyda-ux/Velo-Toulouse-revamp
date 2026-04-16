import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/booking.dart';
import '../dtos/booking_dto.dart';
import 'booking_repository.dart';

class FirebaseBookingRepository implements BookingRepository {
  final FirebaseFirestore _db;

  FirebaseBookingRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _bookings =>
      _db.collection('bookings');

  @override
  Future<String> createBooking(Booking booking) async {
    final doc = await _bookings.add(BookingDTO.toMap(booking));
    return doc.id;
  }

  @override
  Future<Booking?> getBooking(String bookingId) async {
    final doc = await _bookings.doc(bookingId).get();
    if (!doc.exists) return null;
    return BookingDTO.fromSnapshot(doc);
  }
}
