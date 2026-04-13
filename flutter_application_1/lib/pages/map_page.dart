import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/repositories/bike_station_repository.dart';
import '../models/bike_station.dart';
import 'station_detail_page.dart';

const _kOrange = Color(0xFFE8491B);
const _kGreen = Color(0xFF4CAF50);
const _kYellow = Color(0xFFFFC107);
const _kRed = Color(0xFFE53935);
const _kGrey = Color(0xFF9E9E9E);

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final _repo = BikeStationRepository();
  final _mapController = MapController();
  List<BikeStation> _stations = [];
  bool _isLoading = true;
  int _currentNavIndex = 0;

  // Phnom Penh center
  static const _center = LatLng(11.5630, 104.9210);

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    final stations = await _repo.getAllStations();
    setState(() {
      _stations = stations;
      _isLoading = false;
    });
  }

  Color _markerColor(BikeStation station) {
    final available = station.getAvailableBikes();
    if (available >= 7) return _kGreen;
    if (available >= 3) return _kYellow;
    if (available >= 1) return _kRed;
    return _kGrey;
  }

  List<Marker> _buildMarkers() {
    return _stations.map((station) {
      final color = _markerColor(station);

      return Marker(
        point: LatLng(station.latitude, station.longitude),
        width: 36,
        height: 46,
        child: GestureDetector(
          onTap: () => _onStationTap(station),
          child: _MapPin(color: color),
        ),
      );
    }).toList();
  }

  void _onStationTap(BikeStation station) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StationDetailPage(station: station),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fullscreen map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 13.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.flutter_application_1',
              ),
              if (!_isLoading) MarkerLayer(markers: _buildMarkers()),
            ],
          ),

          // Loading indicator
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: _kOrange),
            ),

          // Draggable bottom sheet
          if (!_isLoading)
            DraggableScrollableSheet(
              initialChildSize: 0.32,
              minChildSize: 0.12,
              maxChildSize: 0.75,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
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
                      // Drag handle
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 10, bottom: 12),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // Title
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Find a Bike',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _kOrange,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // "Nearby Stations" header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Nearby Stations',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Station list
                      ..._stations.map((station) {
                        return Column(
                          children: [
                            _StationListTile(
                              station: station,
                              color: _markerColor(station),
                              onTap: () => _onStationTap(station),
                            ),
                            Divider(
                              height: 1,
                              indent: 20,
                              endIndent: 20,
                              color: Colors.grey[200],
                            ),
                          ],
                        );
                      }),

                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
        ],
      ),

      // Bottom navigation bar — Map, Plan, Profile
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: _kOrange,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          currentIndex: _currentNavIndex,
          onTap: (i) => setState(() => _currentNavIndex = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on_outlined),
              activeIcon: Icon(Icons.location_on),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.credit_card_outlined),
              activeIcon: Icon(Icons.credit_card),
              label: 'Plan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// Custom map pin marker (droplet/pin shape)
class _MapPin extends StatelessWidget {
  final Color color;

  const _MapPin({required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.pedal_bike,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
        // Pin tail
        CustomPaint(
          size: const Size(12, 10),
          painter: _PinTailPainter(color),
        ),
      ],
    );
  }
}

// Draws the triangle tail of the pin
class _PinTailPainter extends CustomPainter {
  final Color color;
  _PinTailPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Station list tile
class _StationListTile extends StatelessWidget {
  final BikeStation station;
  final Color color;
  final VoidCallback onTap;

  const _StationListTile({
    required this.station,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final available = station.getAvailableBikes();
    final empty = station.getEmptySlots();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // Color indicator dot
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),

            // Station name + info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.pedal_bike, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        '$available bikes',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.local_parking, size: 14,
                          color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        '$empty slots',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }
}
