import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/admin_user.dart';

part 'admin_auth_response.g.dart';

@JsonSerializable()
class AdminUserModel {
  const AdminUserModel({
    required this.id,
    required this.mobile,
    this.name,
    this.role = 'ADMIN',
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) =>
      _$AdminUserModelFromJson(json);

  final String id;
  final String mobile;
  final String? name;
  final String role;

  Map<String, dynamic> toJson() => _$AdminUserModelToJson(this);

  AdminUser toEntity() => AdminUser(
        id: id,
        mobile: mobile,
        name: name,
        role: role,
      );
}

@JsonSerializable(explicitToJson: true)
class AdminAuthResponse {
  const AdminAuthResponse({
    required this.success,
    this.accessToken,
    this.refreshToken,
    this.user,
  });

  factory AdminAuthResponse.fromJson(Map<String, dynamic> json) {
    // Backend returns both at top level and in `data`
    final dataMap = json['data'] as Map<String, dynamic>?;
    final token = json['accessToken'] as String? ?? dataMap?['accessToken'] as String?;
    final refresh = json['refreshToken'] as String? ?? dataMap?['refreshToken'] as String?;
    
    AdminUserModel? userModel;
    if (json['user'] != null) {
      userModel = AdminUserModel.fromJson(json['user'] as Map<String, dynamic>);
    } else if (dataMap?['user'] != null) {
      userModel = AdminUserModel.fromJson(dataMap!['user'] as Map<String, dynamic>);
    }

    return AdminAuthResponse(
      success: json['success'] as bool? ?? true,
      accessToken: token,
      refreshToken: refresh,
      user: userModel,
    );
  }

  final bool success;
  final String? accessToken;
  final String? refreshToken;
  final AdminUserModel? user;

  Map<String, dynamic> toJson() => _$AdminAuthResponseToJson(this);
}
