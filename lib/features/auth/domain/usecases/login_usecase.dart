import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/admin_user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, AdminUser>> execute({
    required String username,
    required String password,
  }) {
    if (username.trim().isEmpty) {
      return Future.value(left(const AuthFailure('نام کاربری یا شماره موبایل الزامی است')));
    }
    if (password.trim().isEmpty) {
      return Future.value(left(const AuthFailure('رمز عبور الزامی است')));
    }
    return _repository.login(username: username.trim(), password: password);
  }
}
