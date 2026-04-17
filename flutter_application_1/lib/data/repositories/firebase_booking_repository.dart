import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/booking.dart';
import '../../models/slot.dart';
import '../dtos/booking_dto.dart';
import '../dtos/slot_dto.dart';
import 'booking_repository.dart';

class FirebaseBookingRepository implements BookingRepository {
  final FirebaseFirestore _db;

  FirebaseBookingRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _bookings =>
      _db.collection('bookings');

  @override
  Future<Booking?> getBooking(String bookingId) async {
    final doc = await _bookings.doc(bookingId).get();
    if (!doc.exists) return null;
    return BookingDTO.fromSnapshot(doc);
  }

  @override
  Future<String> createBookingWithSlotUpdate(
    Booking booking,
    String stationId,
    Slot slot,
  ) async {
    // Use a transaction to ensure booking creation and slot update are atomic
    return await _db.runTransaction<String>((transaction) async {
      // Reference to the slot document
      final slotRef = _db
          .collection('bikeStations')
          .doc(stationId)
          .collection('slots')
          .doc(slot.id);

      // Read the current slot to verify bike is still there
      final slotSnapshot = await transaction.get(slotRef);
      final slotData = slotSnapshot.data() as Map<String, dynamic>?;

      if (slotData == null) {
        throw Exception('Slot not found: ${slot.id}');
      }

      // Check if the slot is still occupied (bikeId not null)
      final currentBikeId = slotData['bikeId'] as String?;
      if (currentBikeId == null) {
        throw Exception(
            'Slot is empty - bike has already been booked by another user');
      }

      if (currentBikeId != booking.bikeId) {
        throw Exception(
            'Bike mismatch - the bike in this slot has changed. Please refresh and try again.');
      }

      // Create the booking document
      final bookingRef = _bookings.doc();
      transaction.set(bookingRef, BookingDTO.toMap(booking));

      // Clear the slot (set bikeId to null)
      final emptiedSlot = Slot(
        id: slot.id,
        slotNumber: slot.slotNumber,
        bike: null,
      );
      transaction.update(slotRef, SlotDTO.toMap(emptiedSlot));

      return bookingRef.id;
    });
  }
}
