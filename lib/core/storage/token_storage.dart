import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

abstract class TokenStorage {
  Future<void> saveTokens({required String accessToken, String? refreshToken});
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clear();
  Future<bool> hasToken();
  Future<void> saveUserJson(String jsonString);
  Future<String?> getUserJson();
}

class TokenStorageImpl implements TokenStorage {
  TokenStorageImpl(this._secureStorage, this._prefs);

  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  @override
  Future<void> saveTokens({required String accessToken, String? refreshToken}) async {
    await _secureStorage.write(key: AppConstants.adminTokenKey, value: accessToken);
    if (refreshToken != null) {
      await _secureStorage.write(key: AppConstants.adminRefreshTokenKey, value: refreshToken);
    }
    // Also save in prefs for fast synchronous/web fallback
    await _prefs.setString(AppConstants.adminTokenKey, accessToken);
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      final token = await _secureStorage.read(key: AppConstants.adminTokenKey);
      if (token != null) return token;
    } catch (_) {}
    return _prefs.getString(AppConstants.adminTokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: AppConstants.adminRefreshTokenKey);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _secureStorage.delete(key: AppConstants.adminTokenKey);
      await _secureStorage.delete(key: AppConstants.adminRefreshTokenKey);
    } catch (_) {}
    await _prefs.remove(AppConstants.adminTokenKey);
    await _prefs.remove(AppConstants.adminUserKey);
  }

  @override
  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> saveUserJson(String jsonString) async {
    await _prefs.setString(AppConstants.adminUserKey, jsonString);
  }

  @override
  Future<String?> getUserJson() async {
    return _prefs.getString(AppConstants.adminUserKey);
  }
}
