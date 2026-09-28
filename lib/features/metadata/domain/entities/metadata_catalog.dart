import 'metadata_item.dart';

class MetadataCatalog {
  const MetadataCatalog({
    required this.version,
    required this.updatedAt,
    required this.catalog,
  });

  final int version;
  final DateTime updatedAt;
  final Map<String, List<MetadataItem>> catalog;
}

class MetadataListResult {
  const MetadataListResult({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  final List<MetadataItem> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
}
