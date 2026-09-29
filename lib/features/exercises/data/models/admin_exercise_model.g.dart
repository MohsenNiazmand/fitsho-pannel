// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_exercise_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminExerciseModel _$AdminExerciseModelFromJson(Map<String, dynamic> json) =>
    AdminExerciseModel(
      id: json['id'] as String,
      key: json['key'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      pattern: json['pattern'] as String,
      primaryMuscle: json['primaryMuscle'] as String,
      secondaryMuscles: (json['secondaryMuscles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      equipment: (json['equipment'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      locations: (json['locations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      levels: (json['levels'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      disciplines: (json['disciplines'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      contraindications: (json['contraindications'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isCustomized: json['isCustomized'] as bool? ?? false,
      cue: json['cue'] as String?,
      gifUrl: json['gifUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$AdminExerciseModelToJson(AdminExerciseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'name': instance.name,
      'category': instance.category,
      'pattern': instance.pattern,
      'primaryMuscle': instance.primaryMuscle,
      'secondaryMuscles': instance.secondaryMuscles,
      'equipment': instance.equipment,
      'locations': instance.locations,
      'levels': instance.levels,
      'disciplines': instance.disciplines,
      'contraindications': instance.contraindications,
      'isCustomized': instance.isCustomized,
      'cue': instance.cue,
      'gifUrl': instance.gifUrl,
      'videoUrl': instance.videoUrl,
      'isActive': instance.isActive,
    };

ExercisePaginationModel _$ExercisePaginationModelFromJson(
        Map<String, dynamic> json) =>
    ExercisePaginationModel(
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );

Map<String, dynamic> _$ExercisePaginationModelToJson(
        ExercisePaginationModel instance) =>
    <String, dynamic>{
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
      'totalPages': instance.totalPages,
    };

ExercisesDataModel _$ExercisesDataModelFromJson(Map<String, dynamic> json) =>
    ExercisesDataModel(
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => AdminExerciseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: ExercisePaginationModel.fromJson(
          json['pagination'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ExercisesDataModelToJson(ExercisesDataModel instance) =>
    <String, dynamic>{
      'exercises': instance.exercises,
      'pagination': instance.pagination,
    };

ExercisesResponseModel _$ExercisesResponseModelFromJson(
        Map<String, dynamic> json) =>
    ExercisesResponseModel(
      success: json['success'] as bool,
      data: ExercisesDataModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ExercisesResponseModelToJson(
        ExercisesResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
    };

ExerciseMutationResponseModel _$ExerciseMutationResponseModelFromJson(
        Map<String, dynamic> json) =>
    ExerciseMutationResponseModel(
      success: json['success'] as bool,
      exercise: json['exercise'] == null
          ? null
          : AdminExerciseModel.fromJson(
              json['exercise'] as Map<String, dynamic>),
      data: json['data'] == null
          ? null
          : AdminExerciseModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ExerciseMutationResponseModelToJson(
        ExerciseMutationResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'exercise': instance.exercise,
      'data': instance.data,
    };
