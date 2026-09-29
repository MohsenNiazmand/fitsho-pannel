import 'package:json_annotation/json_annotation.dart';
import 'package:fitsho_pannel/features/exercises/domain/entities/admin_exercise.dart';

part 'admin_exercise_model.g.dart';

@JsonSerializable()
class AdminExerciseModel {
  const AdminExerciseModel({
    required this.id,
    required this.key,
    required this.name,
    required this.category,
    required this.pattern,
    required this.primaryMuscle,
    this.secondaryMuscles = const [],
    this.equipment = const [],
    this.locations = const [],
    this.levels = const [],
    this.disciplines = const [],
    this.contraindications = const [],
    this.isCustomized = false,
    this.cue,
    this.gifUrl,
    this.videoUrl,
    this.isActive = true,
  });

  factory AdminExerciseModel.fromJson(Map<String, dynamic> json) =>
      _$AdminExerciseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AdminExerciseModelToJson(this);

  final String id;
  final String key;
  final String name;
  final String category;
  final String pattern;
  final String primaryMuscle;
  final List<String> secondaryMuscles;
  final List<String> equipment;
  final List<String> locations;
  final List<String> levels;
  final List<String> disciplines;
  final List<String> contraindications;
  final bool isCustomized;
  final String? cue;
  final String? gifUrl;
  final String? videoUrl;
  final bool isActive;

  AdminExercise toEntity() {
    return AdminExercise(
      id: id,
      key: key,
      name: name,
      category: category,
      pattern: pattern,
      primaryMuscle: primaryMuscle,
      secondaryMuscles: secondaryMuscles,
      equipment: equipment,
      locations: locations,
      levels: levels,
      disciplines: disciplines,
      contraindications: contraindications,
      isCustomized: isCustomized,
      cue: cue,
      gifUrl: gifUrl,
      videoUrl: videoUrl,
      isActive: isActive,
    );
  }
}

@JsonSerializable()
class ExercisePaginationModel {
  const ExercisePaginationModel({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory ExercisePaginationModel.fromJson(Map<String, dynamic> json) =>
      _$ExercisePaginationModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExercisePaginationModelToJson(this);

  final int total;
  final int page;
  final int limit;
  final int totalPages;

  ExercisePagination toEntity() {
    return ExercisePagination(
      total: total,
      page: page,
      limit: limit,
      totalPages: totalPages,
    );
  }
}

@JsonSerializable()
class ExercisesDataModel {
  const ExercisesDataModel({
    required this.exercises,
    required this.pagination,
  });

  factory ExercisesDataModel.fromJson(Map<String, dynamic> json) =>
      _$ExercisesDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExercisesDataModelToJson(this);

  final List<AdminExerciseModel> exercises;
  final ExercisePaginationModel pagination;
}

@JsonSerializable()
class ExercisesResponseModel {
  const ExercisesResponseModel({
    required this.success,
    required this.data,
  });

  factory ExercisesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ExercisesResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExercisesResponseModelToJson(this);

  final bool success;
  final ExercisesDataModel data;

  AdminExercisesResult toEntity() {
    return AdminExercisesResult(
      exercises: data.exercises.map((e) => e.toEntity()).toList(),
      pagination: data.pagination.toEntity(),
    );
  }
}

@JsonSerializable()
class ExerciseMutationResponseModel {
  const ExerciseMutationResponseModel({
    required this.success,
    this.exercise,
    this.data,
  });

  factory ExerciseMutationResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ExerciseMutationResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseMutationResponseModelToJson(this);

  final bool success;
  final AdminExerciseModel? exercise;
  final AdminExerciseModel? data;

  AdminExercise toEntity() {
    final item = exercise ?? data;
    if (item == null) {
      throw Exception('Exercise data not found in response');
    }
    return item.toEntity();
  }
}
