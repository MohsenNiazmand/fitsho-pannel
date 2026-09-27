import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/admin_api_service.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';

// Storage Providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize sharedPreferencesProvider in main');
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorageImpl(
    ref.watch(secureStorageProvider),
    ref.watch(sharedPreferencesProvider),
  );
});

// Network Providers
final dioClientProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return createDioClient(tokenStorage);
});

final adminApiServiceProvider = Provider<AdminApiService>((ref) {
  final dio = ref.watch(dioClientProvider);
  return AdminApiService(dio);
});

// Repository & UseCases
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(adminApiServiceProvider),
    ref.watch(tokenStorageProvider),
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

// Auth State
class AuthState {
  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.adminUser,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isAuthenticated;
  final AdminUser? adminUser;
  final String? errorMessage;

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    AdminUser? adminUser,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      adminUser: adminUser ?? this.adminUser,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._loginUseCase, this._authRepository) : super(const AuthState()) {
    checkAuthStatus();
  }

  final LoginUseCase _loginUseCase;
  final AuthRepository _authRepository;

  Future<void> checkAuthStatus() async {
    final isLoggedIn = await _authRepository.isLoggedIn();
    if (isLoggedIn) {
      final user = await _authRepository.getCurrentUser();
      state = state.copyWith(isAuthenticated: true, adminUser: user);
    } else {
      state = state.copyWith(isAuthenticated: false, adminUser: null);
    }
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _loginUseCase.execute(username: username, password: password);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (user) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          adminUser: user,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _authRepository.logout();
    state = const AuthState(isAuthenticated: false);
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(loginUseCaseProvider),
    ref.watch(authRepositoryProvider),
  );
});
