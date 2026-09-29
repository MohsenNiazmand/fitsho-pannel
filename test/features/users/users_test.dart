import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fitsho_pannel/core/error/failures.dart';
import 'package:fitsho_pannel/features/users/domain/entities/admin_user_details.dart';
import 'package:fitsho_pannel/features/users/domain/entities/admin_user_item.dart';
import 'package:fitsho_pannel/features/users/domain/repositories/users_repository.dart';
import 'package:fitsho_pannel/features/users/domain/usecases/get_user_details_usecase.dart';
import 'package:fitsho_pannel/features/users/domain/usecases/get_users_usecase.dart';
import 'package:fitsho_pannel/features/users/domain/usecases/reset_user_quotas_usecase.dart';
import 'package:fitsho_pannel/features/users/presentation/providers/users_provider.dart';

import 'package:fitsho_pannel/features/users/presentation/screens/users_screen.dart';

class MockUsersRepository implements UsersRepository {
  bool shouldSucceed = true;
  String? searchReceived;
  int? pageReceived;

  @override
  Future<Either<Failure, AdminUsersResult>> getUsers({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    pageReceived = page;
    searchReceived = search;

    if (!shouldSucceed) {
      return left(const ServerFailure('خطای سرور در دریافت کاربران'));
    }

    return right(
      AdminUsersResult(
        users: [
          AdminUserItem(
            id: 'u-1',
            mobile: '09121112233',
            name: 'علی محمدی',
            role: 'USER',
            createdAt: DateTime(2026, 1, 15),
            workoutPlansCount: 3,
            dietPlansCount: 2,
          ),
          AdminUserItem(
            id: 'u-2',
            mobile: '09129998877',
            name: 'سارا احمدی',
            role: 'ADMIN',
            createdAt: DateTime(2026, 2, 10),
            workoutPlansCount: 1,
            dietPlansCount: 1,
          ),
        ],
        pagination: const UserPagination(
          total: 2,
          page: 1,
          limit: 10,
          totalPages: 1,
        ),
      ),
    );
  }

  @override
  Future<Either<Failure, AdminUserDetails>> getUserDetails(String id) async {
    if (!shouldSucceed) {
      return left(const ServerFailure('خطا در دریافت جزئیات کاربر'));
    }

    return right(
      AdminUserDetails(
        id: id,
        mobile: '09121112233',
        name: 'علی محمدی',
        role: 'USER',
        createdAt: DateTime(2026, 1, 15),
        dietProfile: const {
          'age': 25,
          'heightCm': 180,
          'weightKg': 75,
          'gender': 'male',
          'goal': 'hypertrophy',
        },
        workoutPlansCount: 3,
        dietPlansCount: 2,
      ),
    );
  }

  @override
  Future<Either<Failure, AdminUserDetails>> resetUserQuotas(
    String id, {
    String target = 'all',
  }) async {
    if (!shouldSucceed) {
      return left(const ServerFailure('خطا در ریست سهمیه‌های کاربر'));
    }
    return getUserDetails(id);
  }
}


void main() {
  group('Users Domain & UseCases', () {
    test('GetUsersUseCase returns user list and pagination', () async {
      final mockRepo = MockUsersRepository();
      final useCase = GetUsersUseCase(mockRepo);

      final result = await useCase.execute(page: 2, limit: 10, search: 'علی');

      expect(result.isRight(), true);
      expect(mockRepo.pageReceived, 2);
      expect(mockRepo.searchReceived, 'علی');

      result.fold(
        (_) => fail('should succeed'),
        (data) {
          expect(data.users.length, 2);
          expect(data.users.first.name, 'علی محمدی');
          expect(data.pagination.total, 2);
        },
      );
    });

    test('GetUserDetailsUseCase fails when id is empty', () async {
      final mockRepo = MockUsersRepository();
      final useCase = GetUserDetailsUseCase(mockRepo);

      final result = await useCase.execute('   ');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, 'شناسه کاربر الزامی است'),
        (_) => fail('should fail'),
      );
    });

    test('GetUserDetailsUseCase returns full user details for valid id', () async {
      final mockRepo = MockUsersRepository();
      final useCase = GetUserDetailsUseCase(mockRepo);

      final result = await useCase.execute('u-1');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('should succeed'),
        (details) {
          expect(details.id, 'u-1');
          expect(details.dietProfile?['goal'], 'hypertrophy');
          expect(details.workoutPlansCount, 3);
        },
      );
    });

    test('ResetUserQuotasUseCase resets quotas successfully', () async {
      final mockRepo = MockUsersRepository();
      final useCase = ResetUserQuotasUseCase(mockRepo);

      final result = await useCase.execute('u-1', target: 'all');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('should succeed'),
        (details) {
          expect(details.id, 'u-1');
        },
      );
    });
  });


  group('UsersScreen Widget Tests', () {
    testWidgets('renders users list, search input, and table items', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockRepo = MockUsersRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            usersRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: UsersScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('مدیریت کاربران'), findsOneWidget);
      expect(find.text('علی محمدی'), findsOneWidget);
      expect(find.text('09121112233'), findsOneWidget);
      expect(find.text('سارا احمدی'), findsOneWidget);
      expect(find.text('09129998877'), findsOneWidget);
      expect(find.text('مدیر'), findsOneWidget);
      expect(find.text('کاربر عادی'), findsOneWidget);
      expect(find.text('سهمیه تمرین'), findsOneWidget);
      expect(find.text('سهمیه غذا'), findsOneWidget);
    });

    testWidgets('clicking view details opens user details modal with quotas section', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockRepo = MockUsersRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            usersRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: UsersScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Click on the first details icon
      final detailsBtn = find.byIcon(Icons.visibility_rounded).first;
      await tester.tap(detailsBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('خلاصه وضعیت فیزیکی'), findsOneWidget);
      expect(find.text('25 سال'), findsOneWidget);
      expect(find.text('180 سانتی‌متر'), findsOneWidget);
      expect(find.text('سهمیه‌ها و محدودیت‌ها'), findsOneWidget);
      expect(find.text('شارژ سهمیه / ریست'), findsOneWidget);
    });
  });
}

