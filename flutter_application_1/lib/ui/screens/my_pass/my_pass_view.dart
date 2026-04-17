import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/enums.dart';
import '../../../models/user_plan.dart';
import '../pass_selection/pass_selection_view.dart';
import 'my_pass_viewmodel.dart';

class MyPassView extends StatelessWidget {
  const MyPassView({super.key});

  @override
  Widget build(BuildContext context) {
    // MyPassViewModel is provided at the app level via ChangeNotifierProvider.value
    return const _MyPassBody();
  }
}

class _MyPassBody extends StatelessWidget {
  const _MyPassBody();

  Future<void> _openPassSelection(
    BuildContext context,
    MyPassViewModel vm,
  ) async {
    if (vm.user == null) return;
    final purchased = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PassSelectionView(userId: vm.user!.id)),
    );
    if (purchased == true) await vm.load();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyPassViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(title: const Text('My Pass')),
          body: vm.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.orange),
                )
              : vm.errorMessage != null
              ? _ErrorState(message: vm.errorMessage!, onRetry: vm.load)
              : vm.hasActivePlan
              ? _ActivePassContent(
                  plan: vm.activePlan!,
                  onTryBuyAnother: () => _openPassSelection(context, vm),
                )
              : _NoPassContent(
                  onBuyPass: () => _openPassSelection(context, vm),
                ),
        );
      },
    );
  }
}

class _ActivePassContent extends StatelessWidget {
  final UserPlan plan;
  final VoidCallback onTryBuyAnother;

  const _ActivePassContent({required this.plan, required this.onTryBuyAnother});

  String _formatDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day/$month/${d.year}';
  }

  String _labelFor(PlanType type) => switch (type) {
    PlanType.daily => 'Daily',
    PlanType.monthly => 'Monthly',
    PlanType.annual => 'Annual',
  };

  @override
  Widget build(BuildContext context) {
    final daysLeft = plan.daysRemaining();
    final typeLabel = _labelFor(plan.type);

    return ListView(
      padding: AppSpacing.paddingScreen,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.orange,
                AppColors.orange.withValues(alpha: 0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppSpacing.radiusLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.verified, color: Colors.white, size: 22),
                  const SizedBox(width: AppSpacing.sm),
                  const Text(
                    'Active',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              AppSpacing.gapMd,
              Text(
                '$typeLabel Pass',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '$daysLeft days remaining',
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ],
          ),
        ),
        AppSpacing.gapLg,
        _DetailRow(label: 'Plan type', value: '$typeLabel pass'),
        const Divider(height: 1, color: AppColors.divider),
        _DetailRow(label: 'Started on', value: _formatDate(plan.startDate)),
        const Divider(height: 1, color: AppColors.divider),
        _DetailRow(label: 'Expires on', value: _formatDate(plan.endDate)),
        const Divider(height: 1, color: AppColors.divider),
        _DetailRow(
          label: 'Days remaining',
          value: '$daysLeft',
          valueColor: AppColors.green,
        ),
        AppSpacing.gapXl,
        Container(
          padding: AppSpacing.paddingLg,
          decoration: BoxDecoration(
            color: AppColors.yellow.withValues(alpha: 0.12),
            borderRadius: AppSpacing.radiusMd,
            border: Border.all(color: AppColors.yellow.withValues(alpha: 0.6)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lock_outline, color: AppColors.orange, size: 20),
              const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: Text(
                  'You cannot buy a new pass while this one is active. You can purchase a new pass after it expires.',
                  style: AppTextStyles.bodySm,
                ),
              ),
            ],
          ),
        ),
        AppSpacing.gapLg,
        OutlinedButton(
          onPressed: onTryBuyAnother,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.orange,
            side: const BorderSide(color: AppColors.orange),
            shape: const RoundedRectangleBorder(
              borderRadius: AppSpacing.radiusMd,
            ),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          ),
          child: const Text('View Other Plans'),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodyMd)),
          Text(value, style: AppTextStyles.titleMd.copyWith(color: valueColor)),
        ],
      ),
    );
  }
}

class _NoPassContent extends StatelessWidget {
  final VoidCallback onBuyPass;

  const _NoPassContent({required this.onBuyPass});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSpacing.gapXl,
          const Icon(
            Icons.credit_card_off_outlined,
            size: 64,
            color: AppColors.textMuted,
          ),
          AppSpacing.gapLg,
          const Text(
            'No Active Pass',
            textAlign: TextAlign.center,
            style: AppTextStyles.headingLg,
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'You need an active pass to book a bike. Choose a plan that fits your ride.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd,
          ),
          AppSpacing.gapXl,
          ElevatedButton(
            onPressed: onBuyPass,
            child: const Text('Browse Passes'),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingScreen,
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
