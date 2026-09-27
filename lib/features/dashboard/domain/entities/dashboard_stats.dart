class DashboardStats {
  const DashboardStats({
    required this.totalUsers,
    required this.totalWorkoutPlans,
    required this.totalDietPlans,
    required this.totalExercises,
    required this.activeUsersToday,
    required this.newUsersToday,
  });

  final int totalUsers;
  final int totalWorkoutPlans;
  final int totalDietPlans;
  final int totalExercises;
  final int activeUsersToday;
  final int newUsersToday;
}
