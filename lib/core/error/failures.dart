abstract class Failure {
  const Failure(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'عدم دسترسی به اینترنت یا سرور']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'اطلاعات ورود نامعتبر است یا جلسه کاری منقضی شده است']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'خطا در حافظه محلی']);
}
