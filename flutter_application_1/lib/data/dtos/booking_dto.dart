import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/booking.dart';
import '../../models/enums.dart';

class BookingDTO {
  // Firestore document → Booking model
  static Booking fromMap(String id, Map<String, dynamic> map) {
    return Booking(
      id: id,
      orderId: map['orderId'] as String,
      bikeId: map['bikeId'] as String,
      stationId: map['stationId'] as String,
      slotId: map['slotId'] as String,
      bookingTime: (map['bookingTime'] as Timestamp).toDate(),
      status: BookingStatus.fromMap(map['status'] as String),
    );
  }

  // Booking model → Firestore document
  static Map<String, dynamic> toMap(Booking booking) {
    return {
      'orderId': booking.orderId,
      'bikeId': booking.bikeId,
      'stationId': booking.stationId,
      'slotId': booking.slotId,
      'bookingTime': Timestamp.fromDate(booking.bookingTime),
      'status': booking.status.toMap(),
    };
  }

  // Shortcut: DocumentSnapshot → Booking model
  static Booking fromSnapshot(DocumentSnapshot doc) {
    return fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }
}
