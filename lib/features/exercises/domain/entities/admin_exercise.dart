class AdminExercise {
  const AdminExercise({
    required this.id,
    required this.key,
    required this.name,
    required this.category,
    required this.pattern,
    required this.primaryMuscle,
    this.secondaryMuscles = const [],
    this.equipment = const [],
    this.cue,
    this.gifUrl,
    this.videoUrl,
    this.isActive = true,
  });

  final String id;
  final String key;
  final String name;
  final String category;
  final String pattern;
  final String primaryMuscle;
  final List<String> secondaryMuscles;
  final List<String> equipment;
  final String? cue;
  final String? gifUrl;
  final String? videoUrl;
  final bool isActive;
}

class ExercisePagination {
  const ExercisePagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  final int total;
  final int page;
  final int limit;
  final int totalPages;
}

class AdminExercisesResult {
  const AdminExercisesResult({
    required this.exercises,
    required this.pagination,
  });

  final List<AdminExercise> exercises;
  final ExercisePagination pagination;
}
