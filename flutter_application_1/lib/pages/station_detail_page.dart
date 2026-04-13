import 'package:flutter/material.dart';
import '../models/bike_station.dart';
import '../data/repositories/bike_station_repository.dart';

const _kOrange = Color(0xFFE8491B);
const _kGreen = Color(0xFF4CAF50);

class StationDetailPage extends StatefulWidget {
  final BikeStation station;

  const StationDetailPage({super.key, required this.station});

  @override
  State<StationDetailPage> createState() => _StationDetailPageState();
}

class _StationDetailPageState extends State<StationDetailPage> {
  int? _selectedSlotIndex;
  final _repo = BikeStationRepository();

  void _showNearbyStationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NearbyStationsSheet(repo: _repo),
    );
  }

  @override
  Widget build(BuildContext context) {
    final station = widget.station;
    final available = station.getAvailableBikes();
    final empty = station.getEmptySlots();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Back to map',
          style: TextStyle(
            color: _kOrange,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Station header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  station.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$available available · $empty slots empty',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Slot list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: station.slots.length,
              separatorBuilder: (_, _) => const Divider(
                height: 1,
                indent: 20,
                endIndent: 20,
              ),
              itemBuilder: (context, index) {
                final slot = station.slots[index];
                final hasBike = slot.hasBike();
                final isSelected = _selectedSlotIndex == index;

                return InkWell(
                  onTap: hasBike
                      ? () => setState(() => _selectedSlotIndex = index)
                      : null,
                  child: Container(
                    color: isSelected
                        ? _kOrange.withValues(alpha: 0.06)
                        : Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        // Slot icon
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: hasBike
                                ? _kOrange.withValues(alpha: 0.1)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? _kOrange
                                  : hasBike
                                      ? _kOrange.withValues(alpha: 0.3)
                                      : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              hasBike ? Icons.pedal_bike : Icons.remove,
                              size: 20,
                              color: hasBike ? _kOrange : Colors.grey[400],
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Slot info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Slot ${slot.slotNumber}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                hasBike
                                    ? 'Bike ${slot.bike!.code}'
                                    : 'Empty',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: hasBike
                                      ? Colors.grey[600]
                                      : Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: hasBike
                                ? _kGreen.withValues(alpha: 0.1)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            hasBike ? 'Available' : 'Empty',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: hasBike ? _kGreen : Colors.grey[400],
                            ),
                          ),
                        ),

                        // Radio indicator for selected
                        if (hasBike) ...[
                          const SizedBox(width: 10),
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: isSelected ? _kOrange : Colors.grey[300],
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Continue button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _selectedSlotIndex != null
                    ? () => _showNearbyStationsSheet(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kOrange,
                  disabledBackgroundColor: Colors.grey[300],
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.grey[500],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // Bottom navigation bar
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
          currentIndex: 0,
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

// Bottom modal sheet listing nearby stations to release a bike
class _NearbyStationsSheet extends StatefulWidget {
  final BikeStationRepository repo;

  const _NearbyStationsSheet({required this.repo});

  @override
  State<_NearbyStationsSheet> createState() => _NearbyStationsSheetState();
}

class _NearbyStationsSheetState extends State<_NearbyStationsSheet> {
  List<BikeStation>? _stations;

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    final stations = await widget.repo.getAllStations();
    setState(() => _stations = stations);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Nearby Stations',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _kOrange,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Station list
          if (_stations == null)
            const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: _kOrange),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: _stations!.length,
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                  color: Colors.grey[200],
                ),
                itemBuilder: (context, index) {
                  final station = _stations![index];
                  final available = station.getAvailableBikes();
                  final empty = station.getEmptySlots();

                  return InkWell(
                    onTap: () {
                      Navigator.pop(context); // close sheet
                      // Navigate to that station's detail
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              StationDetailPage(station: station),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
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
                                    Icon(Icons.pedal_bike,
                                        size: 14, color: Colors.grey[500]),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$available bikes',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(Icons.local_parking,
                                        size: 14, color: Colors.grey[500]),
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

                          Icon(Icons.chevron_right,
                              color: Colors.grey[400], size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
