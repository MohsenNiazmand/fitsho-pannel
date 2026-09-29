import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fitsho_pannel/core/error/failures.dart';
import 'package:fitsho_pannel/core/network/admin_api_service.dart';
import 'package:fitsho_pannel/features/users/domain/entities/admin_user_details.dart';
import 'package:fitsho_pannel/features/users/domain/entities/admin_user_item.dart';
import 'package:fitsho_pannel/features/users/domain/repositories/users_repository.dart';

class UsersRepositoryImpl implements UsersRepository {
  const UsersRepositoryImpl(this._apiService);

  final AdminApiService _apiService;

  @override
  Future<Either<Failure, AdminUsersResult>> getUsers({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final response = await _apiService.getUsers(
        page: page,
        limit: limit,
        search: (search != null && search.trim().isNotEmpty) ? search.trim() : null,
      );
      return right(response.toEntity());
    } on DioException catch (e) {
      final message = e.response?.data is Map && e.response?.data['message'] != null
          ? e.response?.data['message'].toString()
          : e.message ?? 'خطا در برقراری ارتباط با سرور';
      return left(ServerFailure(message ?? 'خطا در ارتباط با سرور'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminUserDetails>> getUserDetails(String id) async {
    try {
      final response = await _apiService.getUserById(id);
      return right(response.toEntity());
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return left(const NotFoundFailure('کاربر مورد نظر یافت نشد'));
      }
      final message = e.response?.data is Map && e.response?.data['message'] != null
          ? e.response?.data['message'].toString()
          : e.message ?? 'خطا در دریافت اطلاعات کاربر';
      return left(ServerFailure(message ?? 'خطا در ارتباط با سرور'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminUserDetails>> resetUserQuotas(
    String id, {
    String target = 'all',
  }) async {
    try {
      final response = await _apiService.resetUserQuotas(id, {'target': target});
      return right(response.toEntity());
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return left(const NotFoundFailure('کاربر مورد نظر یافت نشد'));
      }
      final message = e.response?.data is Map && e.response?.data['message'] != null
          ? e.response?.data['message'].toString()
          : e.message ?? 'خطا در ریست سهمیه‌های کاربر';
      return left(ServerFailure(message ?? 'خطا در ارتباط با سرور'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}

