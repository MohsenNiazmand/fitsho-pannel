import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fitsho_pannel/core/error/failures.dart';
import 'package:fitsho_pannel/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:fitsho_pannel/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:fitsho_pannel/features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';
import 'package:fitsho_pannel/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:fitsho_pannel/features/dashboard/presentation/screens/dashboard_screen.dart';

class MockDashboardRepository implements DashboardRepository {
  bool shouldSucceed = true;
  String? errorMessage;

  @override
  Future<Either<Failure, DashboardStats>> getStats() async {
    if (!shouldSucceed) {
      return left(ServerFailure(errorMessage ?? 'خطای دریافت آمار'));
    }
    return right(
      const DashboardStats(
        totalUsers: 150,
        totalWorkoutPlans: 80,
        totalDietPlans: 60,
        totalExercises: 200,
        activeUsersToday: 25,
        newUsersToday: 10,
      ),
    );
  }
}

void main() {
  test('GetDashboardStatsUseCase returns stats from repository', () async {
    final mockRepo = MockDashboardRepository();
    final useCase = GetDashboardStatsUseCase(mockRepo);

    final result = await useCase.execute();

    expect(result.isRight(), true);
    result.fold(
      (_) => fail('should succeed'),
      (stats) {
        expect(stats.totalUsers, 150);
        expect(stats.totalWorkoutPlans, 80);
        expect(stats.totalExercises, 200);
      },
    );
  });

  testWidgets('DashboardScreen renders statistics cards correctly', (WidgetTester tester) async {
    final mockRepo = MockDashboardRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('داشبورد تحلیلی و آماری'), findsOneWidget);
    expect(find.text('تعداد کل کاربران'), findsOneWidget);
    expect(find.text('150'), findsOneWidget);
    expect(find.text('برنامه‌های تمرینی'), findsOneWidget);
    expect(find.text('80'), findsOneWidget);
    expect(find.text('بانک حرکات ورزشی'), findsNWidgets(2));
    expect(find.text('200'), findsOneWidget);
  });
}
