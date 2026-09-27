import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    super.key,
    required this.child,
    required this.currentLocation,
  });

  final Widget child;
  final String currentLocation;

  int _calculateSelectedIndex() {
    if (currentLocation.startsWith('/users')) return 1;
    if (currentLocation.startsWith('/exercises')) return 2;
    return 0; // /dashboard
  }

  void _onDestinationSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/users');
        break;
      case 2:
        context.go('/exercises');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;

        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                _buildSidebar(context, selectedIndex),
                const VerticalDivider(width: 1, thickness: 1, color: Color(0xFF334155)),
                Expanded(child: child),
              ],
            ),
          );
        }

        return Scaffold(
          body: child,
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (idx) => _onDestinationSelected(context, idx),
            backgroundColor: AppTheme.darkSurface,
            indicatorColor: AppTheme.primaryColor.withOpacity(0.2),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded, color: AppTheme.primaryColor),
                label: 'داشبورد',
              ),
              NavigationDestination(
                icon: Icon(Icons.people_outline_rounded),
                selectedIcon: Icon(Icons.people_alt_rounded, color: AppTheme.primaryColor),
                label: 'کاربران',
              ),
              NavigationDestination(
                icon: Icon(Icons.fitness_center_outlined),
                selectedIcon: Icon(Icons.fitness_center_rounded, color: AppTheme.primaryColor),
                label: 'حرکات',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidebar(BuildContext context, int selectedIndex) {
    return Container(
      width: 260,
      color: AppTheme.darkSurface,
      child: Column(
        children: [
          // Logo & Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.accentColor],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.fitness_center_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'فیت‌شو',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryDark,
                        ),
                      ),
                      Text(
                        'پنل مدیریت سیستم',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF334155)),
          const SizedBox(height: 16),
          // Nav items
          _SidebarItem(
            icon: Icons.dashboard_rounded,
            title: 'داشبورد',
            isSelected: selectedIndex == 0,
            onTap: () => _onDestinationSelected(context, 0),
          ),
          _SidebarItem(
            icon: Icons.people_alt_rounded,
            title: 'مدیریت کاربران',
            isSelected: selectedIndex == 1,
            onTap: () => _onDestinationSelected(context, 1),
          ),
          _SidebarItem(
            icon: Icons.fitness_center_rounded,
            title: 'بانک حرکات ورزشی',
            isSelected: selectedIndex == 2,
            onTap: () => _onDestinationSelected(context, 2),
          ),
          const Spacer(),
          // Logout / User Info
          const Divider(height: 1, color: Color(0xFF334155)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppTheme.darkCard,
                  child: Icon(Icons.admin_panel_settings_rounded, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مدیر سیستم',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'ادمین کل',
                        style: TextStyle(fontSize: 11, color: AppTheme.textSecondaryDark),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: AppTheme.dangerColor, size: 20),
                  tooltip: 'خروج از حساب',
                  onPressed: () {
                    context.go('/login');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: isSelected ? AppTheme.primaryColor.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryDark,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
