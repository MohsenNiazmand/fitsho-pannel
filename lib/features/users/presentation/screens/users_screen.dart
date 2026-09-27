import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitsho_pannel/core/theme/app_theme.dart';
import 'package:fitsho_pannel/features/users/domain/entities/admin_user_details.dart';
import 'package:fitsho_pannel/features/users/domain/entities/admin_user_item.dart';
import 'package:fitsho_pannel/features/users/presentation/providers/users_provider.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String value) {
    ref.read(usersNotifierProvider.notifier).onSearch(value);
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(usersNotifierProvider.notifier).onSearch('');
  }

  void _showUserDetailsDialog(BuildContext context, AdminUserItem user) {
    ref.read(usersNotifierProvider.notifier).fetchUserDetails(user.id);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(usersNotifierProvider);
            return Dialog(
              backgroundColor: AppTheme.darkSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520, maxHeight: 650),
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
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name ?? 'کاربر فیت‌شو',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimaryDark,
                                    ),
                                  ),
                                  Text(
                                    user.mobile,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textSecondaryDark,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondaryDark),
                            onPressed: () {
                              ref.read(usersNotifierProvider.notifier).clearSelectedUser();
                              Navigator.of(dialogContext).pop();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFF334155), height: 1),
                      const SizedBox(height: 16),
                      Expanded(
                        child: state.isLoadingDetails
                            ? const Center(
                                child: CircularProgressIndicator(color: AppTheme.primaryColor),
                              )
                            : state.detailsError != null
                                ? Center(
                                    child: Text(
                                      state.detailsError!,
                                      style: const TextStyle(color: AppTheme.dangerColor),
                                    ),
                                  )
                                : _buildUserDetailsContent(state.selectedUserDetails, user),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            ref.read(usersNotifierProvider.notifier).clearSelectedUser();
                            Navigator.of(dialogContext).pop();
                          },
                          child: const Text('بستن'),
                        ),
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
  }

  Widget _buildUserDetailsContent(AdminUserDetails? details, AdminUserItem basicUser) {
    final dietProfile = details?.dietProfile;
    final workoutProfile = details?.workoutProfile;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('شناسه کاربر', basicUser.id),
          _buildInfoRow('شماره همراه', basicUser.mobile),
          _buildInfoRow('نام و نام خانوادگی', basicUser.name ?? 'ثبت نشده'),
          _buildInfoRow('نقش در سامانه', basicUser.role),
          _buildInfoRow(
            'تاریخ عضویت',
            '${basicUser.createdAt.year}/${basicUser.createdAt.month.toString().padLeft(2, '0')}/${basicUser.createdAt.day.toString().padLeft(2, '0')}',
          ),
          const SizedBox(height: 16),
          const Text(
            'خلاصه وضعیت فیزیکی',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.accentColor,
            ),
          ),
          const SizedBox(height: 8),
          if (dietProfile != null) ...[
            _buildInfoRow('سن', '${dietProfile['age'] ?? 'نامشخص'} سال'),
            _buildInfoRow('قد', '${dietProfile['heightCm'] ?? 'نامشخص'} سانتی‌متر'),
            _buildInfoRow('وزن', '${dietProfile['weightKg'] ?? 'نامشخص'} کیلوگرم'),
            _buildInfoRow('جنسیت', dietProfile['gender'] == 'male' ? 'آقا' : 'خانم'),
            _buildInfoRow('هدف ورزشی', dietProfile['goal']?.toString() ?? 'نامشخص'),
          ] else
            const Text(
              'پروفایل بدنی ثبت نشده است.',
              style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 13),
            ),
          const SizedBox(height: 16),
          const Text(
            'برنامه‌ها و آمار',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow('برنامه‌های تمرینی دریافت شده', '${details?.workoutPlansCount ?? basicUser.workoutPlansCount} برنامه'),
          _buildInfoRow('برنامه‌های رژیم دریافت شده', '${details?.dietPlansCount ?? basicUser.dietPlansCount} برنامه'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 13),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimaryDark,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usersNotifierProvider);

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

  Widget _buildHeader(BuildContext context, UsersState state) {
    final total = state.pagination?.total ?? state.users.length;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'مدیریت کاربران',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      '$total کاربر',
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
                'مشاهده لیست کاربران، جستجو بر اساس نام یا شماره همراه و بررسی اطلاعات حساب',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondaryDark,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: AppTheme.textSecondaryDark),
          tooltip: 'بروزرسانی لیست',
          onPressed: () {
            ref.read(usersNotifierProvider.notifier).fetchUsers();
          },
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, UsersState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppTheme.textSecondaryDark, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'جستجو بر اساس نام یا شماره تلفن کاربر...',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              style: const TextStyle(fontSize: 14, color: AppTheme.textPrimaryDark),
              onSubmitted: _onSearchSubmitted,
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded, size: 18, color: AppTheme.textSecondaryDark),
              onPressed: _clearSearch,
            ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => _onSearchSubmitted(_searchController.text),
            child: const Text('جستجو'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, UsersState state) {
    if (state.isLoading && state.users.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (state.errorMessage != null && state.users.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppTheme.dangerColor, size: 48),
            const SizedBox(height: 16),
            Text(
              state.errorMessage!,
              style: const TextStyle(color: AppTheme.textSecondaryDark),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(usersNotifierProvider.notifier).fetchUsers(),
              child: const Text('تلاش مجدد'),
            ),
          ],
        ),
      );
    }

    if (state.users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_off_rounded, color: AppTheme.textSecondaryDark, size: 48),
            SizedBox(height: 12),
            Text(
              'هیچ کاربری با این مشخصات یافت نشد.',
              style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          return _buildDesktopTable(context, state);
        } else {
          return _buildMobileList(context, state);
        }
      },
    );
  }

  Widget _buildDesktopTable(BuildContext context, UsersState state) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(const Color(0xFF1E293B)),
            dataRowColor: MaterialStateProperty.all(Colors.transparent),
            horizontalMargin: 24,
            columnSpacing: 24,
            columns: const [
              DataColumn(label: Text('کاربر', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('شماره همراه', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('نقش', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('برنامه‌ها', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('تاریخ عضویت', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('عملیات', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: state.users.map((user) {
              return DataRow(
                cells: [
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                          child: Text(
                            user.name != null && user.name!.isNotEmpty
                                ? user.name!.substring(0, 1)
                                : 'ک',
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          user.name ?? 'بدون نام',
                          style: const TextStyle(
                            color: AppTheme.textPrimaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Text(
                      user.mobile,
                      style: const TextStyle(
                        color: AppTheme.textSecondaryDark,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: user.role == 'ADMIN'
                            ? AppTheme.accentColor.withOpacity(0.2)
                            : Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        user.role == 'ADMIN' ? 'مدیر' : 'کاربر عادی',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: user.role == 'ADMIN'
                              ? AppTheme.accentColor
                              : AppTheme.textSecondaryDark,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildPlanBadge('${user.workoutPlansCount} تمرین', AppTheme.primaryColor),
                        const SizedBox(width: 6),
                        _buildPlanBadge('${user.dietPlansCount} تغذیه', const Color(0xFF10B981)),
                      ],
                    ),
                  ),
                  DataCell(
                    Text(
                      '${user.createdAt.year}/${user.createdAt.month.toString().padLeft(2, '0')}/${user.createdAt.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 13),
                    ),
                  ),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.visibility_rounded, color: AppTheme.primaryColor, size: 20),
                      tooltip: 'مشاهده جزئیات',
                      onPressed: () => _showUserDetailsDialog(context, user),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMobileList(BuildContext context, UsersState state) {
    return ListView.separated(
      itemCount: state.users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = state.users[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                          child: Text(
                            user.name != null && user.name!.isNotEmpty
                                ? user.name!.substring(0, 1)
                                : 'ک',
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name ?? 'بدون نام',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppTheme.textPrimaryDark,
                              ),
                            ),
                            Text(
                              user.mobile,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondaryDark,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.textSecondaryDark),
                      onPressed: () => _showUserDetailsDialog(context, user),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildPlanBadge('${user.workoutPlansCount} تمرین', AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    _buildPlanBadge('${user.dietPlansCount} تغذیه', const Color(0xFF10B981)),
                    const Spacer(),
                    Text(
                      'عضویت: ${user.createdAt.year}/${user.createdAt.month.toString().padLeft(2, '0')}/${user.createdAt.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondaryDark),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaginationControls(BuildContext context, UsersState state) {
    final pagination = state.pagination;
    if (pagination == null) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'صفحه ${pagination.page} از ${pagination.totalPages} (مجموع: ${pagination.total} کاربر)',
          style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 13),
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: pagination.page > 1
                  ? () => ref.read(usersNotifierProvider.notifier).previousPage()
                  : null,
              icon: const Icon(Icons.chevron_right_rounded, size: 18),
              label: const Text('قبلی'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: pagination.page < pagination.totalPages
                  ? () => ref.read(usersNotifierProvider.notifier).nextPage()
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
