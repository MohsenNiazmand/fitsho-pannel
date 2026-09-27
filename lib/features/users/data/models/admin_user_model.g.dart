// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminUserCountModel _$AdminUserCountModelFromJson(Map<String, dynamic> json) =>
    AdminUserCountModel(
      workoutPlans: (json['workoutPlans'] as num?)?.toInt() ?? 0,
      dietPlans: (json['dietPlans'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$AdminUserCountModelToJson(
        AdminUserCountModel instance) =>
    <String, dynamic>{
      'workoutPlans': instance.workoutPlans,
      'dietPlans': instance.dietPlans,
    };

AdminUserModel _$AdminUserModelFromJson(Map<String, dynamic> json) =>
    AdminUserModel(
      id: json['id'] as String,
      mobile: json['mobile'] as String,
      name: json['name'] as String?,
      role: json['role'] as String? ?? 'USER',
      createdAt: json['createdAt'] as String,
      count: json['_count'] == null
          ? null
          : AdminUserCountModel.fromJson(
              json['_count'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AdminUserModelToJson(AdminUserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mobile': instance.mobile,
      'name': instance.name,
      'role': instance.role,
      'createdAt': instance.createdAt,
      '_count': instance.count,
    };

UserPaginationModel _$UserPaginationModelFromJson(Map<String, dynamic> json) =>
    UserPaginationModel(
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );

Map<String, dynamic> _$UserPaginationModelToJson(
        UserPaginationModel instance) =>
    <String, dynamic>{
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
      'totalPages': instance.totalPages,
    };

UsersDataModel _$UsersDataModelFromJson(Map<String, dynamic> json) =>
    UsersDataModel(
      users: (json['users'] as List<dynamic>)
          .map((e) => AdminUserModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: UserPaginationModel.fromJson(
          json['pagination'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UsersDataModelToJson(UsersDataModel instance) =>
    <String, dynamic>{
      'users': instance.users,
      'pagination': instance.pagination,
    };

UsersResponseModel _$UsersResponseModelFromJson(Map<String, dynamic> json) =>
    UsersResponseModel(
      success: json['success'] as bool,
      data: UsersDataModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UsersResponseModelToJson(UsersResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
    };

UserDetailsDataModel _$UserDetailsDataModelFromJson(
        Map<String, dynamic> json) =>
    UserDetailsDataModel(
      id: json['id'] as String,
      mobile: json['mobile'] as String,
      name: json['name'] as String?,
      role: json['role'] as String? ?? 'USER',
      createdAt: json['createdAt'] as String,
      dietProfile: json['dietProfile'] as Map<String, dynamic>?,
      workoutProfile: json['workoutProfile'] as Map<String, dynamic>?,
      workoutPlans: json['workoutPlans'] as List<dynamic>?,
      dietPlans: json['dietPlans'] as List<dynamic>?,
    );

Map<String, dynamic> _$UserDetailsDataModelToJson(
        UserDetailsDataModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mobile': instance.mobile,
      'name': instance.name,
      'role': instance.role,
      'createdAt': instance.createdAt,
      'dietProfile': instance.dietProfile,
      'workoutProfile': instance.workoutProfile,
      'workoutPlans': instance.workoutPlans,
      'dietPlans': instance.dietPlans,
    };

UserDetailsResponseModel _$UserDetailsResponseModelFromJson(
        Map<String, dynamic> json) =>
    UserDetailsResponseModel(
      success: json['success'] as bool,
      data: UserDetailsDataModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserDetailsResponseModelToJson(
        UserDetailsResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
    };
