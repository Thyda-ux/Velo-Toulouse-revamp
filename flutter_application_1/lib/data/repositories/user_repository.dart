import '../../models/user.dart';
import '../../models/user_plan.dart';

abstract class UserRepository {
  Future<AppUser?> getUser(String userId);
  Future<AppUser?> getCurrentUser();
  Future<void> createUser(AppUser user);
  Future<void> updateUser(AppUser user);
  Future<UserPlan?> getUserPlan(String planId);
  Future<String> createUserPlan(UserPlan plan);
  Future<void> assignPlanToUser(String userId, String planId);
}
