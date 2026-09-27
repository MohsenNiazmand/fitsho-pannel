import 'package:fpdart/fpdart.dart';
import 'package:fitsho_pannel/core/error/failures.dart';
import 'package:fitsho_pannel/features/users/domain/entities/admin_user_item.dart';
import 'package:fitsho_pannel/features/users/domain/repositories/users_repository.dart';

class GetUsersUseCase {
  const GetUsersUseCase(this._repository);

  final UsersRepository _repository;

  Future<Either<Failure, AdminUsersResult>> execute({
    int page = 1,
    int limit = 10,
    String? search,
  }) {
    return _repository.getUsers(
      page: page,
      limit: limit,
      search: search,
    );
  }
}
