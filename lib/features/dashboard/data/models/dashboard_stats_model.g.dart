// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardStatsModel _$DashboardStatsModelFromJson(Map<String, dynamic> json) =>
    DashboardStatsModel(
      totalUsers: (json['totalUsers'] as num?)?.toInt() ?? 0,
      totalWorkoutPlans: (json['totalWorkoutPlans'] as num?)?.toInt() ?? 0,
      totalDietPlans: (json['totalDietPlans'] as num?)?.toInt() ?? 0,
      totalExercises: (json['totalExercises'] as num?)?.toInt() ?? 0,
      activeUsersToday: (json['activeUsersToday'] as num?)?.toInt() ?? 0,
      newUsersToday: (json['newUsersToday'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$DashboardStatsModelToJson(
        DashboardStatsModel instance) =>
    <String, dynamic>{
      'totalUsers': instance.totalUsers,
      'totalWorkoutPlans': instance.totalWorkoutPlans,
      'totalDietPlans': instance.totalDietPlans,
      'totalExercises': instance.totalExercises,
      'activeUsersToday': instance.activeUsersToday,
      'newUsersToday': instance.newUsersToday,
    };

DashboardStatsResponse _$DashboardStatsResponseFromJson(
        Map<String, dynamic> json) =>
    DashboardStatsResponse(
      success: json['success'] as bool,
      data: json['data'] == null
          ? null
          : DashboardStatsModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DashboardStatsResponseToJson(
        DashboardStatsResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data?.toJson(),
    };
