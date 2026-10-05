import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitsho_pannel/features/auth/presentation/providers/auth_provider.dart';
import 'package:fitsho_pannel/features/exercises/data/repositories/exercise_repository_impl.dart';
import 'package:fitsho_pannel/features/exercises/domain/entities/admin_exercise.dart';
import 'package:fitsho_pannel/features/exercises/domain/repositories/exercise_repository.dart';
import 'package:fitsho_pannel/features/exercises/domain/usecases/create_exercise_usecase.dart';
import 'package:fitsho_pannel/features/exercises/domain/usecases/get_exercises_usecase.dart';
import 'package:fitsho_pannel/features/exercises/domain/usecases/update_exercise_usecase.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  final apiService = ref.watch(adminApiServiceProvider);
  return ExerciseRepositoryImpl(apiService);
});

final getExercisesUseCaseProvider = Provider<GetExercisesUseCase>((ref) {
  final repository = ref.watch(exerciseRepositoryProvider);
  return GetExercisesUseCase(repository);
});

final createExerciseUseCaseProvider = Provider<CreateExerciseUseCase>((ref) {
  final repository = ref.watch(exerciseRepositoryProvider);
  return CreateExerciseUseCase(repository);
});

final updateExerciseUseCaseProvider = Provider<UpdateExerciseUseCase>((ref) {
  final repository = ref.watch(exerciseRepositoryProvider);
  return UpdateExerciseUseCase(repository);
});

class ExercisesState {
  const ExercisesState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
    this.exercises = const [],
    this.pagination,
    this.currentPage = 1,
    this.searchQuery = '',
    this.selectedCategory,
    this.selectedMuscle,
    this.selectedLocation,
    this.needsAttentionOnly = false,
  });

  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;
  final List<AdminExercise> exercises;
  final ExercisePagination? pagination;
  final int currentPage;
  final String searchQuery;
  final String? selectedCategory;
  final String? selectedMuscle;
  final String? selectedLocation;
  final bool needsAttentionOnly;

  List<AdminExercise> get filteredExercises {
    var result = exercises;
    if (selectedLocation != null && selectedLocation!.isNotEmpty) {
      result = result
          .where((e) => e.locations.contains(selectedLocation))
          .toList();
    }
    if (needsAttentionOnly) {
      result = result.where((e) => e.needsAttention).toList();
    }
    return result;
  }

  ExercisesState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
    List<AdminExercise>? exercises,
    ExercisePagination? pagination,
    int? currentPage,
    String? searchQuery,
    String? selectedCategory,
    bool clearCategory = false,
    String? selectedMuscle,
    bool clearMuscle = false,
    String? selectedLocation,
    bool clearLocation = false,
    bool? needsAttentionOnly,
  }) {
    return ExercisesState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      exercises: exercises ?? this.exercises,
      pagination: pagination ?? this.pagination,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      selectedMuscle: clearMuscle ? null : (selectedMuscle ?? this.selectedMuscle),
      selectedLocation: clearLocation ? null : (selectedLocation ?? this.selectedLocation),
      needsAttentionOnly: needsAttentionOnly ?? this.needsAttentionOnly,
    );
  }
}

class ExercisesNotifier extends StateNotifier<ExercisesState> {
  ExercisesNotifier(
    this._getExercisesUseCase,
    this._createExerciseUseCase,
    this._updateExerciseUseCase,
  ) : super(const ExercisesState()) {
    fetchExercises();
  }

  final GetExercisesUseCase _getExercisesUseCase;
  final CreateExerciseUseCase _createExerciseUseCase;
  final UpdateExerciseUseCase _updateExerciseUseCase;

  Future<void> fetchExercises({
    int? page,
    String? search,
    String? category,
    String? muscle,
  }) async {
    final targetPage = page ?? state.currentPage;
    final targetSearch = search ?? state.searchQuery;
    final targetCategory = category ?? state.selectedCategory;
    final targetMuscle = muscle ?? state.selectedMuscle;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
      currentPage: targetPage,
      searchQuery: targetSearch,
      selectedCategory: targetCategory,
      selectedMuscle: targetMuscle,
    );

    final result = await _getExercisesUseCase.execute(
      page: targetPage,
      limit: 20,
      search: targetSearch,
      category: targetCategory,
      primaryMuscle: targetMuscle,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (data) {
        state = state.copyWith(
          isLoading: false,
          exercises: data.exercises,
          pagination: data.pagination,
          currentPage: data.pagination.page,
        );
      },
    );
  }

  Future<void> onSearch(String query) async {
    await fetchExercises(page: 1, search: query);
  }

  Future<void> onCategorySelected(String? category) async {
    if (state.selectedCategory == category) {
      state = state.copyWith(clearCategory: true);
      await fetchExercises(page: 1, category: '');
    } else {
      await fetchExercises(page: 1, category: category);
    }
  }

  Future<void> onMuscleSelected(String? muscle) async {
    if (state.selectedMuscle == muscle) {
      state = state.copyWith(clearMuscle: true);
      await fetchExercises(page: 1, muscle: '');
    } else {
      await fetchExercises(page: 1, muscle: muscle);
    }
  }

  void onLocationSelected(String? location) {
    if (state.selectedLocation == location) {
      state = state.copyWith(clearLocation: true);
    } else {
      state = state.copyWith(selectedLocation: location);
    }
  }

  void toggleNeedsAttentionOnly() {
    state = state.copyWith(needsAttentionOnly: !state.needsAttentionOnly);
  }

  void setNeedsAttentionOnly(bool value) {
    state = state.copyWith(needsAttentionOnly: value);
  }

  Future<void> nextPage() async {
    final pagination = state.pagination;
    if (pagination != null && state.currentPage < pagination.totalPages) {
      await fetchExercises(page: state.currentPage + 1);
    }
  }

  Future<void> previousPage() async {
    if (state.currentPage > 1) {
      await fetchExercises(page: state.currentPage - 1);
    }
  }

  Future<bool> createExercise(Map<String, dynamic> data) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true);

    final result = await _createExerciseUseCase.execute(data);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (created) {
        state = state.copyWith(
          isSubmitting: false,
          successMessage: 'حرکت "${created.name}" با موفقیت ایجاد شد',
        );
        fetchExercises(page: 1);
        return true;
      },
    );
  }

  Future<bool> updateExercise(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true);

    final result = await _updateExerciseUseCase.execute(id, data);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (updated) {
        state = state.copyWith(
          isSubmitting: false,
          successMessage: 'حرکت "${updated.name}" با موفقیت به‌روزرسانی شد',
        );
        fetchExercises();
        return true;
      },
    );
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}

final exercisesNotifierProvider =
    StateNotifierProvider<ExercisesNotifier, ExercisesState>((ref) {
  final getExercises = ref.watch(getExercisesUseCaseProvider);
  final createExercise = ref.watch(createExerciseUseCaseProvider);
  final updateExercise = ref.watch(updateExerciseUseCaseProvider);
  return ExercisesNotifier(getExercises, createExercise, updateExercise);
});
