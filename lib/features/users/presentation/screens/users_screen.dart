import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitsho_pannel/features/users/presentation/providers/users_provider.dart';
import 'package:fitsho_pannel/core/theme/app_theme.dart';
import 'dart:async';
import 'user_details_dialog.dart';
import 'package:fitsho_pannel/features/users/domain/entities/admin_user_item.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(usersNotifierProvider.notifier).fetchUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(usersNotifierProvider.notifier).onSearch(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usersNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'مدیریت کاربران',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryDark,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(usersNotifierProvider.notifier).fetchUsers();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('بروزرسانی'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSearchBar(),
            const SizedBox(height: 24),
            Expanded(
              child: _buildContent(state),
            ),
            if (state.pagination != null && state.pagination!.totalPages > 1)
              _buildPagination(state.pagination!.page, state.pagination!.totalPages),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'جستجو با شماره موبایل یا نام...',
          prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondaryDark),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppTheme.darkSurface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildContent(UsersState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppTheme.dangerColor),
            const SizedBox(height: 16),
            Text(
              state.errorMessage!,
              style: const TextStyle(color: AppTheme.dangerColor),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(usersNotifierProvider.notifier).fetchUsers();
              },
              child: const Text('تلاش مجدد'),
            ),
          ],
        ),
      );
    }

    if (state.users.isEmpty) {
      return const Center(
        child: Text('کاربری یافت نشد.'),
      );
    }

    return _buildUsersTable(state.users);
  }

  Widget _buildUsersTable(List<AdminUserItem> users) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('شناسه')),
              DataColumn(label: Text('موبایل')),
              DataColumn(label: Text('نام')),
              DataColumn(label: Text('نقش')),
              DataColumn(label: Text('تاریخ ثبت نام')),
              DataColumn(label: Text('عملیات')),
            ],
            rows: users.map((user) {
              return DataRow(
                cells: [
                  DataCell(Text(user.id)),
                  DataCell(Text(user.mobile)),
                  DataCell(Text(user.name ?? '-')),
                  DataCell(_buildRoleBadge(user.role)),
                  DataCell(Text(user.createdAt.toString().split(' ')[0])),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.visibility_rounded, color: AppTheme.primaryColor),
                      onPressed: () {
                        _showUserDetails(user.id);
                      },
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

  Widget _buildRoleBadge(String role) {
    Color color;
    String label;
    switch (role.toLowerCase()) {
      case 'admin':
        color = Colors.purple;
        label = 'مدیر';
        break;
      case 'user':
        color = Colors.blue;
        label = 'کاربر عادی';
        break;
      default:
        color = Colors.grey;
        label = role;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPagination(int currentPage, int totalPages) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage > 1
                ? () {
                    ref.read(usersNotifierProvider.notifier).fetchUsers(page: currentPage - 1);
                  }
                : null,
          ),
          Text('صفحه $currentPage از $totalPages'),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage < totalPages
                ? () {
                    ref.read(usersNotifierProvider.notifier).fetchUsers(page: currentPage + 1);
                  }
                : null,
          ),
        ],
      ),
    );
  }

  void _showUserDetails(String userId) {
    showDialog(
      context: context,
      builder: (context) => UserDetailsDialog(userId: userId),
    );
  }
}
