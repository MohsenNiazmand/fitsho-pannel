import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/admin_api_service.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/admin_login_request.dart';
import '../models/admin_auth_response.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._apiService, this._tokenStorage);

  final AdminApiService _apiService;
  final TokenStorage _tokenStorage;

  @override
  Future<Either<Failure, AdminUser>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiService.login(
        AdminLoginRequest(username: username, password: password),
      );

      if (response.accessToken == null || response.user == null) {
        return left(const AuthFailure('پاسخ سرور نامعتبر است'));
      }

      await _tokenStorage.saveTokens(
        accessToken: response.accessToken!,
        refreshToken: response.refreshToken,
      );

      await _tokenStorage.saveUserJson(jsonEncode(response.user!.toJson()));

      return right(response.user!.toEntity());
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        final message = e.response?.data is Map
            ? (e.response?.data['message'] as String? ?? 'نام کاربری یا رمز عبور اشتباه است')
            : 'نام کاربری یا رمز عبور اشتباه است';
        return left(AuthFailure(message));
      }
      return left(ServerFailure(
        e.response?.data?['message']?.toString() ?? 'خطا در ارتباط با سرور',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _tokenStorage.clear();
      return right(null);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return _tokenStorage.hasToken();
  }

  @override
  Future<AdminUser?> getCurrentUser() async {
    final userJson = await _tokenStorage.getUserJson();
    if (userJson == null) return null;
    try {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      return AdminUserModel.fromJson(map).toEntity();
    } catch (_) {
      return null;
    }
  }
}
