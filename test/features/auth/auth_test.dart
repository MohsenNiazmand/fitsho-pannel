import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitsho_pannel/core/error/failures.dart';
import 'package:fitsho_pannel/features/auth/domain/entities/admin_user.dart';
import 'package:fitsho_pannel/features/auth/domain/repositories/auth_repository.dart';
import 'package:fitsho_pannel/features/auth/domain/usecases/login_usecase.dart';
import 'package:fitsho_pannel/features/auth/presentation/providers/auth_provider.dart';
import 'package:fitsho_pannel/features/auth/presentation/screens/login_screen.dart';

class MockAuthRepository implements AuthRepository {
  bool shouldSucceed = true;
  String? failureMessage;

  @override
  Future<Either<Failure, AdminUser>> login({
    required String username,
    required String password,
  }) async {
    if (!shouldSucceed) {
      return left(AuthFailure(failureMessage ?? 'نام کاربری یا رمز عبور اشتباه است'));
    }
    return right(AdminUser(id: 'admin-1', mobile: username, name: 'تست ادمین'));
  }

  @override
  Future<Either<Failure, void>> logout() async {
    return right(null);
  }

  @override
  Future<bool> isLoggedIn() async => false;

  @override
  Future<AdminUser?> getCurrentUser() async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockRepo;
  late LoginUseCase loginUseCase;

  setUp(() {
    mockRepo = MockAuthRepository();
    loginUseCase = LoginUseCase(mockRepo);
  });

  group('LoginUseCase', () {
    test('returns failure when username is empty', () async {
      final result = await loginUseCase.execute(username: '', password: '123');
      expect(result.isLeft(), true);
    });

    test('returns failure when password is empty', () async {
      final result = await loginUseCase.execute(username: 'admin', password: '');
      expect(result.isLeft(), true);
    });

    test('returns AdminUser when credentials are valid', () async {
      mockRepo.shouldSucceed = true;
      final result = await loginUseCase.execute(username: 'admin', password: '123');
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('should succeed'),
        (user) {
          expect(user.id, 'admin-1');
          expect(user.mobile, 'admin');
        },
      );
    });
  });

  group('LoginScreen Widget Tests', () {
    testWidgets('renders login screen form fields and button', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            authRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      expect(find.text('ورود به پنل مدیریت فیت‌شو'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('ورود به پنل'), findsOneWidget);
    });
  });
}
