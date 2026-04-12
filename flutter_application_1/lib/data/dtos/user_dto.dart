import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user.dart';
import '../../models/user_plan.dart';

class UserDTO {
  // Firestore document → AppUser model
  static AppUser fromMap(String id, Map<String, dynamic> map,
      {UserPlan? activePlan}) {
    return AppUser(
      id: id,
      name: map['name'] as String,
      activePlan: activePlan,
    );
  }

  // AppUser model → Firestore document
  static Map<String, dynamic> toMap(AppUser user) {
    return {
      'name': user.name,
      'activePlanId': user.activePlan?.id,
    };
  }

  // Shortcut: DocumentSnapshot → AppUser model
  static AppUser fromSnapshot(DocumentSnapshot doc,
      {UserPlan? activePlan}) {
    return fromMap(doc.id, doc.data() as Map<String, dynamic>,
        activePlan: activePlan);
  }
}
