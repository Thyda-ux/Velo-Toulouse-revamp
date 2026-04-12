import 'user_plan.dart';

class AppUser {
  final String id;
  final String name;
  final UserPlan? activePlan;

  AppUser({
    required this.id,
    required this.name,
    this.activePlan,
  });

  bool hasActivePlan() => activePlan != null && activePlan!.isValid();
}
