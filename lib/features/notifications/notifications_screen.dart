import 'package:flutter/material.dart';
import '../../core/db_helper.dart';
import '../../models/notification_model.dart';
import '../../widgets/navbar.dart';
import '../../widgets/custom_empty_state.dart';
import '../../widgets/custom_error_state.dart';
import '../../widgets/custom_notification_card.dart';
import '../../core/user_session.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final SqlDb _sqlDb = SqlDb();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;
  int currentUserId = UserSession.userId;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      List<NotificationModel> list = await _sqlDb.getAllNotifications(currentUserId);
      setState(() {
        _notifications = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteNotification(int id) async {
    try {
      await _sqlDb.deleteNotification(id, currentUserId);
      await _loadNotifications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الحذف: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _markAsRead(int id) async {
    try {
      await _sqlDb.markNotificationAsRead(id, currentUserId);
      await _loadNotifications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحديث الحالة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('الإشعارات'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () async {
              for (var n in _notifications) {
                if (!n.isRead) await _sqlDb.markNotificationAsRead(n.id!, currentUserId);
              }
              _loadNotifications();
            },
            child: const Text(
              'تحديد الكل كمقروء',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      drawer: const Navbar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? CustomErrorState(
              message: _errorMessage!,
              onRetry: _loadNotifications,
            )
          : _notifications.isEmpty
          ? CustomEmptyState(
              title: 'لا توجد إشعارات',
              subtitle: 'ستظهر هنا الإشعارات الجديدة',
              icon: Icons.notifications_none,
              buttonText: 'تحديث',
              onButtonPressed: _loadNotifications,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return CustomNotificationCard(
                  notification: notification,
                  onTap: () {
                    if (!notification.isRead) {
                      _markAsRead(notification.id!);
                    }
                  },
                  onDismiss: () => _deleteNotification(notification.id!),
                );
              },
            ),
    );
  }
}
