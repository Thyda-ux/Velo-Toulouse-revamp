import 'enums.dart';

class UserPlan {
  final String id;
  final PlanType type;
  final DateTime startDate;
  final DateTime endDate;

  UserPlan({
    required this.id,
    required this.type,
    required this.startDate,
    required this.endDate,
  });

  bool isValid() {
    return DateTime.now().isBefore(endDate);
  }

  int daysRemaining() {
    return endDate.difference(DateTime.now()).inDays;
  }
}
