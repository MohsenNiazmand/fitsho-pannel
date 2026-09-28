import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/admin_api_service.dart';
import '../../domain/entities/metadata_catalog.dart';
import '../../domain/entities/metadata_item.dart';
import '../../domain/repositories/metadata_repository.dart';

class MetadataRepositoryImpl implements MetadataRepository {
  const MetadataRepositoryImpl(this._apiService);

  final AdminApiService _apiService;

  @override
  Future<Either<Failure, MetadataListResult>> getMetadataItems({
    String? type,
    bool? isActive,
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _apiService.getMetadata(
        type: (type != null && type.trim().isNotEmpty) ? type.trim() : null,
        isActive: isActive,
        search: (search != null && search.trim().isNotEmpty) ? search.trim() : null,
        page: page,
        limit: limit,
      );
      return right(response.toEntity());
    } on DioException catch (e) {
      final message = e.response?.data is Map && e.response?.data['message'] != null
          ? e.response?.data['message'].toString()
          : e.message ?? 'خطا در دریافت لیست متادیتا';
      return left(ServerFailure(message ?? 'خطا در برقراری ارتباط'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MetadataItem>> createMetadataItem(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.createMetadata(data);
      return right(response.toEntity());
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return left(const ServerFailure('آیتم متادیتا با این کلید قبلاً ثبت شده است'));
      }
      final message = e.response?.data is Map && e.response?.data['message'] != null
          ? e.response?.data['message'].toString()
          : e.message ?? 'خطا در ایجاد آیتم متادیتا';
      return left(ServerFailure(message ?? 'خطا در برقراری ارتباط'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MetadataItem>> updateMetadataItem(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.updateMetadata(id, data);
      return right(response.toEntity());
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return left(const NotFoundFailure('آیتم متادیتا یافت نشد'));
      }
      if (e.response?.statusCode == 409) {
        return left(const ServerFailure('کلید وارد شده برای این نوع متادیتا تکراری است'));
      }
      final message = e.response?.data is Map && e.response?.data['message'] != null
          ? e.response?.data['message'].toString()
          : e.message ?? 'خطا در ویرایش آیتم متادیتا';
      return left(ServerFailure(message ?? 'خطا در برقراری ارتباط'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteMetadataItem(String id) async {
    try {
      await _apiService.deleteMetadata(id);
      return right(true);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return left(const NotFoundFailure('آیتم متادیتا یافت نشد'));
      }
      final message = e.response?.data is Map && e.response?.data['message'] != null
          ? e.response?.data['message'].toString()
          : e.message ?? 'خطا در حذف آیتم متادیتا';
      return left(ServerFailure(message ?? 'خطا در برقراری ارتباط'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> reorderMetadataItems(
    String type,
    List<String> orderedIds,
  ) async {
    try {
      await _apiService.reorderMetadata({
        'type': type,
        'orderedIds': orderedIds,
      });
      return right(true);
    } on DioException catch (e) {
      final message = e.response?.data is Map && e.response?.data['message'] != null
          ? e.response?.data['message'].toString()
          : e.message ?? 'خطا در بروزرسانی ترتیب متادیتا';
      return left(ServerFailure(message ?? 'خطا در برقراری ارتباط'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getCurrentVersion() async {
    try {
      final response = await _apiService.getMetadataVersion();
      return right(response.version);
    } on DioException catch (e) {
      final message = e.response?.data is Map && e.response?.data['message'] != null
          ? e.response?.data['message'].toString()
          : e.message ?? 'خطا در دریافت نسخه متادیتا';
      return left(ServerFailure(message ?? 'خطا در برقراری ارتباط'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
