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
  List<AdminExercise>? customExercises;

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

    final exercises = customExercises ?? [
      const AdminExercise(
        id: 'ex-1',
        key: 'barbell_bench_press',
        name: 'پرس سینه هالتر',
        category: 'strength',
        pattern: 'push',
        primaryMuscle: 'chest',
        gifUrl: 'https://example.com/bench.gif',
        videoUrl: 'https://example.com/bench.mp4',
        cue: 'کمر صاف باشد',
        isCustomized: true,
        locations: ['gym'],
        disciplines: ['bodybuilding'],
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
            locations: ['gym', 'home'],
            disciplines: ['fitness'],
            isActive: true,
          ),
        ];

    return right(
      AdminExercisesResult(
        exercises: exercises,
        pagination: ExercisePagination(
          total: exercises.length,
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
      // Badges
      expect(find.text('شخصی‌سازی'), findsOneWidget);
      expect(find.text('کمر صاف باشد'), findsOneWidget);
      expect(find.text('ویدیو'), findsOneWidget);
    });

    testWidgets('clicking Add Exercise button opens form dialog with all multi-select chips', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
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
      expect(find.text('مکان‌های تمرینی مجاز *'), findsOneWidget);
      expect(find.text('رشته‌های ورزشی مرتبط (۵ رشته استاندارد) *'), findsOneWidget);
      expect(find.text('سطوح مهارت مجاز *'), findsOneWidget);
      expect(find.text('تجهیزات و ابزار موردنیاز *'), findsOneWidget);
      expect(find.text('انصراف'), findsOneWidget);

      // Verify level options: beginner, intermediate, advanced are present, and elite is NOT present
      expect(find.text('مبتدی'), findsOneWidget);
      expect(find.text('متوسط'), findsOneWidget);
      expect(find.text('پیشرفته'), findsOneWidget);
      expect(find.text('حرفه‌ای'), findsNothing);

      // Submit dialog and verify isCustomized: true is sent
      final textFields = find.descendant(of: find.byType(Dialog), matching: find.byType(TextField));
      await tester.enterText(textFields.at(0), 'حرکت جدید');
      await tester.enterText(textFields.at(1), 'new_exercise_key');
      await tester.pump();

      final submitBtn = find.text('افزودن حرکت');
      await tester.tap(submitBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(mockRepo.lastCreatedData, isNotNull);
      expect(mockRepo.lastCreatedData!['key'], 'new_exercise_key');
      expect(mockRepo.lastCreatedData!['isCustomized'], true);
      expect(mockRepo.lastCreatedData!['levels'], ['beginner', 'intermediate', 'advanced']);
    });

    testWidgets('opening exercise with legacy elite level shows warning and saving sends advanced only after selection', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockRepo = MockExerciseRepository();
      mockRepo.customExercises = [
        const AdminExercise(
          id: 'ex-legacy',
          key: 'legacy_bench_press',
          name: 'پرس قدیمی',
          category: 'strength',
          pattern: 'push',
          primaryMuscle: 'chest',
          levels: ['elite'],
          disciplines: ['bodybuilding'],
          locations: ['gym'],
          equipment: ['barbell'],
          isActive: true,
        ),
      ];

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

      expect(find.text('پرس قدیمی'), findsOneWidget);

      // Tap edit button
      final editBtn = find.byIcon(Icons.edit_rounded);
      await tester.tap(editBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Unknown/legacy chip 'elite (نامعتبر)' and warning should be visible
      expect(find.textContaining('elite (نامعتبر)'), findsOneWidget);
      expect(find.textContaining('مقدار نامعتبر یا قدیمی'), findsOneWidget);

      // Admin selects 'پیشرفته' (advanced)
      final advancedChip = find.text('پیشرفته');
      await tester.ensureVisible(advancedChip);
      await tester.tap(advancedChip);
      await tester.pump();

      // Tap save
      final saveBtn = find.text('ذخیره تغییرات');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(mockRepo.lastUpdatedData, isNotNull);
      // elite should be dropped and only advanced sent
      expect(mockRepo.lastUpdatedData!['levels'], ['advanced']);
      expect(mockRepo.lastUpdatedData!['levels'], isNot(contains('elite')));
    });

    testWidgets('filtering by location shows matching exercises', (WidgetTester tester) async {
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

      // Both exercises are shown initially
      expect(find.text('پرس سینه هالتر'), findsOneWidget);
      expect(find.text('اسکات هالتر'), findsOneWidget);

      // Tap on 'خانه' chip (only squat has 'home')
      final homeChip = find.text('خانه');
      await tester.tap(homeChip);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('پرس سینه هالتر'), findsNothing);
      expect(find.text('اسکات هالتر'), findsOneWidget);
    });

    testWidgets('validation blocks submit when levels are empty and shows inline error', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
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

      final textFields = find.descendant(of: find.byType(Dialog), matching: find.byType(TextField));
      await tester.enterText(textFields.at(0), 'حرکت تستی');
      await tester.enterText(textFields.at(1), 'test_key');
      await tester.pump();

      // Deselect all default levels (beginner, intermediate, advanced)
      final beginnerChip = find.text('مبتدی');
      final intermediateChip = find.text('متوسط');
      final advancedChip = find.text('پیشرفته');

      await tester.ensureVisible(beginnerChip);
      await tester.tap(beginnerChip);
      await tester.tap(intermediateChip);
      await tester.tap(advancedChip);
      await tester.pump();

      // Tap submit
      final submitBtn = find.text('افزودن حرکت');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pump();

      // Submit must be blocked
      expect(mockRepo.lastCreatedData, isNull);
      // Inline error message must be shown
      expect(find.text('حداقل یک سطح مهارت مجاز باید انتخاب شود.'), findsOneWidget);
    });

    testWidgets('legacy discipline shows warning chip on card and in editor dialog with proper tooltip', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockRepo = MockExerciseRepository();
      mockRepo.customExercises = [
        const AdminExercise(
          id: 'ex-legacy-disc',
          key: 'legacy_disc_ex',
          name: 'حرکت با رشته نامعتبر',
          category: 'strength',
          pattern: 'push',
          primaryMuscle: 'chest',
          levels: ['beginner'],
          disciplines: ['crossfit'], // Non-canonical discipline
          locations: ['gym'],
          equipment: ['dumbbell'],
          isActive: true,
        ),
      ];

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

      expect(find.text('حرکت با رشته نامعتبر'), findsOneWidget);
      // Raw legacy discipline chip rendered on card
      expect(find.text('crossfit'), findsOneWidget);
      // Needs attention badge rendered on card
      expect(find.text('⚠️ نیازمند بررسی'), findsOneWidget);

      // Verify tooltip on the legacy discipline chip
      final tooltipFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Tooltip &&
            widget.message ==
                'Legacy value — will not be matched by the workout generator.',
      );
      expect(tooltipFinder, findsOneWidget);

      // Open edit dialog
      final editBtn = find.byIcon(Icons.edit_rounded);
      await tester.tap(editBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Warning chip in dialog
      expect(find.textContaining('crossfit (نامعتبر)'), findsOneWidget);
      expect(find.textContaining('رشته نامعتبر یا قدیمی'), findsOneWidget);
    });

    testWidgets('needs attention filter returns only rows requiring attention', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockRepo = MockExerciseRepository();
      mockRepo.customExercises = [
        const AdminExercise(
          id: 'ex-valid',
          key: 'valid_bench',
          name: 'حرکت کامل و معتبر',
          category: 'strength',
          pattern: 'push',
          primaryMuscle: 'chest',
          levels: ['beginner', 'advanced'],
          disciplines: ['bodybuilding'],
          locations: ['gym'],
          equipment: ['barbell'],
          isActive: true,
        ),
        const AdminExercise(
          id: 'ex-broken',
          key: 'broken_ex',
          name: 'حرکت ناقص',
          category: 'strength',
          pattern: 'pull',
          primaryMuscle: 'back',
          levels: [], // Empty levels -> needs attention!
          disciplines: ['fitness'],
          locations: ['gym'],
          equipment: ['dumbbell'],
          isActive: true,
        ),
      ];

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

      // Both exercises visible initially
      expect(find.text('حرکت کامل و معتبر'), findsOneWidget);
      expect(find.text('حرکت ناقص'), findsOneWidget);

      // Tap 'نیازمند بررسی' filter chip
      final attentionChip = find.text('نیازمند بررسی');
      await tester.tap(attentionChip);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Only the broken exercise is shown
      expect(find.text('حرکت کامل و معتبر'), findsNothing);
      expect(find.text('حرکت ناقص'), findsOneWidget);
    });
  });
}
