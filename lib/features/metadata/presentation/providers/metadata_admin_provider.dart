import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/admin_api_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/metadata_repository_impl.dart';
import '../../domain/entities/metadata_item.dart';
import '../../domain/repositories/metadata_repository.dart';

const List<Map<String, String>> kMetadataTypes = [
  {'type': 'muscle_group', 'labelFa': 'گروه‌های عضلانی'},
  {'type': 'exercise_category', 'labelFa': 'دسته‌بندی حرکات'},
  {'type': 'movement_pattern', 'labelFa': 'الگوی حرکتی'},
  {'type': 'workout_type', 'labelFa': 'نوع تمرین'},
  {'type': 'equipment', 'labelFa': 'تجهیزات ورزشی'},
  {'type': 'injury_type', 'labelFa': 'انواع آسیب'},
  {'type': 'goal', 'labelFa': 'اهداف تمرین'},
  {'type': 'difficulty_level', 'labelFa': 'سطح دشواری'},
];

final metadataRepositoryProvider = Provider<MetadataRepository>((ref) {
  final apiService = ref.watch(adminApiServiceProvider);
  return MetadataRepositoryImpl(apiService);
});

class MetadataAdminState {
  const MetadataAdminState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
    this.selectedType = 'muscle_group',
    this.items = const [],
    this.currentVersion = 1,
  });

  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;
  final String selectedType;
  final List<MetadataItem> items;
  final int currentVersion;

  MetadataAdminState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
    String? selectedType,
    List<MetadataItem>? items,
    int? currentVersion,
  }) {
    return MetadataAdminState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      selectedType: selectedType ?? this.selectedType,
      items: items ?? this.items,
      currentVersion: currentVersion ?? this.currentVersion,
    );
  }
}

class MetadataAdminNotifier extends StateNotifier<MetadataAdminState> {
  MetadataAdminNotifier(this._repository) : super(const MetadataAdminState()) {
    fetchItems(state.selectedType);
    fetchVersion();
  }

  final MetadataRepository _repository;

  Future<void> fetchVersion() async {
    final result = await _repository.getCurrentVersion();
    result.fold(
      (failure) => null,
      (version) => state = state.copyWith(currentVersion: version),
    );
  }

  Future<void> fetchItems([String? type, bool clearSuccess = false]) async {
    final targetType = type ?? state.selectedType;
    state = state.copyWith(
      isLoading: true,
      selectedType: targetType,
      clearError: true,
      clearSuccess: clearSuccess,
    );

    final result = await _repository.getMetadataItems(type: targetType, limit: 100);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (data) {
        // Sort items by order
        final sorted = List<MetadataItem>.from(data.items)
          ..sort((a, b) => a.order.compareTo(b.order));
        state = state.copyWith(
          isLoading: false,
          items: sorted,
        );
      },
    );
  }

  Future<void> selectType(String type) async {
    if (state.selectedType == type && state.items.isNotEmpty) return;
    await fetchItems(type);
  }

  Future<bool> createItem(Map<String, dynamic> data) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true);

    final payload = Map<String, dynamic>.from(data);
    if (!payload.containsKey('type') || (payload['type'] as String).isEmpty) {
      payload['type'] = state.selectedType;
    }

    final result = await _repository.createMetadataItem(payload);

    if (result.isLeft()) {
      final failure = result.getLeft().toNullable()!;
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: failure.message,
      );
      return false;
    }

    final created = result.getRight().toNullable()!;
    state = state.copyWith(
      isSubmitting: false,
      successMessage: 'آیتم "${created.labelFa}" با موفقیت ایجاد شد',
    );
    await fetchItems(state.selectedType);
    await fetchVersion();
    return true;
  }

  Future<bool> updateItem(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true);

    final result = await _repository.updateMetadataItem(id, data);

    if (result.isLeft()) {
      final failure = result.getLeft().toNullable()!;
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: failure.message,
      );
      return false;
    }

    final updated = result.getRight().toNullable()!;
    state = state.copyWith(
      isSubmitting: false,
      successMessage: 'آیتم "${updated.labelFa}" با موفقیت به‌روزرسانی شد',
    );
    await fetchItems(state.selectedType);
    await fetchVersion();
    return true;
  }

  Future<bool> deleteItem(String id) async {
    final previousItems = state.items;
    state = state.copyWith(
      items: state.items.where((item) => item.id != id).toList(),
      clearError: true,
      clearSuccess: true,
    );

    final result = await _repository.deleteMetadataItem(id);

    if (result.isLeft()) {
      final failure = result.getLeft().toNullable()!;
      state = state.copyWith(
        items: previousItems,
        errorMessage: failure.message,
      );
      return false;
    }

    state = state.copyWith(
      successMessage: 'آیتم با موفقیت حذف شد',
    );
    await fetchVersion();
    return true;
  }

  Future<bool> reorderItems(List<String> orderedIds) async {
    final itemMap = {for (final item in state.items) item.id: item};
    final reordered = <MetadataItem>[];
    for (int i = 0; i < orderedIds.length; i++) {
      final item = itemMap[orderedIds[i]];
      if (item != null) {
        reordered.add(item.copyWith(order: i + 1));
      }
    }

    final previousItems = state.items;
    state = state.copyWith(items: reordered);

    final result = await _repository.reorderMetadataItems(state.selectedType, orderedIds);

    if (result.isLeft()) {
      final failure = result.getLeft().toNullable()!;
      state = state.copyWith(
        items: previousItems,
        errorMessage: failure.message,
      );
      return false;
    }

    await fetchVersion();
    return true;
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}

final metadataAdminNotifierProvider =
    StateNotifierProvider<MetadataAdminNotifier, MetadataAdminState>((ref) {
  final repository = ref.watch(metadataRepositoryProvider);
  return MetadataAdminNotifier(repository);
});
