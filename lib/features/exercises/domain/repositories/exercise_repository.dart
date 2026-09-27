import 'package:fpdart/fpdart.dart';
import 'package:fitsho_pannel/core/error/failures.dart';
import 'package:fitsho_pannel/features/exercises/domain/entities/admin_exercise.dart';

abstract class ExerciseRepository {
  Future<Either<Failure, AdminExercisesResult>> getExercises({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
    String? primaryMuscle,
    bool? isActive,
  });

  Future<Either<Failure, AdminExercise>> createExercise(Map<String, dynamic> data);

  Future<Either<Failure, AdminExercise>> updateExercise(String id, Map<String, dynamic> data);
}
