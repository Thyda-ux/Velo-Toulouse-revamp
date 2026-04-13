import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSeeder {
  final _db = FirebaseFirestore.instance;

  // Delete all documents in a collection (including subcollections for stations)
  Future<void> _clearCollection(String name) async {
    final docs = await _db.collection(name).get();
    for (final doc in docs.docs) {
      // If it's bikeStations, also delete the slots subcollection
      if (name == 'bikeStations') {
        final slots = await doc.reference.collection('slots').get();
        for (final slot in slots.docs) {
          await slot.reference.delete();
        }
      }
      await doc.reference.delete();
    }
  }

  // Wipe all collections and re-seed from scratch
  Future<void> clearAndReseed() async {
    await _clearCollection('bikes');
    await _clearCollection('bikeStations');
    await _clearCollection('users');
    await _clearCollection('userPlans');
    await seed(force: true);
  }

  // Run this once to create all collections with sample data
  Future<void> seed({bool force = false}) async {
    if (!force) {
      final stations = await _db.collection('bikeStations').limit(1).get();
      if (stations.docs.isNotEmpty) {
        return;
      }
    }

    // 1. Create bikes
    final bikeIds = <String>[];
    for (int i = 1; i <= 40; i++) {
      final doc = await _db.collection('bikes').add({
        'code': 'B${i.toString().padLeft(2, '0')}',
      });
      bikeIds.add(doc.id);
    }

    // 2. Create bike stations with different availability levels
    final stationsData = [
      // Green stations (7-10 available bikes)
      {
        'name': 'Central Market',
        'latitude': 11.5700,
        'longitude': 104.9210,
        'address': 'St. 126, Phnom Penh',
        'totalSlots': 12,
        'bikesAvailable': 10,
      },
      {
        'name': 'Wat Phnom',
        'latitude': 11.5761,
        'longitude': 104.9225,
        'address': 'Street 96, Phnom Penh',
        'totalSlots': 10,
        'bikesAvailable': 8,
      },
      {
        'name': 'Riverside Park',
        'latitude': 11.5680,
        'longitude': 104.9310,
        'address': 'Sisowath Quay, Phnom Penh',
        'totalSlots': 10,
        'bikesAvailable': 7,
      },
      // Yellow stations (3-6 available bikes)
      {
        'name': 'Independence Monument',
        'latitude': 11.5565,
        'longitude': 104.9282,
        'address': 'Norodom Blvd, Phnom Penh',
        'totalSlots': 8,
        'bikesAvailable': 6,
      },
      {
        'name': 'Royal Palace',
        'latitude': 11.5637,
        'longitude': 104.9310,
        'address': 'Samdach Sothearos Blvd, Phnom Penh',
        'totalSlots': 8,
        'bikesAvailable': 4,
      },
      {
        'name': 'Toul Tom Poung Market',
        'latitude': 11.5490,
        'longitude': 104.9220,
        'address': 'St. 163, Phnom Penh',
        'totalSlots': 6,
        'bikesAvailable': 3,
      },
      // Red stations (1-2 available bikes)
      {
        'name': 'Olympic Stadium',
        'latitude': 11.5585,
        'longitude': 104.9115,
        'address': 'Charles de Gaulle Blvd, Phnom Penh',
        'totalSlots': 6,
        'bikesAvailable': 2,
      },
      {
        'name': 'Tuol Sleng Museum',
        'latitude': 11.5494,
        'longitude': 104.9175,
        'address': 'St. 113, Phnom Penh',
        'totalSlots': 5,
        'bikesAvailable': 1,
      },
      // Grey stations (0 available bikes)
      {
        'name': 'Chroy Changvar Bridge',
        'latitude': 11.5830,
        'longitude': 104.9340,
        'address': 'Chroy Changvar, Phnom Penh',
        'totalSlots': 6,
        'bikesAvailable': 0,
      },
      {
        'name': 'Aeon Mall',
        'latitude': 11.5460,
        'longitude': 104.8955,
        'address': 'Sothearos Blvd, Phnom Penh',
        'totalSlots': 8,
        'bikesAvailable': 0,
      },
    ];

    int bikeIndex = 0;
    for (final data in stationsData) {
      final bikesAvailable = data['bikesAvailable'] as int;
      final totalSlots = data['totalSlots'] as int;

      final stationDoc = await _db.collection('bikeStations').add({
        'name': data['name'],
        'latitude': data['latitude'],
        'longitude': data['longitude'],
        'address': data['address'],
        'totalSlots': totalSlots,
      });

      for (int i = 1; i <= totalSlots; i++) {
        final hasBike = i <= bikesAvailable && bikeIndex < bikeIds.length;
        await stationDoc.collection('slots').add({
          'slotNumber': i,
          'bikeId': hasBike ? bikeIds[bikeIndex++] : null,
        });
      }
    }

    // 3. Create a sample user with a monthly plan
    final planDoc = await _db.collection('userPlans').add({
      'type': 'monthly',
      'startDate': Timestamp.fromDate(DateTime.now()),
      'endDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
    });

    await _db.collection('users').add({
      'name': 'Test User',
      'activePlanId': planDoc.id,
    });
  }
}
