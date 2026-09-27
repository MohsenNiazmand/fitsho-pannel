import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitsho_pannel/core/theme/app_theme.dart';
import 'package:fitsho_pannel/features/exercises/domain/entities/admin_exercise.dart';
import 'package:fitsho_pannel/features/exercises/presentation/providers/exercises_provider.dart';

class ExercisesScreen extends ConsumerStatefulWidget {
  const ExercisesScreen({super.key});

  @override
  ConsumerState<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends ConsumerState<ExercisesScreen> {
  final TextEditingController _searchController = TextEditingController();

  static const List<Map<String, String>> _categories = [
    {'label': 'همه', 'value': ''},
    {'label': 'قدرتی', 'value': 'strength'},
    {'label': 'هوازی', 'value': 'cardio'},
    {'label': 'کششی', 'value': 'flexibility'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    ref.read(exercisesNotifierProvider.notifier).onSearch(value);
  }

  void _openExerciseFormDialog(BuildContext context, [AdminExercise? exercise]) {
    final isEditing = exercise != null;

    final keyController = TextEditingController(text: exercise?.key ?? '');
    final nameController = TextEditingController(text: exercise?.name ?? '');
    final categoryController =
        TextEditingController(text: exercise?.category ?? 'strength');
    final patternController =
        TextEditingController(text: exercise?.pattern ?? 'push');
    final muscleController =
        TextEditingController(text: exercise?.primaryMuscle ?? 'chest');
    final gifUrlController = TextEditingController(text: exercise?.gifUrl ?? '');
    final videoUrlController =
        TextEditingController(text: exercise?.videoUrl ?? '');
    final cueController = TextEditingController(text: exercise?.cue ?? '');
    bool isActive = exercise?.isActive ?? true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Consumer(
              builder: (context, ref, _) {
                final state = ref.watch(exercisesNotifierProvider);

                return Dialog(
                  backgroundColor: AppTheme.darkSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxWidth: 580, maxHeight: 720),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color:
                                          AppTheme.primaryColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      isEditing
                                          ? Icons.edit_rounded
                                          : Icons.add_circle_outline_rounded,
                                      color: AppTheme.primaryColor,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    isEditing
                                        ? 'ویرایش حرکت ورزشی'
                                        : 'افزودن حرکت جدید',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimaryDark,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded,
                                    color: AppTheme.textSecondaryDark),
                                onPressed: state.isSubmitting
                                    ? null
                                    : () => Navigator.of(dialogContext).pop(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(
                              color: Color(0xFF334155), height: 1),
                          const SizedBox(height: 16),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildField(
                                    label: 'نام حرکت (فارسی) *',
                                    hint: 'مثال: پرس سینه دمبل',
                                    controller: nameController,
                                  ),
                                  const SizedBox(height: 14),
                                  _buildField(
                                    label: 'کلید یکتا (انگلیسی) *',
                                    hint: 'مثال: dumbbell_bench_press',
                                    controller: keyController,
                                    enabled: !isEditing,
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildField(
                                          label: 'دسته‌بندی *',
                                          hint: 'strength, cardio...',
                                          controller: categoryController,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildField(
                                          label: 'عضله اصلی *',
                                          hint: 'chest, back, legs...',
                                          controller: muscleController,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  _buildField(
                                    label: 'الگوی حرکتی *',
                                    hint: 'مثال: push, pull, squat...',
                                    controller: patternController,
                                  ),
                                  const SizedBox(height: 14),
                                  _buildField(
                                    label: 'آدرس گیف تصویر (GIF URL)',
                                    hint: 'https://...',
                                    controller: gifUrlController,
                                  ),
                                  const SizedBox(height: 14),
                                  _buildField(
                                    label: 'آدرس ویدیو آموزشی (Video URL)',
                                    hint: 'https://...',
                                    controller: videoUrlController,
                                  ),
                                  const SizedBox(height: 14),
                                  _buildField(
                                    label: 'راهنمای اجرا و نکات فنی',
                                    hint: 'نکات صحیح اجرای حرکت...',
                                    controller: cueController,
                                    maxLines: 3,
                                  ),
                                  const SizedBox(height: 14),
                                  SwitchListTile(
                                    title: const Text(
                                      'وضعیت نمایش حرکت (فعال)',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.textPrimaryDark,
                                      ),
                                    ),
                                    value: isActive,
                                    activeColor: AppTheme.primaryColor,
                                    contentPadding: EdgeInsets.zero,
                                    onChanged: (val) {
                                      setDialogState(() {
                                        isActive = val;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: state.isSubmitting
                                    ? null
                                    : () => Navigator.of(dialogContext).pop(),
                                child: const Text('انصراف'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: state.isSubmitting
                                    ? null
                                    : () async {
                                        final data = {
                                          'key': keyController.text.trim(),
                                          'name': nameController.text.trim(),
                                          'category':
                                              categoryController.text.trim(),
                                          'pattern':
                                              patternController.text.trim(),
                                          'primaryMuscle':
                                              muscleController.text.trim(),
                                          'gifUrl': gifUrlController.text
                                                  .trim()
                                                  .isNotEmpty
                                              ? gifUrlController.text.trim()
                                              : null,
                                          'videoUrl': videoUrlController.text
                                                  .trim()
                                                  .isNotEmpty
                                              ? videoUrlController.text.trim()
                                              : null,
                                          'cue':
                                              cueController.text.trim().isNotEmpty
                                                  ? cueController.text.trim()
                                                  : null,
                                          'isActive': isActive,
                                        };

                                        bool success = false;
                                        if (isEditing) {
                                          success = await ref
                                              .read(exercisesNotifierProvider
                                                  .notifier)
                                              .updateExercise(
                                                  exercise.id, data);
                                        } else {
                                          success = await ref
                                              .read(exercisesNotifierProvider
                                                  .notifier)
                                              .createExercise(data);
                                        }

                                        if (success && context.mounted) {
                                          Navigator.of(dialogContext).pop();
                                        }
                                      },
                                child: state.isSubmitting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(isEditing
                                        ? 'ذخیره تغییرات'
                                        : 'افزودن حرکت'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool enabled = true,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.textSecondaryDark,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          style: const TextStyle(
              fontSize: 13, color: AppTheme.textPrimaryDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppTheme.textSecondaryDark.withOpacity(0.5),
              fontSize: 13,
            ),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exercisesNotifierProvider);

    ref.listen<ExercisesState>(exercisesNotifierProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
      if (next.successMessage != null &&
          next.successMessage != previous?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, state),
            const SizedBox(height: 20),
            _buildSearchAndFilters(context, state),
            const SizedBox(height: 16),
            Expanded(
              child: _buildBody(context, state),
            ),
            if (state.pagination != null) ...[
              const SizedBox(height: 16),
              _buildPaginationControls(context, state),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ExercisesState state) {
    final total = state.pagination?.total ?? state.exercises.length;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'بانک حرکات ورزشی',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      '$total حرکت',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'مدیریت دیتابیس حرکات، تصاویر متحرک، ویدئوها و مشخصات بیومکانیکی',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondaryDark,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _openExerciseFormDialog(context),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text('افزودن حرکت جدید'),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, ExercisesState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.darkSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded,
                  color: AppTheme.textSecondaryDark, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'جستجو بر اساس نام یا کلید حرکت...',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  style: const TextStyle(
                      fontSize: 14, color: AppTheme.textPrimaryDark),
                  onSubmitted: _onSearch,
                ),
              ),
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear_rounded,
                      size: 18, color: AppTheme.textSecondaryDark),
                  onPressed: () {
                    _searchController.clear();
                    _onSearch('');
                  },
                ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _onSearch(_searchController.text),
                child: const Text('جستجو'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _categories.map((cat) {
              final isSelected =
                  (state.selectedCategory ?? '') == cat['value'];
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: FilterChip(
                  label: Text(cat['label']!),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                  checkmarkColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.textSecondaryDark,
                  ),
                  backgroundColor: AppTheme.darkSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : const Color(0xFF334155),
                    ),
                  ),
                  onSelected: (_) {
                    ref
                        .read(exercisesNotifierProvider.notifier)
                        .onCategorySelected(
                            cat['value']!.isEmpty ? null : cat['value']);
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, ExercisesState state) {
    if (state.isLoading && state.exercises.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (state.errorMessage != null && state.exercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppTheme.dangerColor, size: 48),
            const SizedBox(height: 16),
            Text(
              state.errorMessage!,
              style: const TextStyle(color: AppTheme.textSecondaryDark),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(exercisesNotifierProvider.notifier).fetchExercises(),
              child: const Text('تلاش مجدد'),
            ),
          ],
        ),
      );
    }

    if (state.exercises.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center_rounded,
                color: AppTheme.textSecondaryDark, size: 48),
            SizedBox(height: 12),
            Text(
              'هیچ حرکتی با این مشخصات یافت نشد.',
              style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth >= 1200) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth >= 750) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 165,
          ),
          itemCount: state.exercises.length,
          itemBuilder: (context, index) {
            final exercise = state.exercises[index];
            return _ExerciseCard(
              exercise: exercise,
              onEdit: () => _openExerciseFormDialog(context, exercise),
            );
          },
        );
      },
    );
  }

  Widget _buildPaginationControls(BuildContext context, ExercisesState state) {
    final pagination = state.pagination;
    if (pagination == null) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'صفحه ${pagination.page} از ${pagination.totalPages} (مجموع: ${pagination.total} حرکت)',
          style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 13),
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: pagination.page > 1
                  ? () =>
                      ref.read(exercisesNotifierProvider.notifier).previousPage()
                  : null,
              icon: const Icon(Icons.chevron_right_rounded, size: 18),
              label: const Text('قبلی'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: pagination.page < pagination.totalPages
                  ? () =>
                      ref.read(exercisesNotifierProvider.notifier).nextPage()
                  : null,
              icon: const Icon(Icons.chevron_left_rounded, size: 18),
              label: const Text('بعدی'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.exercise,
    required this.onEdit,
  });

  final AdminExercise exercise;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // GIF / Image thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 100,
                height: double.infinity,
                color: const Color(0xFF1E293B),
                child: exercise.gifUrl != null && exercise.gifUrl!.isNotEmpty
                    ? Image.network(
                        exercise.gifUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.fitness_center_rounded,
                              color: AppTheme.accentColor, size: 28),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.fitness_center_rounded,
                            color: AppTheme.textSecondaryDark, size: 28),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            // Exercise information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          exercise.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_rounded,
                            size: 18, color: AppTheme.primaryColor),
                        tooltip: 'ویرایش حرکت',
                        onPressed: onEdit,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    exercise.key,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondaryDark.withOpacity(0.8),
                      fontFamily: 'monospace',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _buildChip(
                        exercise.primaryMuscle,
                        AppTheme.accentColor,
                      ),
                      _buildChip(
                        exercise.category,
                        const Color(0xFFF59E0B),
                      ),
                      _buildChip(
                        exercise.isActive ? 'فعال' : 'غیرفعال',
                        exercise.isActive
                            ? AppTheme.primaryColor
                            : AppTheme.dangerColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
