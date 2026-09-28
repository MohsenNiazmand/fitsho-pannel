import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/metadata_catalog.dart';
import '../entities/metadata_item.dart';

abstract class MetadataRepository {
  Future<Either<Failure, MetadataListResult>> getMetadataItems({
    String? type,
    bool? isActive,
    String? search,
    int page = 1,
    int limit = 50,
  });

  Future<Either<Failure, MetadataItem>> createMetadataItem(Map<String, dynamic> data);

  Future<Either<Failure, MetadataItem>> updateMetadataItem(String id, Map<String, dynamic> data);

  Future<Either<Failure, bool>> deleteMetadataItem(String id);

  Future<Either<Failure, bool>> reorderMetadataItems(String type, List<String> orderedIds);

  Future<Either<Failure, int>> getCurrentVersion();
}
