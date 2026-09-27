import 'package:fpdart/fpdart.dart';
import 'package:fitsho_pannel/core/error/failures.dart';
import 'package:fitsho_pannel/features/users/domain/entities/admin_user_details.dart';
import 'package:fitsho_pannel/features/users/domain/entities/admin_user_item.dart';

abstract class UsersRepository {
  Future<Either<Failure, AdminUsersResult>> getUsers({
    int page = 1,
    int limit = 10,
    String? search,
  });

  Future<Either<Failure, AdminUserDetails>> getUserDetails(String id);
}
