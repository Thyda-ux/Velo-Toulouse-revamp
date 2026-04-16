import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/enums.dart';
import '../../../models/user_plan.dart';
import 'pass_selection_viewmodel.dart';

class PassSelectionView extends StatelessWidget {
  final String userId;
  
  const PassSelectionView({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PassSelectionViewModel(userId: userId)..load(),
      child: const _PassSelectionBody(),
    );
  }
}

class _PassSelectionBody extends StatelessWidget {
  const _PassSelectionBody();

  Future<void> _onPurchase(
    BuildContext context,
    PassSelectionViewModel vm,
  ) async {
    final ok = await vm.purchase();
    if (!context.mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    } else if (vm.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(vm.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PassSelectionViewModel>(
      builder: (context, vm, _) {
        final blocked = vm.isBlocked;

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Choose a Pass'),
          ),
          body: vm.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.orange),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: AppSpacing.paddingScreen,
                        children: [
                          const Text(
                            'Select your pass',
                            style: AppTextStyles.headingLg,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          const Text(
                            'Pick the plan that fits your ride. Your pass activates right away.',
                            style: AppTextStyles.bodySm,
                          ),
                          if (blocked) ...[
                            AppSpacing.gapLg,
                            _ActivePassBanner(plan: vm.currentPlan!),
                          ],
                          AppSpacing.gapXl,
                          _PassCard(
                            type: PlanType.daily,
                            title: 'Daily Pass',
                            price: '\$1',
                            description: '24 hours of unlimited short rides.',
                            selected: vm.selectedType == PlanType.daily,
                            disabled: blocked,
                            onTap: () => vm.selectType(PlanType.daily),
                          ),
                          AppSpacing.gapMd,
                          _PassCard(
                            type: PlanType.monthly,
                            title: 'Monthly Pass',
                            price: '\$8',
                            description:
                                '30 days of rides. Best for commuters.',
                            selected: vm.selectedType == PlanType.monthly,
                            disabled: blocked,
                            onTap: () => vm.selectType(PlanType.monthly),
                            recommended: true,
                          ),
                          AppSpacing.gapMd,
                          _PassCard(
                            type: PlanType.annual,
                            title: 'Annual Pass',
                            price: '\$60',
                            description: '365 days of rides. Best value.',
                            selected: vm.selectedType == PlanType.annual,
                            disabled: blocked,
                            onTap: () => vm.selectType(PlanType.annual),
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
                        onPressed:
                            !blocked &&
                                vm.selectedType != null &&
                                !vm.isSubmitting
                            ? () => _onPurchase(context, vm)
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
                                blocked
                                    ? 'Pass Already Active'
                                    : 'Activate Pass',
                              ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _ActivePassBanner extends StatelessWidget {
  final UserPlan plan;

  const _ActivePassBanner({required this.plan});

  @override
  Widget build(BuildContext context) {
    final typeLabel = switch (plan.type) {
      PlanType.daily => 'Daily',
      PlanType.monthly => 'Monthly',
      PlanType.annual => 'Annual',
    };
    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: AppColors.yellow.withValues(alpha: 0.12),
        borderRadius: AppSpacing.radiusMd,
        border: Border.all(color: AppColors.yellow.withValues(alpha: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.orange, size: 22),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'You already have an active pass',
                  style: AppTextStyles.titleMd,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Your $typeLabel pass is valid for ${plan.daysRemaining()} more days. You can buy a new pass once it expires.',
                  style: AppTextStyles.bodySm,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PassCard extends StatelessWidget {
  final PlanType type;
  final String title;
  final String price;
  final String description;
  final bool selected;
  final bool recommended;
  final bool disabled;
  final VoidCallback onTap;

  const _PassCard({
    required this.type,
    required this.title,
    required this.price,
    required this.description,
    required this.selected,
    required this.onTap,
    this.recommended = false,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = disabled
        ? AppColors.divider
        : selected
        ? AppColors.orange
        : AppColors.divider;
    final bgColor = disabled
        ? AppColors.background
        : selected
        ? AppColors.orange.withValues(alpha: 0.06)
        : AppColors.surface;

    return Opacity(
      opacity: disabled ? 0.55 : 1,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: AppSpacing.radiusLg,
        child: Container(
          padding: AppSpacing.paddingLg,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppSpacing.radiusLg,
            border: Border.all(
              color: borderColor,
              width: selected && !disabled ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(title, style: AppTextStyles.headingMd)),
                  if (recommended && !disabled)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withValues(alpha: 0.1),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Popular',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.orange,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(price, style: AppTextStyles.displayLg),
              const SizedBox(height: AppSpacing.xs),
              Text(description, style: AppTextStyles.bodyMd),
            ],
          ),
        ),
      ),
    );
  }
}
