import 'package:fpdart/fpdart.dart';
import 'package:fitsho_pannel/core/error/failures.dart';
import 'package:fitsho_pannel/features/exercises/domain/entities/admin_exercise.dart';
import 'package:fitsho_pannel/features/exercises/domain/repositories/exercise_repository.dart';

class GetExercisesUseCase {
  const GetExercisesUseCase(this._repository);

  final ExerciseRepository _repository;

  Future<Either<Failure, AdminExercisesResult>> execute({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
    String? primaryMuscle,
    bool? isActive,
  }) {
    return _repository.getExercises(
      page: page,
      limit: limit,
      search: search,
      category: category,
      primaryMuscle: primaryMuscle,
      isActive: isActive,
    );
  }
}
