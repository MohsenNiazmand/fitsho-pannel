import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../features/auth/data/models/admin_auth_response.dart';
import '../../features/auth/data/models/admin_login_request.dart';
import '../../features/dashboard/data/models/dashboard_stats_model.dart';
import '../../features/exercises/data/models/admin_exercise_model.dart';
import '../../features/metadata/data/models/metadata_item_model.dart';
import '../../features/users/data/models/admin_user_model.dart';

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
  Future<UsersResponseModel> getUsers({
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('search') String? search,
  });

  @GET('/api/v1/admin/users/{id}')
  Future<UserDetailsResponseModel> getUserById(@Path('id') String id);

  @POST('/api/v1/admin/users/{id}/reset-quotas')
  Future<UserDetailsResponseModel> resetUserQuotas(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );


  // Exercises
  @GET('/api/v1/admin/exercises')
  Future<ExercisesResponseModel> getExercises({
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('search') String? search,
    @Query('category') String? category,
    @Query('primaryMuscle') String? primaryMuscle,
    @Query('isActive') bool? isActive,
  });

  @POST('/api/v1/admin/exercises')
  Future<ExerciseMutationResponseModel> createExercise(@Body() Map<String, dynamic> body);

  @PUT('/api/v1/admin/exercises/{id}')
  Future<ExerciseMutationResponseModel> updateExercise(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  // Metadata
  @GET('/api/v1/admin/metadata')
  Future<MetadataListResponseModel> getMetadata({
    @Query('type') String? type,
    @Query('isActive') bool? isActive,
    @Query('search') String? search,
    @Query('page') int? page,
    @Query('limit') int? limit,
  });

  @POST('/api/v1/admin/metadata')
  Future<MetadataMutationResponseModel> createMetadata(@Body() Map<String, dynamic> body);

  @PUT('/api/v1/admin/metadata/{id}')
  Future<MetadataMutationResponseModel> updateMetadata(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/api/v1/admin/metadata/{id}')
  Future<MetadataActionResponseModel> deleteMetadata(@Path('id') String id);

  @PATCH('/api/v1/admin/metadata/reorder')
  Future<MetadataActionResponseModel> reorderMetadata(@Body() Map<String, dynamic> body);

  @GET('/api/v1/metadata/version')
  Future<MetadataVersionResponseModel> getMetadataVersion();
}
