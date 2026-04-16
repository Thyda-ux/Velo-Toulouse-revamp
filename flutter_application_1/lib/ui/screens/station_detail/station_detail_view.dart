import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/bike_station.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../booking/booking_view.dart';
import 'station_detail_viewmodel.dart';

class StationDetailView extends StatefulWidget {
  final BikeStation station;

  const StationDetailView({super.key, required this.station});

  @override
  State<StationDetailView> createState() => _StationDetailViewState();
}

class _StationDetailViewState extends State<StationDetailView> {
  late final StationDetailViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = StationDetailViewModel(station: widget.station);
    _vm.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _vm.removeListener(_onViewModelChanged);
    _vm.dispose();
    super.dispose();
  }

  void _onViewModelChanged() => setState(() {});

  void _navigateToBooking(BuildContext context) {
    final index = _vm.selectedSlotIndex!;
    final slot = _vm.station.slots[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingView(
          station: _vm.station,
          slot: slot,
          bike: slot.bike!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final station = _vm.station;
    final available = station.getAvailableBikes();
    final empty = station.getEmptySlots();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Back to map',
          style: TextStyle(
            color: AppColors.orange,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(station.name, style: AppTextStyles.headingLg),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$available available · $empty slots empty',
                  style: AppTextStyles.bodySm,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              itemCount: station.slots.length,
              separatorBuilder: (_, _) => const Divider(
                height: 1,
                indent: AppSpacing.xl,
                endIndent: AppSpacing.xl,
                color: AppColors.divider,
              ),
              itemBuilder: (context, index) {
                final slot = station.slots[index];
                final hasBike = slot.hasBike();
                final isSelected = _vm.selectedSlotIndex == index;

                return InkWell(
                  onTap: hasBike ? () => _vm.selectSlot(index) : null,
                  child: Container(
                    color: isSelected
                        ? AppColors.orange.withValues(alpha: 0.06)
                        : Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md + 2,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: hasBike
                                ? AppColors.orange.withValues(alpha: 0.1)
                                : AppColors.background,
                            borderRadius: AppSpacing.radiusSm,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.orange
                                  : hasBike
                                      ? AppColors.orange
                                          .withValues(alpha: 0.3)
                                      : AppColors.divider,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              hasBike ? Icons.pedal_bike : Icons.remove,
                              size: 20,
                              color:
                                  hasBike ? AppColors.orange : AppColors.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md + 2),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Slot ${slot.slotNumber}',
                                style: AppTextStyles.titleMd,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                hasBike ? 'Bike ${slot.bike!.code}' : 'Empty',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm + 2,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: hasBike
                                ? AppColors.green.withValues(alpha: 0.1)
                                : AppColors.background,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12)),
                          ),
                          child: Text(
                            hasBike ? 'Available' : 'Empty',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: hasBike
                                  ? AppColors.green
                                  : AppColors.textMuted,
                            ),
                          ),
                        ),
                        if (hasBike) ...[
                          const SizedBox(width: AppSpacing.sm + 2),
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color:
                                isSelected ? AppColors.orange : AppColors.divider,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: ElevatedButton(
              onPressed: _vm.hasSelection
                  ? () => _navigateToBooking(context)
                  : null,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }
}
