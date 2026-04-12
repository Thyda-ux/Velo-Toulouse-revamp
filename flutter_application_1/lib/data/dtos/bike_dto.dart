import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/bike.dart';

class BikeDTO {
  // Firestore document → Bike model
  static Bike fromMap(String id, Map<String, dynamic> map) {
    return Bike(
      id: id,
      code: map['code'] as String,
    );
  }

  // Bike model → Firestore document
  static Map<String, dynamic> toMap(Bike bike) {
    return {
      'code': bike.code,
    };
  }

  // Shortcut: DocumentSnapshot → Bike model
  static Bike fromSnapshot(DocumentSnapshot doc) {
    return fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }
}
