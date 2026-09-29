// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuotaItemModel _$QuotaItemModelFromJson(Map<String, dynamic> json) =>
    QuotaItemModel(
      used: (json['used'] as num?)?.toInt() ?? 0,
      max: (json['max'] as num?)?.toInt() ?? 3,
      remaining: (json['remaining'] as num?)?.toInt() ?? 3,
      swapsUsed: (json['swapsUsed'] as num?)?.toInt() ?? 0,
      swapsMax: (json['swapsMax'] as num?)?.toInt() ?? 5,
      swapsRemaining: (json['swapsRemaining'] as num?)?.toInt() ?? 5,
      lastGeneratedAt: json['lastGeneratedAt'] as String?,
      lastSwappedAt: json['lastSwappedAt'] as String?,
    );

Map<String, dynamic> _$QuotaItemModelToJson(QuotaItemModel instance) =>
    <String, dynamic>{
      'used': instance.used,
      'max': instance.max,
      'remaining': instance.remaining,
      'swapsUsed': instance.swapsUsed,
      'swapsMax': instance.swapsMax,
      'swapsRemaining': instance.swapsRemaining,
      'lastGeneratedAt': instance.lastGeneratedAt,
      'lastSwappedAt': instance.lastSwappedAt,
    };

UserQuotasModel _$UserQuotasModelFromJson(Map<String, dynamic> json) =>
    UserQuotasModel(
      diet: QuotaItemModel.fromJson(json['diet'] as Map<String, dynamic>),
      workout: QuotaItemModel.fromJson(json['workout'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserQuotasModelToJson(UserQuotasModel instance) =>
    <String, dynamic>{
      'diet': instance.diet,
      'workout': instance.workout,
    };

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
      quotas: json['quotas'] == null
          ? null
          : UserQuotasModel.fromJson(json['quotas'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AdminUserModelToJson(AdminUserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mobile': instance.mobile,
      'name': instance.name,
      'role': instance.role,
      'createdAt': instance.createdAt,
      '_count': instance.count,
      'quotas': instance.quotas,
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
      quotas: json['quotas'] == null
          ? null
          : UserQuotasModel.fromJson(json['quotas'] as Map<String, dynamic>),
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
      'quotas': instance.quotas,
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
