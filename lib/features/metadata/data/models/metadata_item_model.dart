import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/metadata_catalog.dart';
import '../../domain/entities/metadata_item.dart';

part 'metadata_item_model.g.dart';

@JsonSerializable()
class MetadataItemModel {
  const MetadataItemModel({
    required this.id,
    required this.type,
    required this.key,
    required this.labelFa,
    required this.labelEn,
    this.icon,
    this.order = 0,
    this.isActive = true,
    @JsonKey(name: 'metadata') this.extraData,
  });

  factory MetadataItemModel.fromJson(Map<String, dynamic> json) =>
      _$MetadataItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$MetadataItemModelToJson(this);

  final String id;
  final String type;
  final String key;
  final String labelFa;
  final String labelEn;
  final String? icon;
  final int order;
  final bool isActive;
  @JsonKey(name: 'metadata')
  final Map<String, dynamic>? extraData;

  MetadataItem toEntity() {
    return MetadataItem(
      id: id,
      type: type,
      key: key,
      labelFa: labelFa,
      labelEn: labelEn,
      icon: icon,
      order: order,
      isActive: isActive,
      extraData: extraData,
    );
  }
}

@JsonSerializable()
class MetadataPaginationModel {
  const MetadataPaginationModel({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory MetadataPaginationModel.fromJson(Map<String, dynamic> json) =>
      _$MetadataPaginationModelFromJson(json);

  Map<String, dynamic> toJson() => _$MetadataPaginationModelToJson(this);

  final int total;
  final int page;
  final int limit;
  final int totalPages;
}

@JsonSerializable()
class MetadataListResponseModel {
  const MetadataListResponseModel({
    required this.success,
    this.items = const [],
    this.pagination,
  });

  factory MetadataListResponseModel.fromJson(Map<String, dynamic> json) =>
      _$MetadataListResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$MetadataListResponseModelToJson(this);

  final bool success;
  final List<MetadataItemModel> items;
  final MetadataPaginationModel? pagination;

  MetadataListResult toEntity() {
    return MetadataListResult(
      items: items.map((e) => e.toEntity()).toList(),
      total: pagination?.total ?? items.length,
      page: pagination?.page ?? 1,
      limit: pagination?.limit ?? items.length,
      totalPages: pagination?.totalPages ?? 1,
    );
  }
}

@JsonSerializable()
class MetadataMutationResponseModel {
  const MetadataMutationResponseModel({
    required this.success,
    this.item,
    this.message,
  });

  factory MetadataMutationResponseModel.fromJson(Map<String, dynamic> json) =>
      _$MetadataMutationResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$MetadataMutationResponseModelToJson(this);

  final bool success;
  final MetadataItemModel? item;
  final String? message;

  MetadataItem toEntity() {
    if (item == null) {
      throw Exception('Metadata item not present in response');
    }
    return item!.toEntity();
  }
}

@JsonSerializable()
class MetadataVersionResponseModel {
  const MetadataVersionResponseModel({
    required this.success,
    required this.version,
    this.updatedAt,
  });

  factory MetadataVersionResponseModel.fromJson(Map<String, dynamic> json) =>
      _$MetadataVersionResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$MetadataVersionResponseModelToJson(this);

  final bool success;
  final int version;
  final String? updatedAt;
}

@JsonSerializable()
class MetadataActionResponseModel {
  const MetadataActionResponseModel({
    required this.success,
    this.message,
  });

  factory MetadataActionResponseModel.fromJson(Map<String, dynamic> json) =>
      _$MetadataActionResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$MetadataActionResponseModelToJson(this);

  final bool success;
  final String? message;
}
