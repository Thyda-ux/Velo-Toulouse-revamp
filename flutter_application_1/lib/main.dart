import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'data/firestore_seeder.dart';
import 'pages/map_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Clear old data and re-seed with updated bike codes (BXX format)
  // TODO: switch back to seed() once the re-seed is done
  await FirestoreSeeder().clearAndReseed();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velo Phnom Penh',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE8491B),
        ),
        useMaterial3: true,
      ),
      home: const MapPage(),
    );
  }
}
