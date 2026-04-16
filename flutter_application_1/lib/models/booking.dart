import 'enums.dart';

class Booking {
  final String id;
  final String orderId;
  final String userId;
  final String bikeId;
  final String stationId;
  final String slotId;
  final DateTime bookingTime;
  final BookingStatus status;

  Booking({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.bikeId,
    required this.stationId,
    required this.slotId,
    required this.bookingTime,
    required this.status,
  });

  bool isActive() => status == BookingStatus.active;
}
