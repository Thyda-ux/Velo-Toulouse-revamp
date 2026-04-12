import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user.dart';
import '../../models/user_plan.dart';
import '../dtos/user_dto.dart';
import '../dtos/user_plan_dto.dart';

class UserRepository {
  final _db = FirebaseFirestore.instance;

  // Get a user by their ID
  Future<AppUser?> getUser(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return null;

    // If the user has a plan, fetch it too
    final data = doc.data() as Map<String, dynamic>;
    UserPlan? plan;
    if (data['activePlanId'] != null) {
      plan = await getUserPlan(data['activePlanId'] as String);
    }

    return UserDTO.fromSnapshot(doc, activePlan: plan);
  }

  // Create a new user
  Future<void> createUser(AppUser user) async {
    await _db.collection('users').doc(user.id).set(UserDTO.toMap(user));
  }

  // Update an existing user
  Future<void> updateUser(AppUser user) async {
    await _db.collection('users').doc(user.id).update(UserDTO.toMap(user));
  }

  // Get a plan by its ID
  Future<UserPlan?> getUserPlan(String planId) async {
    final doc = await _db.collection('userPlans').doc(planId).get();
    if (!doc.exists) return null;
    return UserPlanDTO.fromSnapshot(doc);
  }

  // Create a new plan and return its auto-generated ID
  Future<String> createUserPlan(UserPlan plan) async {
    final doc = await _db.collection('userPlans').add(UserPlanDTO.toMap(plan));
    return doc.id;
  }

  // Link a plan to a user
  Future<void> assignPlanToUser(String userId, String planId) async {
    await _db.collection('users').doc(userId).update({
      'activePlanId': planId,
    });
  }
}
