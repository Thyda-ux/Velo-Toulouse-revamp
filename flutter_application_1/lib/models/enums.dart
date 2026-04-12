enum BookingStatus {
  pending,
  active,
  completed,
  cancelled;

  String toMap() => name;

  static BookingStatus fromMap(String value) =>
      BookingStatus.values.firstWhere((e) => e.name == value);
}

enum PlanType {
  daily,
  monthly,
  annual;

  String toMap() => name;

  static PlanType fromMap(String value) =>
      PlanType.values.firstWhere((e) => e.name == value);
}
