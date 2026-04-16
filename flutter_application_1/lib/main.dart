import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'data/firestore_seeder.dart';
import 'firebase_options.dart';
import 'ui/screens/map/map_view.dart';

const bool _seedOnBoot = bool.fromEnvironment('SEED_FIRESTORE');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (_seedOnBoot) {
    await FirestoreSeeder().seed();
  }

  runApp(const VeloApp());
}

class VeloApp extends StatelessWidget {
  const VeloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velo Phnom Penh',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const MapView(),
    );
  }
}
