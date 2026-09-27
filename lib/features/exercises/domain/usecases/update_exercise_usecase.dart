import 'package:fpdart/fpdart.dart';
import 'package:fitsho_pannel/core/error/failures.dart';
import 'package:fitsho_pannel/features/exercises/domain/entities/admin_exercise.dart';
import 'package:fitsho_pannel/features/exercises/domain/repositories/exercise_repository.dart';

class UpdateExerciseUseCase {
  const UpdateExerciseUseCase(this._repository);

  final ExerciseRepository _repository;

  Future<Either<Failure, AdminExercise>> execute(String id, Map<String, dynamic> data) {
    if (id.trim().isEmpty) {
      return Future.value(left(const ValidationFailure('شناسه حرکت الزامی است')));
    }
    return _repository.updateExercise(id.trim(), data);
  }
}
