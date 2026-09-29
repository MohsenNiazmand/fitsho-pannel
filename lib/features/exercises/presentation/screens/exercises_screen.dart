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
    {'label': 'همه دسته‌ها', 'value': ''},
    {'label': 'قدرتی', 'value': 'strength'},
    {'label': 'هوازی', 'value': 'cardio'},
    {'label': 'انعطاف‌پذیری', 'value': 'flexibility'},
    {'label': 'پویایی (Warm-up)', 'value': 'mobility'},
    {'label': 'تعادلی', 'value': 'balance'},
    {'label': 'پلیومتریک', 'value': 'plyometric'},
  ];

  static const List<Map<String, String>> _locationsFilter = [
    {'label': 'همه مکان‌ها', 'value': ''},
    {'label': 'باشگاه', 'value': 'gym'},
    {'label': 'خانه', 'value': 'home'},
  ];

  static const Map<String, String> _locationOptions = {
    'gym': 'باشگاه ورزشی',
    'home': 'خانه',
  };

  static const Map<String, String> _disciplineOptions = {
    'bodybuilding': 'بدنسازی',
    'fitness': 'فیتنس و تناسب اندام',
    'corrective': 'حرکات اصلاحی',
    'cardio': 'کاردیو و سلامت قلب',
    'flexibility': 'انعطاف‌پذیری و تحرک‌پذیری',
  };

  static const Map<String, String> _levelOptions = {
    'beginner': 'مبتدی',
    'intermediate': 'متوسط',
    'advanced': 'پیشرفته',
    'elite': 'حرفه‌ای',
  };

  static const Map<String, String> _equipmentOptions = {
    'none': 'بدون ابزار',
    'bodyweight': 'وزن بدن',
    'dumbbell': 'دمبل',
    'barbell': 'هالتر',
    'kettlebell': 'کتل‌بل',
    'resistance_band': 'کش تمرینی',
    'pull_up_bar': 'میله بارفیکس',
    'bench': 'نیمکت',
    'machine': 'دستگاه بدنسازی',
    'cable': 'سیم‌کش',
    'mat': 'مت ورزشی',
    'treadmill': 'تردمیل',
    'stationary_bike': 'دوچرخه ثابت',
    'jump_rope': 'طناب زدن',
  };

  static const Map<String, String> _secondaryMuscleOptions = {
    'chest': 'سینه',
    'back': 'پشت',
    'legs': 'پا',
    'arms': 'بازو',
    'shoulders': 'سرشانه',
    'core': 'میان‌تنه و شکم',
    'glutes': 'باسن',
    'calves': 'ساق پا',
    'full_body': 'تمام بدن',
  };

  static const Map<String, String> _contraindicationOptions = {
    'knee': 'زانو',
    'shoulder': 'شانه',
    'lower_back': 'گودی کمر / کمر',
    'upper_back': 'بالای کمر و کول',
    'ankle': 'مچ پا',
    'wrist': 'مچ دست',
    'neck': 'گردن',
    'hip': 'لگن و ران',
    'elbow': 'آرنج',
  };

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

    final selectedLocations =
        List<String>.from(exercise?.locations ?? ['gym', 'home']);
    final selectedDisciplines =
        List<String>.from(exercise?.disciplines ?? ['bodybuilding', 'fitness']);
    final selectedLevels =
        List<String>.from(exercise?.levels ?? ['beginner', 'intermediate', 'advanced']);
    final selectedEquipment =
        List<String>.from(exercise?.equipment ?? ['bodyweight']);
    final selectedSecondaryMuscles =
        List<String>.from(exercise?.secondaryMuscles ?? []);
    final selectedContraindications =
        List<String>.from(exercise?.contraindications ?? []);

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
                        const BoxConstraints(maxWidth: 640, maxHeight: 780),
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
                                          AppTheme.primaryColor.withValues(alpha: 0.15),
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
                                        child: _buildDropdownField(
                                          label: 'دسته‌بندی اصلی *',
                                          value: categoryController.text.isEmpty
                                              ? 'strength'
                                              : categoryController.text,
                                          items: const [
                                            'strength',
                                            'cardio',
                                            'flexibility',
                                            'mobility',
                                            'balance',
                                            'plyometric'
                                          ],
                                          onChanged: (val) => categoryController
                                              .text = val ?? 'strength',
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildDropdownField(
                                          label: 'عضله اصلی *',
                                          value: muscleController.text.isEmpty
                                              ? 'chest'
                                              : muscleController.text,
                                          items: const [
                                            'chest',
                                            'back',
                                            'legs',
                                            'arms',
                                            'shoulders',
                                            'core',
                                            'glutes',
                                            'calves',
                                            'full_body'
                                          ],
                                          onChanged: (val) =>
                                              muscleController.text =
                                                  val ?? 'chest',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  _buildDropdownField(
                                    label: 'الگوی حرکتی *',
                                    value: patternController.text.isEmpty
                                        ? 'push'
                                        : patternController.text,
                                    items: const [
                                      'push',
                                      'pull',
                                      'squat',
                                      'hinge',
                                      'lunge',
                                      'core',
                                      'carry',
                                      'rotation'
                                    ],
                                    onChanged: (val) => patternController.text =
                                        val ?? 'push',
                                  ),
                                  const SizedBox(height: 16),

                                  // Multi-select: Locations
                                  _buildMultiSelectChips(
                                    label: 'مکان‌های تمرینی مجاز *',
                                    options: _locationOptions,
                                    selectedValues: selectedLocations,
                                    onSelected: (key, selected) {
                                      setDialogState(() {
                                        if (selected) {
                                          selectedLocations.add(key);
                                        } else {
                                          selectedLocations.remove(key);
                                        }
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Multi-select: Disciplines (5 Canonical)
                                  _buildMultiSelectChips(
                                    label: 'رشته‌های ورزشی مرتبط (۵ رشته استاندارد) *',
                                    options: _disciplineOptions,
                                    selectedValues: selectedDisciplines,
                                    onSelected: (key, selected) {
                                      setDialogState(() {
                                        if (selected) {
                                          selectedDisciplines.add(key);
                                        } else {
                                          selectedDisciplines.remove(key);
                                        }
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Multi-select: Levels
                                  _buildMultiSelectChips(
                                    label: 'سطوح مهارت مجاز *',
                                    options: _levelOptions,
                                    selectedValues: selectedLevels,
                                    onSelected: (key, selected) {
                                      setDialogState(() {
                                        if (selected) {
                                          selectedLevels.add(key);
                                        } else {
                                          selectedLevels.remove(key);
                                        }
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Multi-select: Equipment
                                  _buildMultiSelectChips(
                                    label: 'تجهیزات و ابزار موردنیاز *',
                                    options: _equipmentOptions,
                                    selectedValues: selectedEquipment,
                                    onSelected: (key, selected) {
                                      setDialogState(() {
                                        if (selected) {
                                          selectedEquipment.add(key);
                                        } else {
                                          selectedEquipment.remove(key);
                                        }
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Multi-select: Secondary Muscles
                                  _buildMultiSelectChips(
                                    label: 'عضلات کمکی / ثانویه',
                                    options: _secondaryMuscleOptions,
                                    selectedValues: selectedSecondaryMuscles,
                                    onSelected: (key, selected) {
                                      setDialogState(() {
                                        if (selected) {
                                          selectedSecondaryMuscles.add(key);
                                        } else {
                                          selectedSecondaryMuscles.remove(key);
                                        }
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Multi-select: Contraindications
                                  _buildMultiSelectChips(
                                    label: 'موارد منع مصرف و آسیب‌ها',
                                    options: _contraindicationOptions,
                                    selectedValues: selectedContraindications,
                                    onSelected: (key, selected) {
                                      setDialogState(() {
                                        if (selected) {
                                          selectedContraindications.add(key);
                                        } else {
                                          selectedContraindications.remove(key);
                                        }
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),

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
                                    activeThumbColor: AppTheme.primaryColor,
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
                                          'secondaryMuscles':
                                              selectedSecondaryMuscles,
                                          'equipment': selectedEquipment,
                                          'locations': selectedLocations,
                                          'levels': selectedLevels,
                                          'disciplines': selectedDisciplines,
                                          'contraindications':
                                              selectedContraindications,
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
                                          'cue': cueController.text
                                                  .trim()
                                                  .isNotEmpty
                                              ? cueController.text.trim()
                                              : null,
                                          'isActive': isActive,
                                          'isCustomized': true,
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

  Widget _buildMultiSelectChips({
    required String label,
    required Map<String, String> options,
    required List<String> selectedValues,
    required Function(String key, bool selected) onSelected,
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
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: options.entries.map((entry) {
            final isSelected = selectedValues.contains(entry.key);
            return FilterChip(
              label: Text(entry.value),
              selected: isSelected,
              selectedColor: AppTheme.primaryColor.withValues(alpha: 0.25),
              checkmarkColor: AppTheme.primaryColor,
              backgroundColor: AppTheme.darkCard,
              labelStyle: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondaryDark,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected
                    ? AppTheme.primaryColor
                    : const Color(0xFF334155),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              onSelected: (bool selected) => onSelected(entry.key, selected),
            );
          }).toList(),
        ),
      ],
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
              color: AppTheme.textSecondaryDark.withValues(alpha: 0.5),
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

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
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
        DropdownButtonFormField<String>(
          initialValue: items.contains(value) ? value : items.first,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 13)),
            );
          }).toList(),
          onChanged: onChanged,
          dropdownColor: AppTheme.darkCard,
          style: const TextStyle(color: AppTheme.textPrimaryDark),
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                      color: AppTheme.primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3)),
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
                  selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
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
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(
                  'مکان تمرین:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondaryDark,
                  ),
                ),
              ),
              ..._locationsFilter.map((loc) {
                final isSelected =
                    (state.selectedLocation ?? '') == loc['value'];
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: FilterChip(
                    label: Text(loc['label']!),
                    selected: isSelected,
                    selectedColor: AppTheme.accentColor.withValues(alpha: 0.2),
                    checkmarkColor: AppTheme.accentColor,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? AppTheme.accentColor
                          : AppTheme.textSecondaryDark,
                    ),
                    backgroundColor: AppTheme.darkSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected
                            ? AppTheme.accentColor
                            : const Color(0xFF334155),
                      ),
                    ),
                    onSelected: (_) {
                      ref
                          .read(exercisesNotifierProvider.notifier)
                          .onLocationSelected(
                              loc['value']!.isEmpty ? null : loc['value']);
                    },
                  ),
                );
              }),
            ],
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

    final displayedExercises = state.filteredExercises;

    if (displayedExercises.isEmpty) {
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
            mainAxisExtent: 175,
          ),
          itemCount: displayedExercises.length,
          itemBuilder: (context, index) {
            final exercise = displayedExercises[index];
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'strength':
        return const Color(0xFFF59E0B);
      case 'cardio':
        return const Color(0xFFEF4444);
      case 'flexibility':
        return const Color(0xFF10B981);
      case 'mobility':
        return const Color(0xFF06B6D4);
      case 'balance':
        return const Color(0xFF8B5CF6);
      case 'plyometric':
        return const Color(0xFFEC4899);
      default:
        return AppTheme.primaryColor;
    }
  }

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
                      color: AppTheme.textSecondaryDark.withValues(alpha: 0.8),
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
                        _getCategoryColor(exercise.category),
                      ),
                      if (exercise.isCustomized)
                        _buildChip(
                          'شخصی‌سازی',
                          const Color(0xFF8B5CF6),
                        ),
                      if (exercise.cue != null && exercise.cue!.isNotEmpty)
                        _buildChip(
                          'نکته‌دار',
                          const Color(0xFF06B6D4),
                        ),
                      if (exercise.videoUrl != null && exercise.videoUrl!.isNotEmpty)
                        _buildChip(
                          'ویدیو',
                          const Color(0xFF10B981),
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
        color: color.withValues(alpha: 0.12),
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
