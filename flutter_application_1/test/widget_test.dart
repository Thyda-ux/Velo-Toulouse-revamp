import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/data/repositories/mock_user_repository.dart';
import 'package:flutter_application_1/ui/screens/pass_selection/pass_selection_view.dart';
import 'package:flutter_application_1/ui/screens/pass_selection/pass_selection_viewmodel.dart';

void main() {
  testWidgets('Pass selection screen renders all three plans',
      (WidgetTester tester) async {
    PassSelectionViewModel(
      userId: 'mock-user',
      userRepo: MockUserRepository(),
    );

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: const PassSelectionView(userId: 'mock-user'),
    ));

    expect(find.text('Daily Pass'), findsOneWidget);
    expect(find.text('Monthly Pass'), findsOneWidget);
    expect(find.text('Annual Pass'), findsOneWidget);
  });
}
