import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/metadata_item.dart';
import '../providers/metadata_admin_provider.dart';

class MetadataFormDialog extends ConsumerStatefulWidget {
  const MetadataFormDialog({
    super.key,
    this.item,
    required this.selectedType,
  });

  final MetadataItem? item;
  final String selectedType;

  @override
  ConsumerState<MetadataFormDialog> createState() => _MetadataFormDialogState();
}

class _MetadataFormDialogState extends ConsumerState<MetadataFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _keyController;
  late final TextEditingController _labelFaController;
  late final TextEditingController _labelEnController;
  late final TextEditingController _iconController;
  late final TextEditingController _orderController;
  late bool _isActive;

  bool get isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    _keyController = TextEditingController(text: widget.item?.key ?? '');
    _labelFaController = TextEditingController(text: widget.item?.labelFa ?? '');
    _labelEnController = TextEditingController(text: widget.item?.labelEn ?? '');
    _iconController = TextEditingController(text: widget.item?.icon ?? '');
    _orderController = TextEditingController(
      text: widget.item?.order.toString() ?? '0',
    );
    _isActive = widget.item?.isActive ?? true;
  }

  @override
  void dispose() {
    _keyController.dispose();
    _labelFaController.dispose();
    _labelEnController.dispose();
    _iconController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(metadataAdminNotifierProvider.notifier);
    final data = <String, dynamic>{
      'type': widget.selectedType,
      'key': _keyController.text.trim().toLowerCase(),
      'labelFa': _labelFaController.text.trim(),
      'labelEn': _labelEnController.text.trim(),
      'icon': _iconController.text.trim().isEmpty ? null : _iconController.text.trim(),
      'order': int.tryParse(_orderController.text.trim()) ?? 0,
      'isActive': _isActive,
    };

    bool success;
    if (isEditing) {
      success = await notifier.updateItem(widget.item!.id, data);
    } else {
      success = await notifier.createItem(data);
    }

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(metadataAdminNotifierProvider);
    final typeName = kMetadataTypes.firstWhere(
      (t) => t['type'] == widget.selectedType,
      orElse: () => {'labelFa': widget.selectedType},
    )['labelFa'];

    return Dialog(
      backgroundColor: AppTheme.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.category_rounded,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEditing ? 'ویرایش آیتم کاتالوگ' : 'افزودن آیتم جدید به کاتالوگ',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimaryDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'دسته: $typeName',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondaryDark),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (state.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.dangerColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.dangerColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: AppTheme.dangerColor, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.errorMessage!,
                              style: const TextStyle(color: AppTheme.dangerColor, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Key Field
                  TextFormField(
                    controller: _keyController,
                    readOnly: isEditing,
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      color: isEditing ? AppTheme.textSecondaryDark : AppTheme.textPrimaryDark,
                    ),
                    decoration: InputDecoration(
                      labelText: 'کلید انگلیسی یکتا (key) *',
                      hintText: 'مثال: chest, barbell',
                      prefixIcon: const Icon(Icons.key_rounded, size: 20),
                      helperText: isEditing ? 'کلید یکتا قابل ویرایش نیست' : 'فقط حروف انگلیسی کوچک و underline',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'وارد کردن کلید الزامی است';
                      }
                      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(val.trim())) {
                        return 'فقط حروف انگلیسی، عدد و _ مجاز است';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Persian Label
                  TextFormField(
                    controller: _labelFaController,
                    decoration: const InputDecoration(
                      labelText: 'عنوان فارسی (labelFa) *',
                      hintText: 'مثال: سینه، هالتر',
                      prefixIcon: Icon(Icons.translate_rounded, size: 20),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'وارد کردن عنوان فارسی الزامی است';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // English Label
                  TextFormField(
                    controller: _labelEnController,
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                      labelText: 'عنوان انگلیسی (labelEn) *',
                      hintText: 'e.g. Chest, Barbell',
                      prefixIcon: Icon(Icons.language_rounded, size: 20),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'وارد کردن عنوان انگلیسی الزامی است';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Icon & Order in row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _iconController,
                          textDirection: TextDirection.ltr,
                          decoration: const InputDecoration(
                            labelText: 'نام آیکون (اختیاری)',
                            hintText: 'e.g. dumbbell',
                            prefixIcon: Icon(Icons.image_outlined, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _orderController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'ترتیب نمایش (order)',
                            hintText: '0',
                            prefixIcon: Icon(Icons.format_list_numbered_rounded, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Active Toggle Switch
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.darkCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.check_circle_outline_rounded, color: AppTheme.successColor, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'وضعیت فعال در اپ‌ها',
                              style: TextStyle(fontSize: 14, color: AppTheme.textPrimaryDark),
                            ),
                          ],
                        ),
                        Switch(
                          value: _isActive,
                          activeColor: AppTheme.primaryColor,
                          onChanged: (val) => setState(() => _isActive = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: state.isSubmitting ? null : () => Navigator.of(context).pop(),
                        child: const Text('انصراف'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: state.isSubmitting ? null : _submit,
                        child: state.isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(isEditing ? 'بروزرسانی' : 'افزودن به کاتالوگ'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
