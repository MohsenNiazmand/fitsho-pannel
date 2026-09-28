import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fitsho_pannel/core/error/failures.dart';
import 'package:fitsho_pannel/features/metadata/domain/entities/metadata_catalog.dart';
import 'package:fitsho_pannel/features/metadata/domain/entities/metadata_item.dart';
import 'package:fitsho_pannel/features/metadata/domain/repositories/metadata_repository.dart';
import 'package:fitsho_pannel/features/metadata/presentation/providers/metadata_admin_provider.dart';

class MockMetadataRepository implements MetadataRepository {
  List<MetadataItem> mockItems = [
    const MetadataItem(
      id: 'm1',
      type: 'muscle_group',
      key: 'chest',
      labelFa: 'سینه',
      labelEn: 'Chest',
      order: 1,
    ),
    const MetadataItem(
      id: 'm2',
      type: 'muscle_group',
      key: 'back',
      labelFa: 'پشت',
      labelEn: 'Back',
      order: 2,
    ),
  ];

  int currentVersion = 10;
  bool shouldFail = false;

  @override
  Future<Either<Failure, MetadataListResult>> getMetadataItems({
    String? type,
    bool? isActive,
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    if (shouldFail) {
      return left(const ServerFailure('خطا در دریافت اطلاعات'));
    }
    final filtered = mockItems.where((i) => type == null || i.type == type).toList();
    return right(MetadataListResult(
      items: filtered,
      total: filtered.length,
      page: 1,
      limit: 50,
      totalPages: 1,
    ));
  }

  @override
  Future<Either<Failure, MetadataItem>> createMetadataItem(Map<String, dynamic> data) async {
    if (shouldFail) {
      return left(const ServerFailure('خطا در ایجاد'));
    }
    final item = MetadataItem(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      type: data['type'] as String,
      key: data['key'] as String,
      labelFa: data['labelFa'] as String,
      labelEn: data['labelEn'] as String,
      order: data['order'] as int? ?? 0,
    );
    mockItems.add(item);
    currentVersion++;
    return right(item);
  }

  @override
  Future<Either<Failure, MetadataItem>> updateMetadataItem(
    String id,
    Map<String, dynamic> data,
  ) async {
    if (shouldFail) {
      return left(const ServerFailure('خطا در ویرایش'));
    }
    final index = mockItems.indexWhere((i) => i.id == id);
    if (index == -1) {
      return left(const NotFoundFailure('آیتم یافت نشد'));
    }
    final existing = mockItems[index];
    final updated = existing.copyWith(
      labelFa: data['labelFa'] as String? ?? existing.labelFa,
      labelEn: data['labelEn'] as String? ?? existing.labelEn,
    );
    mockItems[index] = updated;
    currentVersion++;
    return right(updated);
  }

  @override
  Future<Either<Failure, bool>> deleteMetadataItem(String id) async {
    if (shouldFail) {
      return left(const ServerFailure('خطا در حذف'));
    }
    mockItems.removeWhere((i) => i.id == id);
    currentVersion++;
    return right(true);
  }

  @override
  Future<Either<Failure, bool>> reorderMetadataItems(
    String type,
    List<String> orderedIds,
  ) async {
    if (shouldFail) {
      return left(const ServerFailure('خطا در مرتب سازی'));
    }
    currentVersion++;
    return right(true);
  }

  @override
  Future<Either<Failure, int>> getCurrentVersion() async {
    return right(currentVersion);
  }
}

void main() {
  late MockMetadataRepository mockRepository;
  late MetadataAdminNotifier notifier;

  setUp(() {
    mockRepository = MockMetadataRepository();
    notifier = MetadataAdminNotifier(mockRepository);
  });

  test('initial state loads muscle_group items and version', () async {
    await pumpEventQueue();

    expect(notifier.state.selectedType, 'muscle_group');
    expect(notifier.state.items.length, 2);
    expect(notifier.state.currentVersion, 10);
    expect(notifier.state.isLoading, false);
  });

  test('selectType updates selectedType and fetches items', () async {
    await notifier.selectType('equipment');

    expect(notifier.state.selectedType, 'equipment');
    expect(notifier.state.items.isEmpty, true);
  });

  test('createItem adds item and increments version', () async {
    final success = await notifier.createItem({
      'type': 'muscle_group',
      'key': 'legs',
      'labelFa': 'پا',
      'labelEn': 'Legs',
      'order': 3,
    });

    expect(success, true);
    expect(notifier.state.successMessage, contains('پا'));
    expect(notifier.state.currentVersion, 11);
  });

  test('updateItem modifies item label and updates version', () async {
    final success = await notifier.updateItem('m1', {
      'labelFa': 'سینه و بالاسینه',
    });

    expect(success, true);
    expect(notifier.state.successMessage, contains('سینه و بالاسینه'));
  });

  test('deleteItem removes item optimistically and from repository', () async {
    final success = await notifier.deleteItem('m1');

    expect(success, true);
    expect(notifier.state.items.any((i) => i.id == 'm1'), false);
  });

  test('reorderItems reorders items optimistically', () async {
    final success = await notifier.reorderItems(['m2', 'm1']);

    expect(success, true);
    expect(notifier.state.items.first.id, 'm2');
    expect(notifier.state.items.last.id, 'm1');
  });
}
