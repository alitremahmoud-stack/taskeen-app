import 'package:flutter/material.dart';
import 'package:taskeen_app/core/user_session.dart';
import '../../core/db_helper.dart';
import 'package:badges/badges.dart' as badges;
import '../../core/routes_names.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    int currentUserId = UserSession.userId; // تحديث معرف المستخدم الحالي

    return Drawer(
      child: Column(
        children: [
          // رأس القائمة المخصص
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  children: [
                    // الصورة الرمزية
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          'https://static.vecteezy.com/system/resources/previews/041/033/205/large_2x/user-icon-profile-line-icon-isolated-on-white-background-vector.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: colorScheme.secondary,
                              child: Center(
                                child: Text(
                                  UserSession.username.isNotEmpty
                                      ? UserSession.username[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // اسم المستخدم
                    Text(
                      UserSession.username.isNotEmpty
                          ? UserSession.username
                          : 'مستخدم',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // البريد الإلكتروني
                    Text(
                      UserSession.email.isNotEmpty
                          ? UserSession.email
                          : 'user@example.com',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // قائمة العناصر
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 8),
                _buildDrawerItem(
                  context,
                  icon: Icons.dashboard,
                  title: 'لوحة التحكم',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, RoutesNames.dashboard);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.people,
                  title: 'الموظفين',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, RoutesNames.employees);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.business_center,
                  title: 'المشاريع',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, RoutesNames.projects);
                  },
                ),

                ListTile(
                  leading: FutureBuilder<int>(
                    future: SqlDb().getUnreadNotificationsCount(currentUserId),
                    builder: (context, snapshot) {
                      int count = snapshot.data ?? 0;
                      return badges.Badge(
                        badgeContent: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                        badgeAnimation: badges.BadgeAnimation.slide(),
                        child: const Icon(Icons.notifications),
                      );
                    },
                  ),
                  title: const Text('الإشعارات'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, RoutesNames.notifications);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.receipt_long,
                  title: 'الفواتير',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, RoutesNames.invoices);
                  },
                ),
                const Divider(
                  color: Color(0xFFE5E7EB),
                  thickness: 1,
                  height: 24,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.logout,
                  title: 'خروج',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      RoutesNames.login,
                      (route) => false,
                    );
                  },
                  isLogout: true,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
    bool isLogout = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.red.shade400 : colorScheme.primary,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: isLogout ? Colors.red.shade400 : colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      splashColor: colorScheme.secondary.withOpacity(0.1),
      hoverColor: colorScheme.secondary.withOpacity(0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildNotificationBadge(BuildContext context, {required int count}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
