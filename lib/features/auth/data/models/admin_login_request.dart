import 'package:json_annotation/json_annotation.dart';

part 'admin_login_request.g.dart';

@JsonSerializable()
class AdminLoginRequest {
  const AdminLoginRequest({
    required this.username,
    required this.password,
  });

  factory AdminLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$AdminLoginRequestFromJson(json);

  final String username;
  final String password;

  Map<String, dynamic> toJson() => _$AdminLoginRequestToJson(this);
}
