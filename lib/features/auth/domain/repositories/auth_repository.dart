import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/admin_user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AdminUser>> login({
    required String username,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  Future<bool> isLoggedIn();

  Future<AdminUser?> getCurrentUser();
}
