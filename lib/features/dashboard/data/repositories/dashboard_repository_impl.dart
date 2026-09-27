import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/admin_api_service.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._apiService);

  final AdminApiService _apiService;

  @override
  Future<Either<Failure, DashboardStats>> getStats() async {
    try {
      final response = await _apiService.getDashboardStats();
      if (response.data == null) {
        return left(const ServerFailure('دریافت اطلاعات آماری با خطا مواجه شد'));
      }
      return right(response.data!.toEntity());
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        return left(const AuthFailure('دسترسی غیرمجاز'));
      }
      return left(ServerFailure(
        e.response?.data?['message']?.toString() ?? 'خطا در ارتباط با سرور',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
