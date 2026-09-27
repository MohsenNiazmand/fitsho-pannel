import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitsho_pannel/features/auth/presentation/providers/auth_provider.dart';
import 'package:fitsho_pannel/features/users/data/repositories/users_repository_impl.dart';
import 'package:fitsho_pannel/features/users/domain/entities/admin_user_details.dart';
import 'package:fitsho_pannel/features/users/domain/entities/admin_user_item.dart';
import 'package:fitsho_pannel/features/users/domain/repositories/users_repository.dart';
import 'package:fitsho_pannel/features/users/domain/usecases/get_user_details_usecase.dart';
import 'package:fitsho_pannel/features/users/domain/usecases/get_users_usecase.dart';

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  final apiService = ref.watch(adminApiServiceProvider);
  return UsersRepositoryImpl(apiService);
});

final getUsersUseCaseProvider = Provider<GetUsersUseCase>((ref) {
  final repository = ref.watch(usersRepositoryProvider);
  return GetUsersUseCase(repository);
});

final getUserDetailsUseCaseProvider = Provider<GetUserDetailsUseCase>((ref) {
  final repository = ref.watch(usersRepositoryProvider);
  return GetUserDetailsUseCase(repository);
});

class UsersState {
  const UsersState({
    this.isLoading = false,
    this.errorMessage,
    this.users = const [],
    this.pagination,
    this.currentPage = 1,
    this.searchQuery = '',
    this.selectedUserDetails,
    this.isLoadingDetails = false,
    this.detailsError,
  });

  final bool isLoading;
  final String? errorMessage;
  final List<AdminUserItem> users;
  final UserPagination? pagination;
  final int currentPage;
  final String searchQuery;
  final AdminUserDetails? selectedUserDetails;
  final bool isLoadingDetails;
  final String? detailsError;

  UsersState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    List<AdminUserItem>? users,
    UserPagination? pagination,
    int? currentPage,
    String? searchQuery,
    AdminUserDetails? selectedUserDetails,
    bool clearSelectedDetails = false,
    bool? isLoadingDetails,
    String? detailsError,
    bool clearDetailsError = false,
  }) {
    return UsersState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      users: users ?? this.users,
      pagination: pagination ?? this.pagination,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedUserDetails: clearSelectedDetails
          ? null
          : (selectedUserDetails ?? this.selectedUserDetails),
      isLoadingDetails: isLoadingDetails ?? this.isLoadingDetails,
      detailsError:
          clearDetailsError ? null : (detailsError ?? this.detailsError),
    );
  }
}

class UsersNotifier extends StateNotifier<UsersState> {
  UsersNotifier(this._getUsersUseCase, this._getUserDetailsUseCase)
      : super(const UsersState()) {
    fetchUsers();
  }

  final GetUsersUseCase _getUsersUseCase;
  final GetUserDetailsUseCase _getUserDetailsUseCase;

  Future<void> fetchUsers({int? page, String? search}) async {
    final targetPage = page ?? state.currentPage;
    final targetSearch = search ?? state.searchQuery;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      currentPage: targetPage,
      searchQuery: targetSearch,
    );

    final result = await _getUsersUseCase.execute(
      page: targetPage,
      limit: 10,
      search: targetSearch,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (data) {
        state = state.copyWith(
          isLoading: false,
          users: data.users,
          pagination: data.pagination,
          currentPage: data.pagination.page,
        );
      },
    );
  }

  Future<void> onSearch(String query) async {
    await fetchUsers(page: 1, search: query);
  }

  Future<void> nextPage() async {
    final pagination = state.pagination;
    if (pagination != null && state.currentPage < pagination.totalPages) {
      await fetchUsers(page: state.currentPage + 1);
    }
  }

  Future<void> previousPage() async {
    if (state.currentPage > 1) {
      await fetchUsers(page: state.currentPage - 1);
    }
  }

  Future<void> fetchUserDetails(String id) async {
    state = state.copyWith(
      isLoadingDetails: true,
      clearDetailsError: true,
      clearSelectedDetails: true,
    );

    final result = await _getUserDetailsUseCase.execute(id);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingDetails: false,
          detailsError: failure.message,
        );
      },
      (details) {
        state = state.copyWith(
          isLoadingDetails: false,
          selectedUserDetails: details,
        );
      },
    );
  }

  void clearSelectedUser() {
    state = state.copyWith(clearSelectedDetails: true, clearDetailsError: true);
  }
}

final usersNotifierProvider =
    StateNotifierProvider<UsersNotifier, UsersState>((ref) {
  final getUsers = ref.watch(getUsersUseCaseProvider);
  final getUserDetails = ref.watch(getUserDetailsUseCaseProvider);
  return UsersNotifier(getUsers, getUserDetails);
});
