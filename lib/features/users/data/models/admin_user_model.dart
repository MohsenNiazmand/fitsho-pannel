import 'package:json_annotation/json_annotation.dart';
import 'package:fitsho_pannel/features/users/domain/entities/admin_user_details.dart';
import 'package:fitsho_pannel/features/users/domain/entities/admin_user_item.dart';

part 'admin_user_model.g.dart';

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

  AdminUserItem toEntity() {
    return AdminUserItem(
      id: id,
      mobile: mobile,
      name: name,
      role: role,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      workoutPlansCount: count?.workoutPlans ?? 0,
      dietPlansCount: count?.dietPlans ?? 0,
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
