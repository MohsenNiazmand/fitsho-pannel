class AdminUserItem {
  const AdminUserItem({
    required this.id,
    required this.mobile,
    this.name,
    required this.role,
    required this.createdAt,
    this.workoutPlansCount = 0,
    this.dietPlansCount = 0,
  });

  final String id;
  final String mobile;
  final String? name;
  final String role;
  final DateTime createdAt;
  final int workoutPlansCount;
  final int dietPlansCount;
}

class UserPagination {
  const UserPagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  final int total;
  final int page;
  final int limit;
  final int totalPages;
}

class AdminUsersResult {
  const AdminUsersResult({
    required this.users,
    required this.pagination,
  });

  final List<AdminUserItem> users;
  final UserPagination pagination;
}
