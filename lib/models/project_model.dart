class Project {
  final int? id; // معرف فريد (سيقوم SQLite بتوليده تلقائياً)
  final int userId;
  final String name; // اسم المشروع
  final String location; // الموقع
  final String status; // حالته (قيد التنفيذ، منتهي...)
  final double budget; // الميزانية

  Project({
    this.id,
    required this.name,
    required this.location,
    required this.status,
    required this.budget,
    required this.userId,
  });

  // 1. تحويل من قاعدة البيانات (Map) إلى كائن (Object) - لقراءة البيانات
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      location: map['location'],
      status: map['status'],
      budget: map['budget'],
      userId: map['user_id'],
    );
  }

  // 2. تحويل من كائن (Object) إلى قاعدة بيانات (Map) - لحفظ البيانات
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'status': status,
      'budget': budget,
      'user_id': userId,
    };
  }
}
