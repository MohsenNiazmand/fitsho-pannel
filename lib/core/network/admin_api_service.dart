import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../features/auth/data/models/admin_auth_response.dart';
import '../../features/auth/data/models/admin_login_request.dart';
import '../../features/dashboard/data/models/dashboard_stats_model.dart';

part 'admin_api_service.g.dart';

@RestApi()
abstract class AdminApiService {
  factory AdminApiService(Dio dio, {String baseUrl}) = _AdminApiService;

  // Auth
  @POST('/api/v1/admin/auth/login')
  Future<AdminAuthResponse> login(@Body() AdminLoginRequest request);

  // Dashboard
  @GET('/api/v1/admin/dashboard/stats')
  Future<DashboardStatsResponse> getDashboardStats();

  // Users
  @GET('/api/v1/admin/users')
  Future<dynamic> getUsers({
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('search') String? search,
  });

  @GET('/api/v1/admin/users/{id}')
  Future<dynamic> getUserById(@Path('id') String id);

  // Exercises
  @GET('/api/v1/admin/exercises')
  Future<dynamic> getExercises({
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('search') String? search,
    @Query('category') String? category,
    @Query('primaryMuscle') String? primaryMuscle,
    @Query('isActive') bool? isActive,
  });

  @POST('/api/v1/admin/exercises')
  Future<dynamic> createExercise(@Body() Map<String, dynamic> body);

  @PUT('/api/v1/admin/exercises/{id}')
  Future<dynamic> updateExercise(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );
}
