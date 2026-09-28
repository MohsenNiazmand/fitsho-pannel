import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitsho_pannel/features/users/presentation/providers/users_provider.dart';
import 'package:fitsho_pannel/core/theme/app_theme.dart';
import 'package:fitsho_pannel/features/users/domain/entities/admin_user_details.dart';

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
        width: 600,
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
            if (state.isLoadingDetails)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (userDetails != null)
              _buildUserDetails(userDetails)
            else if (state.detailsError != null)
              Center(
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
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('اطلاعاتی یافت نشد'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserDetails(AdminUserDetails user) {
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
