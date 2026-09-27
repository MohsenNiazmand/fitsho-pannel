import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/dashboard_stats.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardStatsUseCase {
  const GetDashboardStatsUseCase(this._repository);

  final DashboardRepository _repository;

  Future<Either<Failure, DashboardStats>> execute() {
    return _repository.getStats();
  }
}
