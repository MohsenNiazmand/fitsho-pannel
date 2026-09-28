import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fitsho_pannel/core/error/failures.dart';
import 'package:fitsho_pannel/features/metadata/domain/entities/metadata_catalog.dart';
import 'package:fitsho_pannel/features/metadata/domain/entities/metadata_item.dart';
import 'package:fitsho_pannel/features/metadata/domain/repositories/metadata_repository.dart';
import 'package:fitsho_pannel/features/metadata/presentation/providers/metadata_admin_provider.dart';
import 'package:fitsho_pannel/features/metadata/presentation/screens/metadata_screen.dart';

class MockMetadataRepository implements MetadataRepository {
  List<MetadataItem> items = [
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

  @override
  Future<Either<Failure, MetadataListResult>> getMetadataItems({
    String? type,
    bool? isActive,
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    final filtered = items.where((i) => type == null || i.type == type).toList();
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
    return right(const MetadataItem(
      id: 'new-id',
      type: 'muscle_group',
      key: 'legs',
      labelFa: 'پا',
      labelEn: 'Legs',
    ));
  }

  @override
  Future<Either<Failure, MetadataItem>> updateMetadataItem(
    String id,
    Map<String, dynamic> data,
  ) async {
    return right(const MetadataItem(
      id: 'm1',
      type: 'muscle_group',
      key: 'chest',
      labelFa: 'سینه جدید',
      labelEn: 'New Chest',
    ));
  }

  @override
  Future<Either<Failure, bool>> deleteMetadataItem(String id) async {
    return right(true);
  }

  @override
  Future<Either<Failure, bool>> reorderMetadataItems(
    String type,
    List<String> orderedIds,
  ) async {
    return right(true);
  }

  @override
  Future<Either<Failure, int>> getCurrentVersion() async {
    return right(7);
  }
}

void main() {
  Widget createWidgetUnderTest(MockMetadataRepository repo) {
    return ProviderScope(
      overrides: [
        metadataRepositoryProvider.overrideWithValue(repo),
      ],
      child: const MaterialApp(
        home: MetadataScreen(),
      ),
    );
  }

  testWidgets('renders MetadataScreen with header, tabs, and items', (tester) async {
    final repo = MockMetadataRepository();
    await tester.pumpWidget(createWidgetUnderTest(repo));
    await tester.pumpAndSettle();

    expect(find.text('مدیریت کاتالوگ پلتفرم'), findsOneWidget);
    expect(find.text('نسخه کاتالوگ: 7'), findsOneWidget);
    expect(find.text('گروه‌های عضلانی'), findsOneWidget);
    expect(find.text('دسته‌بندی حرکات'), findsOneWidget);
    expect(find.text('سینه'), findsOneWidget);
    expect(find.text('Chest'), findsOneWidget);
    expect(find.text('chest'), findsOneWidget);
    expect(find.text('پشت'), findsOneWidget);
    expect(find.text('افزودن آیتم جدید'), findsOneWidget);
  });

  testWidgets('clicking Add Item button opens form dialog', (tester) async {
    final repo = MockMetadataRepository();
    await tester.pumpWidget(createWidgetUnderTest(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('افزودن آیتم جدید'));
    await tester.pumpAndSettle();

    expect(find.text('افزودن آیتم جدید به کاتالوگ'), findsOneWidget);
    expect(find.text('افزودن به کاتالوگ'), findsOneWidget);
    expect(find.text('انصراف'), findsOneWidget);
  });
}
