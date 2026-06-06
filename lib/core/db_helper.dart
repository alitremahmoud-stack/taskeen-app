import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:taskeen_app/models/notification_model.dart';
import '../models/project_model.dart';
import '../models/employee_model.dart';
import '../models/invoice_model.dart';

class SqlDb {
  static Database? _db;

  // 1. استخدام getter للحصول على قاعدة البيانات
  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  // 2. تهيئة قاعدة البيانات
  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'construction.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  // 3. إنشاء الجداول
  Future<void> _onCreate(Database db, int version) async {
    // جدول المستخدمين
    await db.execute('''
  CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL
  )
''');
    // جدول المشاريع
    await db.execute('''
  CREATE TABLE projects (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    location TEXT NOT NULL,
    status TEXT NOT NULL,
    budget REAL NOT NULL
  )
''');

    // جدول الموظفين
    await db.execute('''
  CREATE TABLE employees (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    phone TEXT NOT NULL,
    role TEXT NOT NULL,
    birthDate TEXT NOT NULL
  )
''');

    // جدول ربط الموظفين بالمشاريع
    await db.execute('''
      CREATE TABLE project_employees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        employee_id INTEGER NOT NULL
      )
    ''');

    await db.execute('''
  CREATE TABLE invoices (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    project_id INTEGER NOT NULL,
    amount REAL NOT NULL,
    date TEXT NOT NULL,
    status TEXT NOT NULL,
    description TEXT,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
  )
''');

    await db.execute('''
  CREATE TABLE notifications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    is_read INTEGER DEFAULT 0
  )
''');
  }

