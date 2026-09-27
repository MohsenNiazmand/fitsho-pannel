class AdminUser {
  const AdminUser({
    required this.id,
    required this.mobile,
    this.name,
    this.role = 'ADMIN',
  });

  final String id;
  final String mobile;
  final String? name;
  final String role;
}
