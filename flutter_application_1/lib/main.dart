import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/firestore_seeder.dart';
import 'firebase_options.dart';
import 'ui/screens/map/map_view.dart';
import 'ui/screens/map/map_viewmodel.dart';
import 'ui/screens/my_pass/my_pass_viewmodel.dart';

const bool _seedOnBoot = bool.fromEnvironment('SEED_FIRESTORE');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (_seedOnBoot) {
    await FirestoreSeeder().seed();
  }

  runApp(const VeloApp());
}

class VeloApp extends StatefulWidget {
  const VeloApp({super.key});

  @override
  State<VeloApp> createState() => _VeloAppState();
}

class _VeloAppState extends State<VeloApp> {
  late final MapViewModel _mapViewModel;
  late final MyPassViewModel _myPassViewModel;

  @override
  void initState() {
    super.initState();
    _mapViewModel = MapViewModel()..loadStations();
    _myPassViewModel = MyPassViewModel()..load();
  }

  @override
  void dispose() {
    _mapViewModel.dispose();
    _myPassViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MapViewModel>.value(value: _mapViewModel),
        ChangeNotifierProvider<MyPassViewModel>.value(value: _myPassViewModel),
      ],
      child: MaterialApp(
        title: 'Velo Phnom Penh',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const MapView(),
      ),
    );
  }
}
