import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardNotifierProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(dashboardNotifierProvider.notifier).loadStats(),
          color: AppTheme.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                _buildHeader(context, ref, state),
                const SizedBox(height: 24),

                if (state.isLoading && state.stats == null)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(60),
                      child: CircularProgressIndicator(color: AppTheme.primaryColor),
                    ),
                  )
                else if (state.errorMessage != null && state.stats == null)
                  _buildErrorView(context, ref, state.errorMessage!)
                else ...[
                  // Stat Cards Grid
                  _buildStatsGrid(context, state),
                  const SizedBox(height: 32),

                  // Quick Action Cards
                  _buildQuickActions(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, DashboardState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'داشبورد تحلیلی و آماری',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryDark,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'خلاصه وضعیت سیستم و فعالیت‌های کاربران فیت‌شو',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondaryDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: state.isLoading
              ? null
              : () => ref.read(dashboardNotifierProvider.notifier).loadStats(),
          icon: state.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('بروزرسانی'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.darkCard,
            foregroundColor: AppTheme.textPrimaryDark,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, DashboardState state) {
    final stats = state.stats;

    final cards = [
      _StatCardData(
        title: 'تعداد کل کاربران',
        value: stats?.totalUsers.toString() ?? '0',
        icon: Icons.people_alt_rounded,
        color: const Color(0xFF10B981),
        subtitle: 'کل کاربران ثبت‌نام شده',
      ),
      _StatCardData(
        title: 'برنامه‌های تمرینی',
        value: stats?.totalWorkoutPlans.toString() ?? '0',
        icon: Icons.fitness_center_rounded,
        color: const Color(0xFF06B6D4),
        subtitle: 'تولید شده توسط هوش مصنوعی',
      ),
      _StatCardData(
        title: 'برنامه‌های غذایی',
        value: stats?.totalDietPlans.toString() ?? '0',
        icon: Icons.restaurant_rounded,
        color: const Color(0xFFF59E0B),
        subtitle: 'رژیم‌های فعال و آرشیو',
      ),
      _StatCardData(
        title: 'بانک حرکات ورزشی',
        value: stats?.totalExercises.toString() ?? '0',
        icon: Icons.sports_gymnastics_rounded,
        color: const Color(0xFF8B5CF6),
        subtitle: 'حرکات ثبت‌شده در دیتابیس',
      ),
      _StatCardData(
        title: 'کاربران فعال امروز',
        value: stats?.activeUsersToday.toString() ?? '0',
        icon: Icons.trending_up_rounded,
        color: const Color(0xFF38BDF8),
        subtitle: 'دارای لاگ یا تعامل روزانه',
      ),
      _StatCardData(
        title: 'ثبت‌نام جدید امروز',
        value: stats?.newUsersToday.toString() ?? '0',
        icon: Icons.person_add_alt_1_rounded,
        color: const Color(0xFFF43F5E),
        subtitle: 'کاربران جدید از بامداد',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth >= 1100) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth >= 600) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 140,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) => _StatCard(data: cards[index]),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'دسترسی سریع',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                title: 'مدیریت کاربران',
                description: 'مشاهده لیست کاربران، جستجو و جزئیات پروفایل',
                icon: Icons.people_alt_rounded,
                color: AppTheme.primaryColor,
                onTap: () => context.go('/users'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _QuickActionCard(
                title: 'بانک حرکات ورزشی',
                description: 'مدیریت حرکات، ویرایش گیف‌ها و ویدئوها',
                icon: Icons.fitness_center_rounded,
                color: AppTheme.accentColor,
                onTap: () => context.go('/exercises'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorView(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppTheme.dangerColor, size: 48),
            const SizedBox(height: 16),
            Text(
              error,
              style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => ref.read(dashboardNotifierProvider.notifier).loadStats(),
              child: const Text('تلاش مجدد'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCardData {
  const _StatCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});

  final _StatCardData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: data.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: data.color.withOpacity(0.25)),
              ),
              child: Icon(data.icon, color: data.color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondaryDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: data.color,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondaryDark.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppTheme.textSecondaryDark,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
