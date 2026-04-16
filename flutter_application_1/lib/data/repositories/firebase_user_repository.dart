import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user.dart';
import '../../models/user_plan.dart';
import '../dtos/user_dto.dart';
import '../dtos/user_plan_dto.dart';
import 'user_repository.dart';

class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _db;

  FirebaseUserRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  @override
  Future<AppUser?> getUser(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    UserPlan? plan;
    if (data['activePlanId'] != null) {
      plan = await getUserPlan(data['activePlanId'] as String);
    }
    return UserDTO.fromSnapshot(doc, activePlan: plan);
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final result = await _db.collection('users').limit(1).get();
    if (result.docs.isEmpty) return null;
    final doc = result.docs.first;
    final data = doc.data();
    UserPlan? plan;
    if (data['activePlanId'] != null) {
      plan = await getUserPlan(data['activePlanId'] as String);
    }
    return UserDTO.fromSnapshot(doc, activePlan: plan);
  }

  @override
  Future<void> createUser(AppUser user) async {
    await _db.collection('users').doc(user.id).set(UserDTO.toMap(user));
  }

  @override
  Future<void> updateUser(AppUser user) async {
    await _db.collection('users').doc(user.id).update(UserDTO.toMap(user));
  }

  @override
  Future<UserPlan?> getUserPlan(String planId) async {
    final doc = await _db.collection('userPlans').doc(planId).get();
    if (!doc.exists) return null;
    return UserPlanDTO.fromSnapshot(doc);
  }

  @override
  Future<String> createUserPlan(UserPlan plan) async {
    final doc = await _db.collection('userPlans').add(UserPlanDTO.toMap(plan));
    return doc.id;
  }

  @override
  Future<void> assignPlanToUser(String userId, String planId) async {
    await _db.collection('users').doc(userId).update({
      'activePlanId': planId,
    });
  }
}
