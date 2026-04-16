import '../../models/enums.dart';
import '../../models/user.dart';
import '../../models/user_plan.dart';
import 'user_repository.dart';

class MockUserRepository implements UserRepository {
  AppUser _currentUser = AppUser(
    id: 'mock-user',
    name: 'Test User',
    activePlan: UserPlan(
      id: 'mock-plan',
      type: PlanType.monthly,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
    ),
  );

  final Map<String, UserPlan> _plans = {};
  int _planSequence = 0;

  @override
  Future<AppUser?> getUser(String userId) async {
    if (userId != _currentUser.id) return null;
    return _currentUser;
  }

  @override
  Future<AppUser?> getCurrentUser() async => _currentUser;

  @override
  Future<void> createUser(AppUser user) async {
    _currentUser = user;
  }

  @override
  Future<void> updateUser(AppUser user) async {
    _currentUser = user;
  }

  @override
  Future<UserPlan?> getUserPlan(String planId) async => _plans[planId];

  @override
  Future<String> createUserPlan(UserPlan plan) async {
    final id = 'mock-plan-${++_planSequence}';
    _plans[id] = UserPlan(
      id: id,
      type: plan.type,
      startDate: plan.startDate,
      endDate: plan.endDate,
    );
    return id;
  }

  @override
  Future<void> assignPlanToUser(String userId, String planId) async {
    final plan = _plans[planId];
    if (plan == null) return;
    _currentUser = AppUser(
      id: _currentUser.id,
      name: _currentUser.name,
      activePlan: plan,
    );
  }
}
