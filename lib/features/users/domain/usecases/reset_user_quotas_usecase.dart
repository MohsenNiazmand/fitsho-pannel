import 'package:fpdart/fpdart.dart';
import 'package:fitsho_pannel/core/error/failures.dart';
import 'package:fitsho_pannel/features/users/domain/entities/admin_user_details.dart';
import 'package:fitsho_pannel/features/users/domain/repositories/users_repository.dart';

class ResetUserQuotasUseCase {
  const ResetUserQuotasUseCase(this._repository);

  final UsersRepository _repository;

  Future<Either<Failure, AdminUserDetails>> execute(
    String id, {
    String target = 'all',
  }) {
    return _repository.resetUserQuotas(id, target: target);
  }
}
