import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/bike.dart';
import '../../../models/bike_station.dart';
import '../../../models/enums.dart';
import '../../../models/slot.dart';
import '../../../models/user.dart';
import '../my_pass/my_pass_viewmodel.dart';
import '../pass_selection/pass_selection_view.dart';
import 'booking_viewmodel.dart';

class BookingView extends StatelessWidget {
  final BikeStation station;
  final Slot slot;
  final Bike bike;

  const BookingView({
    super.key,
    required this.station,
    required this.slot,
    required this.bike,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          BookingViewModel(station: station, slot: slot, bike: bike),
      child: _BookingBody(station: station, slot: slot, bike: bike),
    );
  }
}

class _BookingBody extends StatelessWidget {
  final BikeStation station;
  final Slot slot;
  final Bike bike;

  const _BookingBody({
    required this.station,
    required this.slot,
    required this.bike,
  });

  Future<void> _onConfirm(
    BuildContext context,
    BookingViewModel vm,
    MyPassViewModel passVm,
  ) async {
    final userId = passVm.user?.id;
    if (userId == null) return;

    final orderId = await vm.confirmBooking(userId);
    if (!context.mounted) return;

    if (orderId != null) {
      await showDialog(
        context: context,
        builder: (_) => _BookingSuccessDialog(
          bikeCode: bike.code,
          stationName: station.name,
        ),
      );
      if (!context.mounted) return;
      Navigator.of(context)
        ..pop()
        ..pop();
    } else if (vm.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(vm.errorMessage!)));
    }
  }

  Future<void> _onBuyPass(BuildContext context, MyPassViewModel passVm) async {
    if (passVm.user == null) return;
    final purchased = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PassSelectionView(userId: passVm.user!.id),
      ),
    );
    if (purchased == true) {
      await passVm.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final passVm = context.watch<MyPassViewModel>();

    return Consumer<BookingViewModel>(
      builder: (context, vm, _) {
        final hasActivePlan = passVm.hasActivePlan;
        final user = passVm.user;

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Confirm Booking',
              style: TextStyle(
                color: AppColors.orange,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            titleSpacing: 0,
          ),
          body: passVm.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.orange),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: AppSpacing.lg,
                        ),
                        children: [
                          const Text(
                            'Booking Summary',
                            style: AppTextStyles.headingLg,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          const Text(
                            'Review your selection before confirming',
                            style: AppTextStyles.bodySm,
                          ),
                          AppSpacing.gapXl,
                          _InfoCard(
                            icon: Icons.pedal_bike,
                            label: 'Bike',
                            title: bike.code,
                            subtitle: 'Slot ${slot.slotNumber}',
                          ),
                          AppSpacing.gapMd,
                          _InfoCard(
                            icon: Icons.location_on,
                            label: 'Pickup Station',
                            title: station.name,
                            subtitle: station.address,
                          ),
                          AppSpacing.gapMd,
                          _InfoCard(
                            icon: Icons.access_time,
                            label: 'Booking Time',
                            title: _formatTime(DateTime.now()),
                            subtitle: 'Starts immediately on confirmation',
                          ),
                          AppSpacing.gapXl,
                          const Text('Your Pass', style: AppTextStyles.titleMd),
                          AppSpacing.gapMd,
                          if (hasActivePlan)
                            _PlanActiveCard(user: user!)
                          else
                            _NoPlanCard(
                              onBuyPass: () => _onBuyPass(context, passVm),
                            ),
                        ],
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
                        onPressed: hasActivePlan && !vm.isSubmitting
                            ? () => _onConfirm(context, vm, passVm)
                            : null,
                        child: vm.isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                hasActivePlan
                                    ? 'Confirm Booking'
                                    : 'Active Pass Required',
                              ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '${t.day}/${t.month}/${t.year} · $h:$m';
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String title;
  final String subtitle;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppSpacing.radiusMd,
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.1),
              borderRadius: AppSpacing.radiusSm,
            ),
            child: Icon(icon, color: AppColors.orange, size: 20),
          ),
          const SizedBox(width: AppSpacing.md + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(title, style: AppTextStyles.titleMd),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.bodySm),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanActiveCard extends StatelessWidget {
  final AppUser user;

  const _PlanActiveCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final plan = user.activePlan!;
    final daysLeft = plan.daysRemaining();
    final typeLabel = switch (plan.type) {
      PlanType.daily => 'Daily',
      PlanType.monthly => 'Monthly',
      PlanType.annual => 'Annual',
    };

    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.08),
        borderRadius: AppSpacing.radiusMd,
        border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 22),
          ),
          const SizedBox(width: AppSpacing.md + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$typeLabel Pass · Active', style: AppTextStyles.titleMd),
                const SizedBox(height: 2),
                Text('$daysLeft days remaining', style: AppTextStyles.bodySm),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoPlanCard extends StatelessWidget {
  final VoidCallback onBuyPass;

  const _NoPlanCard({required this.onBuyPass});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.06),
        borderRadius: AppSpacing.radiusMd,
        border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.red,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No Active Pass',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.red,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      'You need an active daily, monthly, or annual pass to book a bike.',
                      style: AppTextStyles.bodySm,
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.gapMd,
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onBuyPass,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.orange,
                side: const BorderSide(color: AppColors.orange),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppSpacing.radiusMd,
                ),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
              child: const Text('Buy a Pass'),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingSuccessDialog extends StatelessWidget {
  final String bikeCode;
  final String stationName;

  const _BookingSuccessDialog({
    required this.bikeCode,
    required this.stationName,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppSpacing.radiusLg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 36),
            ),
            AppSpacing.gapLg,
            const Text('Booking Confirmed', style: AppTextStyles.headingMd),
            AppSpacing.gapSm,
            Text(
              'Bike $bikeCode is reserved for you at $stationName.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySm,
            ),
            AppSpacing.gapLg,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
