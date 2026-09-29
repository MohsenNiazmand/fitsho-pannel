import 'package:json_annotation/json_annotation.dart';
import 'package:fitsho_pannel/features/users/domain/entities/admin_user_details.dart';
import 'package:fitsho_pannel/features/users/domain/entities/admin_user_item.dart';
import 'package:fitsho_pannel/features/users/domain/entities/user_quotas.dart';

part 'admin_user_model.g.dart';

@JsonSerializable()
class QuotaItemModel {
  const QuotaItemModel({
    this.used = 0,
    this.max = 3,
    this.remaining = 3,
    this.swapsUsed = 0,
    this.swapsMax = 5,
    this.swapsRemaining = 5,
    this.lastGeneratedAt,
    this.lastSwappedAt,
  });

  factory QuotaItemModel.fromJson(Map<String, dynamic> json) =>
      _$QuotaItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuotaItemModelToJson(this);

  final int used;
  final int max;
  final int remaining;
  final int swapsUsed;
  final int swapsMax;
  final int swapsRemaining;
  final String? lastGeneratedAt;
  final String? lastSwappedAt;

  QuotaItem toEntity() => QuotaItem(
        used: used,
        max: max,
        remaining: remaining,
        swapsUsed: swapsUsed,
        swapsMax: swapsMax,
        swapsRemaining: swapsRemaining,
        lastGeneratedAt: lastGeneratedAt,
        lastSwappedAt: lastSwappedAt,
      );
}

@JsonSerializable()
class UserQuotasModel {
  const UserQuotasModel({
    required this.diet,
    required this.workout,
  });

  factory UserQuotasModel.fromJson(Map<String, dynamic> json) =>
      _$UserQuotasModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserQuotasModelToJson(this);

  final QuotaItemModel diet;
  final QuotaItemModel workout;

  UserQuotas toEntity() => UserQuotas(
        diet: diet.toEntity(),
        workout: workout.toEntity(),
      );
}

@JsonSerializable()
class AdminUserCountModel {
  const AdminUserCountModel({
    this.workoutPlans = 0,
    this.dietPlans = 0,
  });

  factory AdminUserCountModel.fromJson(Map<String, dynamic> json) =>
      _$AdminUserCountModelFromJson(json);

  Map<String, dynamic> toJson() => _$AdminUserCountModelToJson(this);

  final int workoutPlans;
  final int dietPlans;
}

@JsonSerializable()
class AdminUserModel {
  const AdminUserModel({
    required this.id,
    required this.mobile,
    this.name,
    this.role = 'USER',
    required this.createdAt,
    this.count,
    this.quotas,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) =>
      _$AdminUserModelFromJson(json);

  Map<String, dynamic> toJson() => _$AdminUserModelToJson(this);

  final String id;
  final String mobile;
  final String? name;
  final String role;
  final String createdAt;
  @JsonKey(name: '_count')
  final AdminUserCountModel? count;
  final UserQuotasModel? quotas;

  AdminUserItem toEntity() {
    return AdminUserItem(
      id: id,
      mobile: mobile,
      name: name,
      role: role,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      workoutPlansCount: count?.workoutPlans ?? 0,
      dietPlansCount: count?.dietPlans ?? 0,
      quotas: quotas?.toEntity(),
    );
  }
}


@JsonSerializable()
class UserPaginationModel {
  const UserPaginationModel({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory UserPaginationModel.fromJson(Map<String, dynamic> json) =>
      _$UserPaginationModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserPaginationModelToJson(this);

  final int total;
  final int page;
  final int limit;
  final int totalPages;

  UserPagination toEntity() {
    return UserPagination(
      total: total,
      page: page,
      limit: limit,
      totalPages: totalPages,
    );
  }
}

@JsonSerializable()
class UsersDataModel {
  const UsersDataModel({
    required this.users,
    required this.pagination,
  });

  factory UsersDataModel.fromJson(Map<String, dynamic> json) =>
      _$UsersDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$UsersDataModelToJson(this);

  final List<AdminUserModel> users;
  final UserPaginationModel pagination;
}

@JsonSerializable()
class UsersResponseModel {
  const UsersResponseModel({
    required this.success,
    required this.data,
  });

  factory UsersResponseModel.fromJson(Map<String, dynamic> json) =>
      _$UsersResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$UsersResponseModelToJson(this);

  final bool success;
  final UsersDataModel data;

  AdminUsersResult toEntity() {
    return AdminUsersResult(
      users: data.users.map((u) => u.toEntity()).toList(),
      pagination: data.pagination.toEntity(),
    );
  }
}

@JsonSerializable()
class UserDetailsDataModel {
  const UserDetailsDataModel({
    required this.id,
    required this.mobile,
    this.name,
    this.role = 'USER',
    required this.createdAt,
    this.dietProfile,
    this.workoutProfile,
    this.workoutPlans,
    this.dietPlans,
    this.quotas,
  });

  factory UserDetailsDataModel.fromJson(Map<String, dynamic> json) =>
      _$UserDetailsDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserDetailsDataModelToJson(this);

  final String id;
  final String mobile;
  final String? name;
  final String role;
  final String createdAt;
  final Map<String, dynamic>? dietProfile;
  final Map<String, dynamic>? workoutProfile;
  final List<dynamic>? workoutPlans;
  final List<dynamic>? dietPlans;
  final UserQuotasModel? quotas;

  AdminUserDetails toEntity() {
    return AdminUserDetails(
      id: id,
      mobile: mobile,
      name: name,
      role: role,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      dietProfile: dietProfile,
      workoutProfile: workoutProfile,
      workoutPlansCount: workoutPlans?.length ?? 0,
      dietPlansCount: dietPlans?.length ?? 0,
      quotas: quotas?.toEntity(),
    );
  }
}


@JsonSerializable()
class UserDetailsResponseModel {
  const UserDetailsResponseModel({
    required this.success,
    required this.data,
  });

  factory UserDetailsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$UserDetailsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserDetailsResponseModelToJson(this);

  final bool success;
  final UserDetailsDataModel data;

  AdminUserDetails toEntity() => data.toEntity();
}
