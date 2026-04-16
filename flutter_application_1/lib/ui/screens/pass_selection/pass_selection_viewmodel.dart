import 'package:flutter/material.dart';
import '../../../data/repositories/firebase_user_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../models/enums.dart';
import '../../../models/user.dart';
import '../../../models/user_plan.dart';

class PassSelectionViewModel extends ChangeNotifier {
  final String userId;
  final UserRepository _userRepo;

  PassSelectionViewModel({
    required this.userId,
    UserRepository? userRepo,
  }) : _userRepo = userRepo ?? FirebaseUserRepository();

  AppUser? user;
  PlanType? selectedType;
  bool isLoading = true;
  bool isSubmitting = false;
  String? errorMessage;

  UserPlan? get currentPlan =>
      (user?.hasActivePlan() ?? false) ? user!.activePlan : null;
  bool get isBlocked => currentPlan != null;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    user = await _userRepo.getUser(userId);
    isLoading = false;
    notifyListeners();
  }

  void selectType(PlanType type) {
    if (isBlocked) return;
    selectedType = type;
    errorMessage = null;
    notifyListeners();
  }

  Duration _durationFor(PlanType type) => switch (type) {
        PlanType.daily => const Duration(days: 1),
        PlanType.monthly => const Duration(days: 30),
        PlanType.annual => const Duration(days: 365),
      };

  Future<bool> purchase() async {
    if (selectedType == null || isBlocked) return false;
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final plan = UserPlan(
        id: '',
        type: selectedType!,
        startDate: now,
        endDate: now.add(_durationFor(selectedType!)),
      );
      final planId = await _userRepo.createUserPlan(plan);
      await _userRepo.assignPlanToUser(userId, planId);
      isSubmitting = false;
      notifyListeners();
      return true;
    } catch (_) {
      errorMessage = 'Could not activate your pass. Please try again.';
      isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
}
