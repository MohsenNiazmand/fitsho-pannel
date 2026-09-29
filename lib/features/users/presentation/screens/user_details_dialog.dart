import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitsho_pannel/features/users/presentation/providers/users_provider.dart';
import 'package:fitsho_pannel/core/theme/app_theme.dart';
import 'package:fitsho_pannel/features/users/domain/entities/admin_user_details.dart';
import 'package:fitsho_pannel/features/users/domain/entities/user_quotas.dart';


class UserDetailsDialog extends ConsumerStatefulWidget {
  final String userId;

  const UserDetailsDialog({super.key, required this.userId});

  @override
  ConsumerState<UserDetailsDialog> createState() => _UserDetailsDialogState();
}

class _UserDetailsDialogState extends ConsumerState<UserDetailsDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(usersNotifierProvider.notifier).fetchUserDetails(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usersNotifierProvider);
    final userDetails = state.selectedUserDetails;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 720,
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 850),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'جزئیات کاربر',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: state.isLoadingDetails
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : userDetails != null
                        ? _buildUserDetails(userDetails, state.isResettingQuotas)
                        : state.detailsError != null
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.error_outline, color: AppTheme.dangerColor, size: 48),
                                      const SizedBox(height: 16),
                                      Text(state.detailsError!, style: const TextStyle(color: AppTheme.dangerColor)),
                                    ],
                                  ),
                                ),
                              )
                            : const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: Text('اطلاعاتی یافت نشد'),
                                ),
                              ),
              ),
            ),
          ],
        ),
      ),
    );

  }

  Widget _buildUserDetails(AdminUserDetails user, bool isResetting) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 40, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(label: 'شناسه', value: user.id),
                  _DetailRow(label: 'نام', value: user.name ?? 'ثبت نشده'),
                  _DetailRow(label: 'موبایل', value: user.mobile),
                  _DetailRow(label: 'نقش', value: user.role),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (user.dietProfile != null) ...[
          Text(
            'خلاصه وضعیت فیزیکی',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DetailRow(
                  label: 'سن',
                  value: user.dietProfile!['age'] != null ? '${user.dietProfile!['age']} سال' : '-',
                ),
              ),
              Expanded(
                child: _DetailRow(
                  label: 'قد',
                  value: user.dietProfile!['heightCm'] != null ? '${user.dietProfile!['heightCm']} سانتی‌متر' : '-',
                ),
              ),
              Expanded(
                child: _DetailRow(
                  label: 'وزن',
                  value: user.dietProfile!['weightKg'] != null ? '${user.dietProfile!['weightKg']} کیلوگرم' : '-',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
        const SizedBox(height: 24),
        _buildQuotasSection(context, user, isResetting),
        const SizedBox(height: 24),

        Text(
          'آمار کاربر',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'برنامه‌های تمرینی',
                value: user.workoutPlansCount.toString(),
                icon: Icons.fitness_center,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'برنامه‌های غذایی',
                value: user.dietPlansCount.toString(),
                icon: Icons.restaurant,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _DetailRow(
                label: 'تاریخ ثبت‌نام',
                value: user.createdAt.toString().split('.')[0],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuotasSection(BuildContext context, AdminUserDetails user, bool isResetting) {
    final quotas = user.quotas;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.darkCard.withValues(alpha: 0.5)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.speed_rounded, size: 20, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'سهمیه‌ها و محدودیت‌ها',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryDark,
                        ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: isResetting ? null : () => _showResetQuotasDialog(context, user),
                icon: isResetting
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.restart_alt_rounded, size: 16),
                label: Text(isResetting ? 'در حال اعمال...' : 'شارژ سهمیه / ریست'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildQuotaCard(
                  title: 'برنامه تمرینی',
                  icon: Icons.fitness_center_rounded,
                  color: Colors.blueAccent,
                  quota: quotas?.workout,
                  swapLabel: 'جابجایی حرکت (Swap)',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuotaCard(
                  title: 'برنامه غذایی',
                  icon: Icons.restaurant_rounded,
                  color: AppTheme.successColor,
                  quota: quotas?.diet,
                  swapLabel: 'تغییر وعده (Swap)',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuotaCard({
    required String title,
    required IconData icon,
    required Color color,
    required QuotaItem? quota,
    required String swapLabel,
  }) {
    if (quota == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text('اطلاعات سهمیه موجود نیست', style: TextStyle(color: AppTheme.textSecondaryDark)),
      );
    }

    final isFull = quota.remaining == 0;
    final isSwapFull = quota.swapsRemaining == 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isFull
              ? AppTheme.dangerColor.withValues(alpha: 0.5)
              : AppTheme.darkCard.withValues(alpha: 0.6),
        ),

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const Spacer(),
              if (isFull)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.dangerColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'سقف پر',
                    style: TextStyle(color: AppTheme.dangerColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          _buildQuotaProgressRow(
            label: 'ساخت برنامه (۷ روزه)',
            used: quota.used,
            max: quota.max,
            remaining: quota.remaining,
            color: color,
          ),
          const SizedBox(height: 10),
          _buildQuotaProgressRow(
            label: swapLabel,
            used: quota.swapsUsed,
            max: quota.swapsMax,
            remaining: quota.swapsRemaining,
            color: isSwapFull ? AppTheme.dangerColor : AppTheme.warningColor,
          ),
        ],
      ),
    );
  }

  Widget _buildQuotaProgressRow({
    required String label,
    required int used,
    required int max,
    required int remaining,
    required Color color,
  }) {
    final double percent = max > 0 ? (used / max).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 11)),
            Text(
              '$used از $max (باقی: $remaining)',
              style: TextStyle(
                color: remaining == 0 ? AppTheme.dangerColor : AppTheme.textPrimaryDark,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 6,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            valueColor: AlwaysStoppedAnimation<Color>(
              remaining == 0 ? AppTheme.dangerColor : color,
            ),
          ),
        ),
      ],
    );
  }

  void _showResetQuotasDialog(BuildContext context, AdminUserDetails user) {
    String selectedTarget = 'all';

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.restart_alt_rounded, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text('شارژ مجدد سهمیه‌های کاربر'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'آیا از ریست کردن محدودیت‌های کاربر «${user.name ?? user.mobile}» اطمینان دارید؟',
                style: const TextStyle(color: AppTheme.textPrimaryDark),
              ),
              const SizedBox(height: 16),
              const Text(
                'نوع سهمیه جهت ریست:',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondaryDark, fontSize: 12),
              ),
              const SizedBox(height: 8),
              RadioListTile<String>(
                title: const Text('تمام سهمیه‌ها (تمرینی و غذایی)'),
                value: 'all',
                groupValue: selectedTarget,
                onChanged: (val) => setDialogState(() => selectedTarget = val!),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
              RadioListTile<String>(
                title: const Text('فقط سهمیه برنامه تمرینی و حرکات'),
                value: 'workout',
                groupValue: selectedTarget,
                onChanged: (val) => setDialogState(() => selectedTarget = val!),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
              RadioListTile<String>(
                title: const Text('فقط سهمیه برنامه غذایی و وعده‌ها'),
                value: 'diet',
                groupValue: selectedTarget,
                onChanged: (val) => setDialogState(() => selectedTarget = val!),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogCtx).pop();
                final success = await ref
                    .read(usersNotifierProvider.notifier)
                    .resetUserQuotas(user.id, target: selectedTarget);

                if (!context.mounted) return;

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('سهمیه‌های کاربر با موفقیت شارژ و ریست شد.'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                } else {
                  final error = ref.read(usersNotifierProvider).resetQuotaError;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error ?? 'خطا در شارژ مجدد سهمیه‌ها'),
                      backgroundColor: AppTheme.dangerColor,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('تایید و ریست'),
            ),
          ],
        ),
      ),
    );
  }

}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondaryDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