  // ========== دوال إضافية للمشاريع ==========
  Future<int> updateProject(Project project) async {
    Database mydb = await db;
    return await mydb.update(
      'projects',
      project.toMap(),
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  Future<int> deleteProject(int id) async {
    Database mydb = await db;
    return await mydb.delete('projects', where: 'id = ?', whereArgs: [id]);
  }

  // ========== دوال المشاريع ==========
  Future<int> insertProject(Project project) async {
    Database mydb = await db; // تأكد من استخدام this.db
    return await mydb.insert('projects', project.toMap());
  }

  Future<List<Project>> getAllProjects(int userId) async {
    Database mydb = await db;
    List<Map<String, dynamic>> maps = await mydb.query(
      'projects',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => Project.fromMap(maps[i]));
  }

  // ========== دوال الموظفين ==========
  Future<int> insertEmployee(Employee employee) async {
    Database mydb = await db;
    return await mydb.insert('employees', employee.toMap());
  }

  Future<List<Employee>> getAllEmployees(int userId) async {
    Database mydb = await db;
    List<Map<String, dynamic>> maps = await mydb.query(
      'employees',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => Employee.fromMap(maps[i]));
  }

  // ========== دوال المستخدمين ==========

  // إضافة مستخدم جديد (تسجيل)
  Future<int> insertUser(String username, String email, String password) async {
    Database mydb = await this.db;
    return await mydb.insert('users', {
      'username': username,
      'email': email,
      'password': password,
    });
  }

  // جلب مستخدم بناءً على اسم المستخدم (للتسجيل الدخول)
  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    Database mydb = await this.db;
    List<Map<String, dynamic>> results = await mydb.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // التحقق من وجود اسم مستخدم مكرر (اختياري)
  Future<bool> checkUsernameExists(String username) async {
    Database mydb = await this.db;
    List<Map<String, dynamic>> results = await mydb.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return results.isNotEmpty;
  }

  // التحقق من وجود بريد إلكتروني مكرر (اختياري)
  Future<bool> checkEmailExists(String email) async {
    Database mydb = await this.db;
    List<Map<String, dynamic>> results = await mydb.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return results.isNotEmpty;
  }

  // ====== الدوال الجديدة (المفقودة) ======
  Future<int> assignEmployeeToProject(int projectId, int employeeId) async {
    Database mydb = await db;
    return await mydb.insert('project_employees', {
      'project_id': projectId,
      'employee_id': employeeId,
    });
  }

  Future<List<Employee>> getEmployeesForProject(int projectId) async {
    Database mydb = await db;
    try {
      List<Map<String, dynamic>> maps = await mydb.rawQuery(
        '''
      SELECT employees.* FROM employees
      INNER JOIN project_employees ON employees.id = project_employees.employee_id
      WHERE project_employees.project_id = ?
    ''',
        [projectId],
      );
      return List.generate(maps.length, (i) => Employee.fromMap(maps[i]));
    } catch (e) {
      print("❌ خطأ في getEmployeesForProject: $e");
      return []; // إرجاع قائمة فارغة كبديل
    }
  }

  Future<List<Employee>> getUnassignedEmployees(int projectId) async {
    Database mydb = await db;
    try {
      List<Map<String, dynamic>> maps = await mydb.rawQuery(
        '''
      SELECT * FROM employees
      WHERE id NOT IN (
        SELECT employee_id FROM project_employees WHERE project_id = ?
      )
    ''',
        [projectId],
      );
      return List.generate(maps.length, (i) => Employee.fromMap(maps[i]));
    } catch (e) {
      print("❌ خطأ في getUnassignedEmployees: $e");
      return []; // إرجاع قائمة فارغة كبديل
    }
  }

  // ========== دوال إضافية للموظفين ==========

  // تعديل موظف
  Future<int> updateEmployee(Employee employee) async {
    Database mydb = await this.db;
    return await mydb.update(
      'employees',
      employee.toMap(),
      where: 'id = ? AND user_id = ?',
      whereArgs: [employee.id, employee.userId],
    );
  }

  // حذف موظف
  Future<int> deleteEmployee(int id, int userId) async {
    Database mydb = await this.db;
    return await mydb.delete(
      'employees',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  // ========== دوال الفواتير ==========

  // إضافة فاتورة
  Future<int> insertInvoice(Invoice invoice) async {
    Database mydb = await this.db;
    return await mydb.insert('invoices', invoice.toMap());
  }

  // جلب جميع الفواتير
  Future<List<Invoice>> getAllInvoices(int userId) async {
    Database mydb = await this.db;
    List<Map<String, dynamic>> maps = await mydb.query(
      'invoices',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => Invoice.fromMap(maps[i]));
  }

  // جلب فواتير مشروع معين
  Future<List<Invoice>> getInvoicesForProject(int projectId, int userId) async {
    Database mydb = await this.db;
    List<Map<String, dynamic>> maps = await mydb.query(
      'invoices',
      where: 'project_id = ? AND user_id = ?',
      whereArgs: [projectId, userId],
    );
    return List.generate(maps.length, (i) => Invoice.fromMap(maps[i]));
  }

  // تحديث فاتورة
  Future<int> updateInvoice(Invoice invoice, int userId) async {
    Database mydb = await this.db;
    return await mydb.update(
      'invoices',
      invoice.toMap(),
      where: 'id = ? AND user_id = ?',
      whereArgs: [invoice.id, userId],
    );
  }

  // حذف فاتورة
  Future<int> deleteInvoice(int id, int userId) async {
    Database mydb = await this.db;
    return await mydb.delete(
      'invoices',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  // ========== دوال الإشعارات ==========

  // إضافة إشعار
  Future<int> insertNotification(NotificationModel notification) async {
    Database mydb = await this.db;
    return await mydb.insert('notifications', notification.toMap());
  }

  // جلب جميع الإشعارات (الأحدث أولاً)
  Future<List<NotificationModel>> getAllNotifications(int userId) async {
    Database mydb = await this.db;
    List<Map<String, dynamic>> maps = await mydb.query(
      'notifications',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return List.generate(
      maps.length,
      (i) => NotificationModel.fromMap(maps[i]),
    );
  }

  // عدد الإشعارات غير المقروءة
  Future<int> getUnreadNotificationsCount(int userId) async {
    Database mydb = await this.db;
    List<Map<String, dynamic>> maps = await mydb.query(
      'notifications',
      where: 'user_id = ? AND is_read = ?',
      whereArgs: [userId, 0],
    );
    return maps.length;
  }

  // تعيين إشعار كمقروء
  Future<int> markNotificationAsRead(int id, int userId) async {
    Database mydb = await this.db;
    return await mydb.update(
      'notifications',
      {'is_read': 1},
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  // حذف إشعار
  Future<int> deleteNotification(int id, int userId) async {
    Database mydb = await this.db;
    return await mydb.delete(
      'notifications',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }
}
