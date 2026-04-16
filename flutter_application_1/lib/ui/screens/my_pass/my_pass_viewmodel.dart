import 'package:flutter/material.dart';
import '../../../data/repositories/firebase_user_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../models/user.dart';
import '../../../models/user_plan.dart';

class MyPassViewModel extends ChangeNotifier {
  final UserRepository _userRepo;

  MyPassViewModel({UserRepository? userRepo})
      : _userRepo = userRepo ?? FirebaseUserRepository();

  AppUser? user;
  bool isLoading = true;
  String? errorMessage;

  bool get hasActivePlan => user?.hasActivePlan() ?? false;
  UserPlan? get activePlan => hasActivePlan ? user!.activePlan : null;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      user = await _userRepo.getCurrentUser();
    } catch (_) {
      errorMessage = 'Could not load your pass. Please try again.';
    }
    isLoading = false;
    notifyListeners();
  }
}
