import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/metadata_item.dart';
import '../providers/metadata_admin_provider.dart';
import 'metadata_form_dialog.dart';

class MetadataScreen extends ConsumerStatefulWidget {
  const MetadataScreen({super.key});

  @override
  ConsumerState<MetadataScreen> createState() => _MetadataScreenState();
}

class _MetadataScreenState extends ConsumerState<MetadataScreen> {
  void _openFormDialog([MetadataItem? item]) {
    final state = ref.read(metadataAdminNotifierProvider);
    showDialog(
      context: context,
      builder: (context) => MetadataFormDialog(
        item: item,
        selectedType: state.selectedType,
      ),
    );
  }

  void _confirmDelete(MetadataItem item) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.dangerColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning_amber_rounded, color: AppTheme.dangerColor),
            ),
            const SizedBox(width: 12),
            const Text(
              'حذف آیتم از کاتالوگ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'آیا از حذف آیتم "${item.labelFa}" (${item.key}) اطمینان دارید؟\nاین تغییر نسخه کاتالوگ را افزایش داده و در تمام اپ‌های پلتفرم منعکس خواهد شد.',
          style: const TextStyle(fontSize: 14, color: AppTheme.textSecondaryDark, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              final success = await ref
                  .read(metadataAdminNotifierProvider.notifier)
                  .deleteItem(item.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('آیتم "${item.labelFa}" با موفقیت حذف شد'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(metadataAdminNotifierProvider);
    final notifier = ref.read(metadataAdminNotifierProvider.notifier);

    // Listen to success / error messages
    ref.listen<MetadataAdminState>(metadataAdminNotifierProvider, (prev, next) {
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
      if (next.successMessage != null && next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              _buildHeader(context, state),
              const SizedBox(height: 20),
              // Category / Type Tabs
              _buildTypeTabs(state, notifier),
              const SizedBox(height: 16),
              // Items List
              Expanded(
                child: _buildItemsList(context, state, notifier),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, MetadataAdminState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.accentColor],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.category_rounded, color: Colors.white, size: 22),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'مدیریت کاتالوگ پلتفرم',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryDark,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'پیکربندی مقادیر مشترک پلتفرم',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryDark),
                  ),
                ],
              ),
              // Version Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryColor.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_rounded, size: 14, color: AppTheme.primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      'نسخه کاتالوگ: ${state.currentVersion}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('افزودن آیتم جدید'),
            onPressed: () => _openFormDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeTabs(MetadataAdminState state, MetadataAdminNotifier notifier) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: kMetadataTypes.map((typeInfo) {
          final type = typeInfo['type']!;
          final label = typeInfo['labelFa']!;
          final isSelected = state.selectedType == type;

          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              selectedColor: AppTheme.primaryColor,
              backgroundColor: AppTheme.darkSurface,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondaryDark,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              side: BorderSide(
                color: isSelected ? AppTheme.primaryColor : const Color(0xFF334155),
              ),
              onSelected: (_) => notifier.selectType(type),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildItemsList(
    BuildContext context,
    MetadataAdminState state,
    MetadataAdminNotifier notifier,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: AppTheme.textSecondaryDark.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text(
              'هیچ آیتمی برای این دسته یافت نشد',
              style: TextStyle(fontSize: 16, color: AppTheme.textSecondaryDark),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_rounded),
              label: const Text('ثبت اولین آیتم'),
              onPressed: () => _openFormDialog(),
            ),
          ],
        ),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      child: ReorderableListView.builder(
        itemCount: state.items.length,
        onReorder: (oldIndex, newIndex) {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final items = List<MetadataItem>.from(state.items);
          final moved = items.removeAt(oldIndex);
          items.insert(newIndex, moved);

          final orderedIds = items.map((i) => i.id).toList();
          notifier.reorderItems(orderedIds);
        },
        itemBuilder: (context, index) {
          final item = state.items[index];
          return _buildItemCard(item, index);
        },
      ),
    );
  }

  Widget _buildItemCard(MetadataItem item, int index) {
    return Container(
      key: ValueKey(item.id),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Drag Handle
            const Icon(
              Icons.drag_indicator_rounded,
              color: AppTheme.textSecondaryDark,
              size: 20,
            ),
            const SizedBox(width: 12),
            // Order number
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${item.order > 0 ? item.order : index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppTheme.textSecondaryDark,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Persian and English Title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.labelFa,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Key Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.darkCard,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Text(
                          item.key,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: AppTheme.accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.labelEn,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: item.isActive
                    ? AppTheme.successColor.withOpacity(0.15)
                    : AppTheme.textSecondaryDark.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.isActive ? 'فعال' : 'غیرفعال',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: item.isActive ? AppTheme.successColor : AppTheme.textSecondaryDark,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Action Buttons
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20, color: AppTheme.accentColor),
              tooltip: 'ویرایش',
              onPressed: () => _openFormDialog(item),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppTheme.dangerColor),
              tooltip: 'حذف',
              onPressed: () => _confirmDelete(item),
            ),
          ],
        ),
      ),
    );
  }
}
