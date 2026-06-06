import 'package:flutter/material.dart';
import '../../core/db_helper.dart';
import '../../models/employee_model.dart';
import '../../widgets/navbar.dart';
import '../../widgets/custom_empty_state.dart';
import '../../widgets/custom_error_state.dart';
import '../../widgets/custom_employee_card.dart';
import '../../core/routes_names.dart';
import '../../core/user_session.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  final SqlDb _sqlDb = SqlDb();
  int currentUserId = UserSession.userId;

  Future<List<Employee>> _fetchEmployees() async {
    return await _sqlDb.getAllEmployees(currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('إدارة الموظفين'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      drawer: const Navbar(),
      body: RefreshIndicator(
        onRefresh: _fetchEmployees,
        child: FutureBuilder<List<Employee>>(
          future: _fetchEmployees(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return CustomErrorState(
                message: 'حدث خطأ: ${snapshot.error}',
                onRetry: () => setState(() {}),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return CustomEmptyState(
                title: 'لا يوجد موظفون مضافة بعد',
                subtitle: 'اضغط على زر + لإضافة أول موظف',
                icon: Icons.people_outline,
                buttonText: 'إضافة موظف',
                onButtonPressed: () => Navigator.pushNamed(context, RoutesNames.addEmployee)
                    .then((_) => setState(() {})),
              );
            }

            final employees = snapshot.data!;
            return Column(
              children: [
                // بطاقة إحصائية سريعة (يمكن استبدالها بـ CustomStatCard إذا أردت)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'إجمالي الموظفين',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${employees.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: employees.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final employee = employees[index];
                      return CustomEmployeeCard(
                        employee: employee,
                        onTap: () => Navigator.pushNamed(context, RoutesNames.employeeDetails, arguments: employee)
                            .then((_) => setState(() {})),
                        onEdit: () => Navigator.pushNamed(context, RoutesNames.editEmployee, arguments: employee)
                            .then((_) => setState(() {})),
                        onDelete: () async {
                          await _sqlDb.deleteEmployee(employee.id!, currentUserId);
                          if (mounted) setState(() {});
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, RoutesNames.addEmployee).then((_) => setState(() {}));
        },
        backgroundColor: colorScheme.secondary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
