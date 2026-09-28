// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MetadataItemModel _$MetadataItemModelFromJson(Map<String, dynamic> json) =>
    MetadataItemModel(
      id: json['id'] as String,
      type: json['type'] as String,
      key: json['key'] as String,
      labelFa: json['labelFa'] as String,
      labelEn: json['labelEn'] as String,
      icon: json['icon'] as String?,
      order: (json['order'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      extraData: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$MetadataItemModelToJson(MetadataItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'key': instance.key,
      'labelFa': instance.labelFa,
      'labelEn': instance.labelEn,
      'icon': instance.icon,
      'order': instance.order,
      'isActive': instance.isActive,
      'metadata': instance.extraData,
    };

MetadataPaginationModel _$MetadataPaginationModelFromJson(
        Map<String, dynamic> json) =>
    MetadataPaginationModel(
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );

Map<String, dynamic> _$MetadataPaginationModelToJson(
        MetadataPaginationModel instance) =>
    <String, dynamic>{
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
      'totalPages': instance.totalPages,
    };

MetadataListResponseModel _$MetadataListResponseModelFromJson(
        Map<String, dynamic> json) =>
    MetadataListResponseModel(
      success: json['success'] as bool,
      items: (json['items'] as List<dynamic>?)
              ?.map(
                  (e) => MetadataItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      pagination: json['pagination'] == null
          ? null
          : MetadataPaginationModel.fromJson(
              json['pagination'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MetadataListResponseModelToJson(
        MetadataListResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'items': instance.items,
      'pagination': instance.pagination,
    };

MetadataMutationResponseModel _$MetadataMutationResponseModelFromJson(
        Map<String, dynamic> json) =>
    MetadataMutationResponseModel(
      success: json['success'] as bool,
      item: json['item'] == null
          ? null
          : MetadataItemModel.fromJson(json['item'] as Map<String, dynamic>),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$MetadataMutationResponseModelToJson(
        MetadataMutationResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'item': instance.item,
      'message': instance.message,
    };

MetadataVersionResponseModel _$MetadataVersionResponseModelFromJson(
        Map<String, dynamic> json) =>
    MetadataVersionResponseModel(
      success: json['success'] as bool,
      version: (json['version'] as num).toInt(),
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$MetadataVersionResponseModelToJson(
        MetadataVersionResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'version': instance.version,
      'updatedAt': instance.updatedAt,
    };

MetadataActionResponseModel _$MetadataActionResponseModelFromJson(
        Map<String, dynamic> json) =>
    MetadataActionResponseModel(
      success: json['success'] as bool,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$MetadataActionResponseModelToJson(
        MetadataActionResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
    };
