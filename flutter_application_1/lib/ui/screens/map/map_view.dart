import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/bike_station.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/bottom_sheet_handle.dart';
import '../../widgets/map_pin.dart';
import '../../widgets/station_list_tile.dart';
import '../my_pass/my_pass_view.dart';
import '../station_detail/station_detail_view.dart';
import 'map_viewmodel.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    // MapViewModel is provided at the app level via ChangeNotifierProvider.value
    return const _MapViewBody();
  }
}

class _MapViewBody extends StatefulWidget {
  const _MapViewBody();

  @override
  State<_MapViewBody> createState() => _MapViewBodyState();
}

class _MapViewBodyState extends State<_MapViewBody> {
  final _mapController = MapController();
  int _currentNavIndex = 0;

  static const _center = LatLng(11.5630, 104.9210);

  List<Marker> _buildMarkers(MapViewModel vm) {
    return vm.stations.map((station) {
      final color = vm.markerColor(station);
      return Marker(
        point: LatLng(station.latitude, station.longitude),
        width: 36,
        height: 46,
        child: GestureDetector(
          onTap: () => _navigateToStation(station),
          child: MapPin(color: color),
        ),
      );
    }).toList();
  }

  void _onNavTap(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MyPassView()),
      );
      return;
    }
    setState(() => _currentNavIndex = index);
  }

  void _navigateToStation(BikeStation station) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StationDetailView(station: station)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: _center,
                  initialZoom: 13.5,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.flutter_application_1',
                  ),
                  if (!vm.isLoading && vm.errorMessage == null)
                    MarkerLayer(markers: _buildMarkers(vm)),
                ],
              ),
              if (vm.isLoading)
                const Center(
                  child: CircularProgressIndicator(color: AppColors.orange),
                ),
              if (vm.errorMessage != null)
                _ErrorBanner(
                  message: vm.errorMessage!,
                  onRetry: vm.loadStations,
                ),
              if (!vm.isLoading && vm.errorMessage == null)
                DraggableScrollableSheet(
                  initialChildSize: 0.32,
                  minChildSize: 0.12,
                  maxChildSize: 0.75,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: ListView(
                        controller: scrollController,
                        padding: EdgeInsets.zero,
                        children: [
                          const BottomSheetHandle(),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl,
                            ),
                            child: Text(
                              'Find a Bike',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.orange,
                              ),
                            ),
                          ),
                          AppSpacing.gapLg,
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl,
                            ),
                            child: Text(
                              'Nearby Stations',
                              style: AppTextStyles.bodySm,
                            ),
                          ),
                          AppSpacing.gapSm,
                          ...vm.stations.map((station) {
                            return Column(
                              children: [
                                StationListTile(
                                  station: station,
                                  indicatorColor: vm.markerColor(station),
                                  onTap: () => _navigateToStation(station),
                                ),
                                const Divider(
                                  height: 1,
                                  indent: AppSpacing.xl,
                                  endIndent: AppSpacing.xl,
                                  color: AppColors.divider,
                                ),
                              ],
                            );
                          }),
                          AppSpacing.gapLg,
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
          bottomNavigationBar: AppBottomNavBar(
            currentIndex: _currentNavIndex,
            onTap: _onNavTap,
          ),
        );
      },
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        padding: AppSpacing.paddingLg,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.radiusLg,
          border: Border.all(color: AppColors.divider),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.red, size: 40),
            AppSpacing.gapMd,
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd,
            ),
            AppSpacing.gapLg,
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
