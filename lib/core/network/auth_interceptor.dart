import 'dart:async';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../storage/token_storage.dart';

class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required TokenStorage tokenStorage,
    required Dio dio,
  })  : _tokenStorage = tokenStorage,
        _dio = dio,
        _refreshDio = Dio(
          BaseOptions(
            baseUrl: dio.options.baseUrl,
            connectTimeout: dio.options.connectTimeout,
            receiveTimeout: dio.options.receiveTimeout,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

  final TokenStorage _tokenStorage;
  final Dio _dio;
  final Dio _refreshDio;

  static Future<bool>? _refreshFuture;

  static const _noAuthHeaderPaths = {
    '/api/v1/admin/auth/login',
    '/api/v1/auth/refresh',
    '/health',
  };

  static const _noRefreshOn401Paths = {
    '/api/v1/admin/auth/login',
    '/api/v1/auth/refresh',
  };

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final path = options.path;
    final isExcluded = _noAuthHeaderPaths.any((p) => path.contains(p));

    if (!isExcluded) {
      final accessToken = await _tokenStorage.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;
    final isExcluded = _noRefreshOn401Paths.any((p) => path.contains(p));
    final shouldRefresh = statusCode == 401 &&
        !isExcluded &&
        err.requestOptions.extra['_retried'] != true;

    if (!shouldRefresh) {
      if (statusCode == 401 && isExcluded && path.contains('/auth/refresh')) {
        // Refresh token failed -> session truly expired
        developer.log('⚠️ [AUTH] Refresh token expired or rejected. Clearing session.', name: 'FitShoAdmin.Auth');
        // ignore: avoid_print
        print('[AUTH] ⚠️ Refresh token expired. Clearing session.');
        await _tokenStorage.clear();
      }
      handler.next(err);
      return;
    }

    developer.log('🔄 [AUTH] Access token expired on $path -> Attempting silent token refresh...', name: 'FitShoAdmin.Auth');
    // ignore: avoid_print
    print('[AUTH] 🔄 401 on $path -> Attempting automatic token refresh...');

    final refreshed = await _tryRefreshToken();
    if (!refreshed) {
      developer.log('❌ [AUTH] Token refresh failed. Clearing credentials.', name: 'FitShoAdmin.Auth');
      // ignore: avoid_print
      print('[AUTH] ❌ Token refresh failed. Clearing stored tokens.');
      await _tokenStorage.clear();
      handler.next(err);
      return;
    }

    developer.log('🎉 [AUTH] Token refreshed successfully! Retrying original request: $path', name: 'FitShoAdmin.Auth');
    // ignore: avoid_print
    print('[AUTH] 🎉 Token refreshed successfully! Retrying: $path');

    try {
      final newAccessToken = await _tokenStorage.getAccessToken();
      final requestOptions = err.requestOptions;
      requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      requestOptions.extra['_retried'] = true;

      final response = await _dio.fetch<dynamic>(requestOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      if (retryError.response?.statusCode == 401) {
        developer.log('❌ [AUTH] Retry still resulted in 401. Clearing session.', name: 'FitShoAdmin.Auth');
        await _tokenStorage.clear();
      }
      handler.next(retryError);
    } catch (e) {
      handler.next(err);
    }
  }

  Future<bool> _tryRefreshToken() async {
    if (_refreshFuture != null) {
      return _refreshFuture!;
    }

    _refreshFuture = _performRefresh();
    try {
      return await _refreshFuture!;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<bool> _performRefresh() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      developer.log('⚠️ [AUTH] No refresh token found in storage.', name: 'FitShoAdmin.Auth');
      return false;
    }

    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        '/api/v1/auth/refresh',
        data: {
          'refreshToken': refreshToken,
          'deviceId': 'admin-web',
        },
      );

      final data = response.data;
      final accessToken = data?['accessToken'] as String? ??
          (data?['data'] as Map<String, dynamic>?)?['accessToken'] as String?;
      final newRefreshToken = data?['refreshToken'] as String? ??
          (data?['data'] as Map<String, dynamic>?)?['refreshToken'] as String?;

      if (accessToken == null || accessToken.isEmpty) {
        return false;
      }

      await _tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: newRefreshToken ?? refreshToken,
      );

      return true;
    } catch (e) {
      developer.log('❌ [AUTH] Refresh API error: $e', name: 'FitShoAdmin.Auth');
      return false;
    }
  }
}
