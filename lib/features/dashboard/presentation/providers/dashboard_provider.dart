import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/usecases/get_dashboard_stats_usecase.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final apiService = ref.watch(adminApiServiceProvider);
  return DashboardRepositoryImpl(apiService);
});

final getDashboardStatsUseCaseProvider = Provider<GetDashboardStatsUseCase>((ref) {
  return GetDashboardStatsUseCase(ref.watch(dashboardRepositoryProvider));
});

class DashboardState {
  const DashboardState({
    this.isLoading = false,
    this.stats,
    this.errorMessage,
  });

  final bool isLoading;
  final DashboardStats? stats;
  final String? errorMessage;

  DashboardState copyWith({
    bool? isLoading,
    DashboardStats? stats,
    String? errorMessage,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      errorMessage: errorMessage,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier(this._getStatsUseCase) : super(const DashboardState()) {
    loadStats();
  }

  final GetDashboardStatsUseCase _getStatsUseCase;

  Future<void> loadStats() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _getStatsUseCase.execute();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (stats) => state = state.copyWith(
        isLoading: false,
        stats: stats,
        errorMessage: null,
      ),
    );
  }
}

final dashboardNotifierProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(ref.watch(getDashboardStatsUseCaseProvider));
});
