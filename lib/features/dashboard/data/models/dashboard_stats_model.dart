import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/dashboard_stats.dart';

part 'dashboard_stats_model.g.dart';

@JsonSerializable()
class DashboardStatsModel {
  const DashboardStatsModel({
    this.totalUsers = 0,
    this.totalWorkoutPlans = 0,
    this.totalDietPlans = 0,
    this.totalExercises = 0,
    this.activeUsersToday = 0,
    this.newUsersToday = 0,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;

    return DashboardStatsModel(
      totalUsers: (data['totalUsers'] as num?)?.toInt() ?? 0,
      totalWorkoutPlans: (data['totalWorkoutPlans'] as num?)?.toInt() ?? 0,
      totalDietPlans: (data['totalDietPlans'] as num?)?.toInt() ?? 0,
      totalExercises: (data['totalExercises'] as num?)?.toInt() ?? 0,
      activeUsersToday: (data['activeUsersToday'] as num?)?.toInt() ?? 0,
      newUsersToday: (data['newUsersToday'] as num?)?.toInt() ?? 0,
    );
  }

  final int totalUsers;
  final int totalWorkoutPlans;
  final int totalDietPlans;
  final int totalExercises;
  final int activeUsersToday;
  final int newUsersToday;

  Map<String, dynamic> toJson() => _$DashboardStatsModelToJson(this);

  DashboardStats toEntity() => DashboardStats(
        totalUsers: totalUsers,
        totalWorkoutPlans: totalWorkoutPlans,
        totalDietPlans: totalDietPlans,
        totalExercises: totalExercises,
        activeUsersToday: activeUsersToday,
        newUsersToday: newUsersToday,
      );
}

@JsonSerializable(explicitToJson: true)
class DashboardStatsResponse {
  const DashboardStatsResponse({
    required this.success,
    this.data,
  });

  factory DashboardStatsResponse.fromJson(Map<String, dynamic> json) {
    return DashboardStatsResponse(
      success: json['success'] as bool? ?? true,
      data: DashboardStatsModel.fromJson(json),
    );
  }

  final bool success;
  final DashboardStatsModel? data;

  Map<String, dynamic> toJson() => _$DashboardStatsResponseToJson(this);
}
