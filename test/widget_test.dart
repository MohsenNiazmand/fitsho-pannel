import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitsho_pannel/features/auth/domain/entities/admin_user.dart';
import 'package:fitsho_pannel/features/auth/presentation/providers/auth_provider.dart';
import 'package:fitsho_pannel/main.dart';

void main() {
  testWidgets('FitShoAdminApp smoke test and navigation rendering', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authNotifierProvider.overrideWith((ref) => _FakeAuthNotifier(true)),
        ],
        child: const FitShoAdminApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify sidebar title and dashboard item
    expect(find.text('فیت‌شو'), findsOneWidget);
    expect(find.text('داشبورد'), findsOneWidget);
    expect(find.text('صفحه داشبورد'), findsOneWidget);
  });

  testWidgets('ResponsiveScaffold renders BottomNavigationBar on mobile', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authNotifierProvider.overrideWith((ref) => _FakeAuthNotifier(true)),
        ],
        child: const FitShoAdminApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
  });
}

class _FakeAuthNotifier extends StateNotifier<AuthState> implements AuthNotifier {
  _FakeAuthNotifier(bool authenticated)
      : super(AuthState(
          isAuthenticated: authenticated,
          adminUser: const AdminUser(id: 'admin-1', mobile: 'admin', name: 'مدیر کل'),
        ));

  @override
  Future<void> checkAuthStatus() async {}

  @override
  Future<bool> login(String username, String password) async => true;

  @override
  Future<void> logout() async {
    state = const AuthState(isAuthenticated: false);
  }
}
