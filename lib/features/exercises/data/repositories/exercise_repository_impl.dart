import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fitsho_pannel/core/error/failures.dart';
import 'package:fitsho_pannel/core/network/admin_api_service.dart';
import 'package:fitsho_pannel/features/exercises/domain/entities/admin_exercise.dart';
import 'package:fitsho_pannel/features/exercises/domain/repositories/exercise_repository.dart';

class ExerciseRepositoryImpl implements ExerciseRepository {
  const ExerciseRepositoryImpl(this._apiService);

  final AdminApiService _apiService;

  @override
  Future<Either<Failure, AdminExercisesResult>> getExercises({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
    String? primaryMuscle,
    bool? isActive,
  }) async {
    try {
      final response = await _apiService.getExercises(
        page: page,
        limit: limit,
        search: (search != null && search.trim().isNotEmpty) ? search.trim() : null,
        category: (category != null && category.trim().isNotEmpty) ? category.trim() : null,
        primaryMuscle: (primaryMuscle != null && primaryMuscle.trim().isNotEmpty)
            ? primaryMuscle.trim()
            : null,
        isActive: isActive,
      );
      return right(response.toEntity());
    } on DioException catch (e) {
      final message = e.response?.data is Map && e.response?.data['message'] != null
          ? e.response?.data['message'].toString()
          : e.message ?? 'خطا در دریافت لیست حرکات';
      return left(ServerFailure(message ?? 'خطا در برقراری ارتباط'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminExercise>> createExercise(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.createExercise(data);
      return right(response.toEntity());
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return left(const ServerFailure('حرکتی با این کلید قبلاً ثبت شده است'));
      }
      final message = e.response?.data is Map && e.response?.data['message'] != null
          ? e.response?.data['message'].toString()
          : e.message ?? 'خطا در ثبت حرکت جدید';
      return left(ServerFailure(message ?? 'خطا در برقراری ارتباط'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminExercise>> updateExercise(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.updateExercise(id, data);
      return right(response.toEntity());
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return left(const NotFoundFailure('حرکت مورد نظر یافت نشد'));
      }
      if (e.response?.statusCode == 409) {
        return left(const ServerFailure('کلید وارد شده برای حرکت تکراری است'));
      }
      final message = e.response?.data is Map && e.response?.data['message'] != null
          ? e.response?.data['message'].toString()
          : e.message ?? 'خطا در ویرایش حرکت';
      return left(ServerFailure(message ?? 'خطا در برقراری ارتباط'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
