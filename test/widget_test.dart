import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitsho_pannel/main.dart';

void main() {
  testWidgets('FitShoAdminApp smoke test and navigation rendering', (WidgetTester tester) async {
    // Set screen size to desktop width (1000px)
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: FitShoAdminApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify sidebar title and dashboard item
    expect(find.text('فیت‌شو'), findsOneWidget);
    expect(find.text('داشبورد'), findsOneWidget);
    expect(find.text('صفحه داشبورد'), findsOneWidget);
  });

  testWidgets('ResponsiveScaffold renders BottomNavigationBar on mobile', (WidgetTester tester) async {
    // Set screen size to mobile width (400px)
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: FitShoAdminApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify NavigationBar is rendered
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
