import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fitsho_pannel/core/error/failures.dart';
import 'package:fitsho_pannel/features/exercises/domain/entities/admin_exercise.dart';
import 'package:fitsho_pannel/features/exercises/domain/repositories/exercise_repository.dart';
import 'package:fitsho_pannel/features/exercises/domain/usecases/create_exercise_usecase.dart';
import 'package:fitsho_pannel/features/exercises/domain/usecases/get_exercises_usecase.dart';
import 'package:fitsho_pannel/features/exercises/domain/usecases/update_exercise_usecase.dart';
import 'package:fitsho_pannel/features/exercises/presentation/providers/exercises_provider.dart';
import 'package:fitsho_pannel/features/exercises/presentation/screens/exercises_screen.dart';

class MockExerciseRepository implements ExerciseRepository {
  bool shouldSucceed = true;
  String? searchReceived;
  String? categoryReceived;
  Map<String, dynamic>? lastCreatedData;
  Map<String, dynamic>? lastUpdatedData;

  @override
  Future<Either<Failure, AdminExercisesResult>> getExercises({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
    String? primaryMuscle,
    bool? isActive,
  }) async {
    searchReceived = search;
    categoryReceived = category;

    if (!shouldSucceed) {
      return left(const ServerFailure('خطا در دریافت حرکات'));
    }

    return right(
      AdminExercisesResult(
        exercises: [
          const AdminExercise(
            id: 'ex-1',
            key: 'barbell_bench_press',
            name: 'پرس سینه هالتر',
            category: 'strength',
            pattern: 'push',
            primaryMuscle: 'chest',
            gifUrl: 'https://example.com/bench.gif',
            isActive: true,
          ),
          const AdminExercise(
            id: 'ex-2',
            key: 'barbell_squat',
            name: 'اسکات هالتر',
            category: 'strength',
            pattern: 'squat',
            primaryMuscle: 'legs',
            gifUrl: null,
            isActive: true,
          ),
        ],
        pagination: const ExercisePagination(
          total: 2,
          page: 1,
          limit: 20,
          totalPages: 1,
        ),
      ),
    );
  }

  @override
  Future<Either<Failure, AdminExercise>> createExercise(Map<String, dynamic> data) async {
    lastCreatedData = data;
    if (!shouldSucceed) {
      return left(const ServerFailure('خطا در ثبت حرکت جدید'));
    }

    return right(
      AdminExercise(
        id: 'new-ex-id',
        key: data['key'] as String,
        name: data['name'] as String,
        category: data['category'] as String,
        pattern: data['pattern'] as String,
        primaryMuscle: data['primaryMuscle'] as String,
        gifUrl: data['gifUrl'] as String?,
        isActive: data['isActive'] as bool? ?? true,
      ),
    );
  }

  @override
  Future<Either<Failure, AdminExercise>> updateExercise(
    String id,
    Map<String, dynamic> data,
  ) async {
    lastUpdatedData = data;
    if (!shouldSucceed) {
      return left(const ServerFailure('خطا در ویرایش حرکت'));
    }

    return right(
      AdminExercise(
        id: id,
        key: 'barbell_bench_press',
        name: data['name'] as String? ?? 'پرس سینه هالتر',
        category: data['category'] as String? ?? 'strength',
        pattern: 'push',
        primaryMuscle: 'chest',
        gifUrl: data['gifUrl'] as String?,
        isActive: data['isActive'] as bool? ?? true,
      ),
    );
  }
}

void main() {
  group('Exercises Domain & UseCases', () {
    test('GetExercisesUseCase returns exercises list', () async {
      final mockRepo = MockExerciseRepository();
      final useCase = GetExercisesUseCase(mockRepo);

      final result = await useCase.execute(search: 'پرس', category: 'strength');

      expect(result.isRight(), true);
      expect(mockRepo.searchReceived, 'پرس');
      expect(mockRepo.categoryReceived, 'strength');

      result.fold(
        (_) => fail('should succeed'),
        (data) {
          expect(data.exercises.length, 2);
          expect(data.exercises.first.name, 'پرس سینه هالتر');
          expect(data.pagination.total, 2);
        },
      );
    });

    test('CreateExerciseUseCase validates required fields', () async {
      final mockRepo = MockExerciseRepository();
      final useCase = CreateExerciseUseCase(mockRepo);

      final result = await useCase.execute({
        'key': '',
        'name': 'حرکت تست',
      });

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, 'کلید شناسه حرکت الزامی است'),
        (_) => fail('should fail'),
      );
    });

    test('CreateExerciseUseCase successfully creates exercise', () async {
      final mockRepo = MockExerciseRepository();
      final useCase = CreateExerciseUseCase(mockRepo);

      final result = await useCase.execute({
        'key': 'pull_up',
        'name': 'بارفیکس دست باز',
        'category': 'strength',
        'pattern': 'pull',
        'primaryMuscle': 'back',
      });

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('should succeed'),
        (created) {
          expect(created.key, 'pull_up');
          expect(created.name, 'بارفیکس دست باز');
        },
      );
    });

    test('UpdateExerciseUseCase validates exercise id', () async {
      final mockRepo = MockExerciseRepository();
      final useCase = UpdateExerciseUseCase(mockRepo);

      final result = await useCase.execute('', {'name': 'تست'});

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, 'شناسه حرکت الزامی است'),
        (_) => fail('should fail'),
      );
    });
  });

  group('ExercisesScreen Widget Tests', () {
    testWidgets('renders exercises screen and items', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockRepo = MockExerciseRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exerciseRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: ExercisesScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('بانک حرکات ورزشی'), findsOneWidget);
      expect(find.text('پرس سینه هالتر'), findsOneWidget);
      expect(find.text('barbell_bench_press'), findsOneWidget);
      expect(find.text('اسکات هالتر'), findsOneWidget);
      expect(find.text('افزودن حرکت جدید'), findsOneWidget);
    });

    testWidgets('clicking Add Exercise button opens form dialog', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockRepo = MockExerciseRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exerciseRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: ExercisesScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final addBtn = find.text('افزودن حرکت جدید');
      await tester.tap(addBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('نام حرکت (فارسی) *'), findsOneWidget);
      expect(find.text('کلید یکتا (انگلیسی) *'), findsOneWidget);
      expect(find.text('انصراف'), findsOneWidget);
    });
  });
}
