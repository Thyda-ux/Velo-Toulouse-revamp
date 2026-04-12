import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/enums.dart';
import '../../models/user_plan.dart';

class UserPlanDTO {
  // Firestore document → UserPlan model
  static UserPlan fromMap(String id, Map<String, dynamic> map) {
    return UserPlan(
      id: id,
      type: PlanType.fromMap(map['type'] as String),
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
    );
  }

  // UserPlan model → Firestore document
  static Map<String, dynamic> toMap(UserPlan plan) {
    return {
      'type': plan.type.toMap(),
      'startDate': Timestamp.fromDate(plan.startDate),
      'endDate': Timestamp.fromDate(plan.endDate),
    };
  }

  // Shortcut: DocumentSnapshot → UserPlan model
  static UserPlan fromSnapshot(DocumentSnapshot doc) {
    return fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }
}
