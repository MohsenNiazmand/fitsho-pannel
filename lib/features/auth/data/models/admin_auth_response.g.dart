// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_auth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminUserModel _$AdminUserModelFromJson(Map<String, dynamic> json) =>
    AdminUserModel(
      id: json['id'] as String,
      mobile: json['mobile'] as String,
      name: json['name'] as String?,
      role: json['role'] as String? ?? 'ADMIN',
    );

Map<String, dynamic> _$AdminUserModelToJson(AdminUserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mobile': instance.mobile,
      'name': instance.name,
      'role': instance.role,
    };

AdminAuthResponse _$AdminAuthResponseFromJson(Map<String, dynamic> json) =>
    AdminAuthResponse(
      success: json['success'] as bool,
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      user: json['user'] == null
          ? null
          : AdminUserModel.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AdminAuthResponseToJson(AdminAuthResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'user': instance.user?.toJson(),
    };
