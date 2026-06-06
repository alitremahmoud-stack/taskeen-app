class Employee {
  final int? id;
  final int userId;
  final String name;
  final String address; // العنوان
  final String phone; // رقم الهاتف
  final String role; // المنصب
  final String birthDate; // تاريخ الميلاد

  Employee({
    this.id,
    required this.userId,
    required this.name,
    required this.address,
    required this.phone,
    required this.role,
    required this.birthDate,
  });

  // من قاعدة البيانات إلى الكائن
  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      address: map['address'],
      phone: map['phone'],
      role: map['role'],
      birthDate: map['birthDate'],
    );
  }

  // من الكائن إلى قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'address': address,
      'phone': phone,
      'role': role,
      'birthDate': birthDate,
    };
  }
}
