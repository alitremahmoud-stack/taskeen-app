class NotificationModel {
  final int? id;
  final int userId;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      body: map['body'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      isRead: map['is_read'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'created_at': createdAt.millisecondsSinceEpoch,
      'is_read': isRead ? 1 : 0,
    };
  }
}
