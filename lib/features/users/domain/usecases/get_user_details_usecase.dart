import 'package:fpdart/fpdart.dart';
import 'package:fitsho_pannel/core/error/failures.dart';
import 'package:fitsho_pannel/features/users/domain/entities/admin_user_details.dart';
import 'package:fitsho_pannel/features/users/domain/repositories/users_repository.dart';

class GetUserDetailsUseCase {
  const GetUserDetailsUseCase(this._repository);

  final UsersRepository _repository;

  Future<Either<Failure, AdminUserDetails>> execute(String id) {
    if (id.trim().isEmpty) {
      return Future.value(left(const ValidationFailure('شناسه کاربر الزامی است')));
    }
    return _repository.getUserDetails(id);
  }
}
