import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/bike.dart';
import '../../../models/bike_station.dart';
import '../../../models/enums.dart';
import '../../../models/slot.dart';
import '../../../models/user.dart';
import '../pass_selection/pass_selection_view.dart';
import 'booking_viewmodel.dart';

class BookingView extends StatefulWidget {
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
  State<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView> {
  late final BookingViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = BookingViewModel(
      station: widget.station,
      slot: widget.slot,
      bike: widget.bike,
    );
    _vm.addListener(_onChanged);
    _vm.loadUser();
  }

  @override
  void dispose() {
    _vm.removeListener(_onChanged);
    _vm.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  Future<void> _onConfirm() async {
    final orderId = await _vm.confirmBooking();
    if (!mounted) return;

    if (orderId != null) {
      await showDialog(
        context: context,
        builder: (_) => _BookingSuccessDialog(
          bikeCode: widget.bike.code,
          stationName: widget.station.name,
        ),
      );
      if (!mounted) return;
      Navigator.of(context)
        ..pop()
        ..pop();
    } else if (_vm.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_vm.errorMessage!)),
      );
    }
  }

  Future<void> _onBuyPass() async {
    if (_vm.user == null) return;
    final purchased = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PassSelectionView(userId: _vm.user!.id),
      ),
    );
    if (purchased == true) {
      await _vm.loadUser();
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: _vm.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.orange),
            )
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            children: [
              const Text('Booking Summary', style: AppTextStyles.headingLg),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Review your selection before confirming',
                style: AppTextStyles.bodySm,
              ),
              AppSpacing.gapXl,
              _InfoCard(
                icon: Icons.pedal_bike,
                label: 'Bike',
                title: widget.bike.code,
                subtitle: 'Slot ${widget.slot.slotNumber}',
              ),
              AppSpacing.gapMd,
              _InfoCard(
                icon: Icons.location_on,
                label: 'Pickup Station',
                title: widget.station.name,
                subtitle: widget.station.address,
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
              if (_vm.hasActivePlan)
                _PlanActiveCard(user: _vm.user!)
              else
                _NoPlanCard(onBuyPass: _onBuyPass),
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
            onPressed: _vm.hasActivePlan && !_vm.isSubmitting ? _onConfirm : null,
            child: _vm.isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    _vm.hasActivePlan
                        ? 'Confirm Booking'
                        : 'Active Pass Required',
                  ),
          ),
        ),
      ],
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
                Text(
                  '$typeLabel Pass · Active',
                  style: AppTextStyles.titleMd,
                ),
                const SizedBox(height: 2),
                Text('$daysLeft days remaining',
                    style: AppTextStyles.bodySm),
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
              const Icon(Icons.warning_amber_rounded,
                  color: AppColors.red, size: 24),
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
                    borderRadius: AppSpacing.radiusMd),
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.md),
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
            const Text(
              'Booking Confirmed',
              style: AppTextStyles.headingMd,
            ),
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
