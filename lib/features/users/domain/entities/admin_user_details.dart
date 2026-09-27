class AdminUserDetails {
  const AdminUserDetails({
    required this.id,
    required this.mobile,
    this.name,
    required this.role,
    required this.createdAt,
    this.dietProfile,
    this.workoutProfile,
    this.workoutPlansCount = 0,
    this.dietPlansCount = 0,
  });

  final String id;
  final String mobile;
  final String? name;
  final String role;
  final DateTime createdAt;
  final Map<String, dynamic>? dietProfile;
  final Map<String, dynamic>? workoutProfile;
  final int workoutPlansCount;
  final int dietPlansCount;
}
