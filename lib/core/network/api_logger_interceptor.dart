import 'dart:developer' as developer;
import 'package:dio/dio.dart';

class ApiLoggerInterceptor extends Interceptor {
  final Map<int, DateTime> _requestTimestamps = {};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _requestTimestamps[options.hashCode] = DateTime.now();

    final buffer = StringBuffer();
    buffer.write('🌐 [HTTP REQ] ${options.method} ${options.uri}');
    if (options.queryParameters.isNotEmpty) {
      buffer.write(' | Query: ${options.queryParameters}');
    }
    if (options.data != null) {
      // Don't log sensitive passwords
      if (options.data is Map && options.data.containsKey('password')) {
        final sanitized = Map<String, dynamic>.from(options.data as Map);
        sanitized['password'] = '******';
        buffer.write(' | Body: $sanitized');
      } else {
        buffer.write(' | Body: ${options.data}');
      }
    }

    developer.log(buffer.toString(), name: 'FitShoAdmin.Http');
    // Also print to console for IDE/terminal visibility
    // ignore: avoid_print
    print('[HTTP] --> ${options.method} ${options.uri}');

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime = _requestTimestamps.remove(response.requestOptions.hashCode);
    final duration = startTime != null
        ? DateTime.now().difference(startTime).inMilliseconds
        : null;

    final durationStr = duration != null ? ' (${duration}ms)' : '';
    final message = '✅ [HTTP RES ${response.statusCode}] ${response.requestOptions.method} ${response.requestOptions.uri}$durationStr';

    developer.log(message, name: 'FitShoAdmin.Http');
    // ignore: avoid_print
    print('[HTTP] <-- ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}$durationStr');

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final startTime = _requestTimestamps.remove(err.requestOptions.hashCode);
    final duration = startTime != null
        ? DateTime.now().difference(startTime).inMilliseconds
        : null;

    final durationStr = duration != null ? ' (${duration}ms)' : '';
    final status = err.response?.statusCode ?? 'NO_STATUS';
    final errorMsg = err.response?.data is Map && err.response?.data['message'] != null
        ? err.response?.data['message']
        : err.message ?? err.error ?? 'Unknown error';

    final message = '❌ [HTTP ERR $status] ${err.requestOptions.method} ${err.requestOptions.uri}$durationStr | Error: $errorMsg';

    developer.log(message, name: 'FitShoAdmin.Http', error: err);
    // ignore: avoid_print
    print('[HTTP] <X- ERROR $status ${err.requestOptions.method} ${err.requestOptions.uri}$durationStr: $errorMsg');

    handler.next(err);
  }
}
