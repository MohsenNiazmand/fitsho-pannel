import 'package:fpdart/fpdart.dart';
import 'package:fitsho_pannel/core/error/failures.dart';
import 'package:fitsho_pannel/features/exercises/domain/entities/admin_exercise.dart';
import 'package:fitsho_pannel/features/exercises/domain/repositories/exercise_repository.dart';

class CreateExerciseUseCase {
  const CreateExerciseUseCase(this._repository);

  final ExerciseRepository _repository;

  Future<Either<Failure, AdminExercise>> execute(Map<String, dynamic> data) {
    final key = data['key']?.toString().trim();
    final name = data['name']?.toString().trim();
    final category = data['category']?.toString().trim();
    final pattern = data['pattern']?.toString().trim();
    final primaryMuscle = data['primaryMuscle']?.toString().trim();

    if (key == null || key.isEmpty) {
      return Future.value(left(const ValidationFailure('کلید شناسه حرکت الزامی است')));
    }
    if (name == null || name.isEmpty) {
      return Future.value(left(const ValidationFailure('نام حرکت الزامی است')));
    }
    if (category == null || category.isEmpty) {
      return Future.value(left(const ValidationFailure('دسته‌بندی حرکت الزامی است')));
    }
    if (pattern == null || pattern.isEmpty) {
      return Future.value(left(const ValidationFailure('الگوی حرکتی الزامی است')));
    }
    if (primaryMuscle == null || primaryMuscle.isEmpty) {
      return Future.value(left(const ValidationFailure('عضله اصلی الزامی است')));
    }

    return _repository.createExercise(data);
  }
}
