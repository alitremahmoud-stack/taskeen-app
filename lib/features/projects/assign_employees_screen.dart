import 'package:flutter/material.dart';
import '../../core/db_helper.dart';
import '../../models/project_model.dart';
import '../../models/employee_model.dart';
import '../../core/routes_names.dart';

class AssignEmployeesScreen extends StatefulWidget {
  final Project project;
  const AssignEmployeesScreen({super.key, required this.project});

  @override
  State<AssignEmployeesScreen> createState() => _AssignEmployeesScreenState();
}

class _AssignEmployeesScreenState extends State<AssignEmployeesScreen> {
  final SqlDb _sqlDb = SqlDb();
  List<Employee> _unassignedEmployees = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _assigningEmployeeId;

  @override
  void initState() {
    super.initState();
    _loadUnassignedEmployees();
  }

  Future<void> _loadUnassignedEmployees() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      List<Employee> employees = await _sqlDb.getUnassignedEmployees(
        widget.project.id!,
      );
      if (mounted) {
        setState(() {
          _unassignedEmployees = employees;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'حدث خطأ: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _assignEmployee(int employeeId) async {
    if (_assigningEmployeeId != null) return;

    setState(() {
      _assigningEmployeeId = employeeId;
    });

    try {
      await _sqlDb.assignEmployeeToProject(widget.project.id!, employeeId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تعيين الموظف بنجاح'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      await _loadUnassignedEmployees();
      if (!mounted) return;

      Navigator.pop(context);
      Navigator.pushNamed(
        context,
        RoutesNames.projectDetails,
        arguments: widget.project,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل التعيين: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _assigningEmployeeId = null;
        });
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
        title: Text('تعيين موظفين لـ ${widget.project.name}'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadUnassignedEmployees,
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.red.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadUnassignedEmployees,
                        icon: const Icon(Icons.refresh),
                        label: const Text('إعادة المحاولة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.secondary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : _unassignedEmployees.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'جميع الموظفين معينون لهذا المشروع',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'لا يوجد موظفون غير معينين متاحون',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _unassignedEmployees.length,
                  itemBuilder: (context, index) {
                    final employee = _unassignedEmployees[index];
                    final isAssigning = _assigningEmployeeId == employee.id;
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: colorScheme.primary.withOpacity(
                                0.1,
                              ),
                              child: Text(
                                employee.name.isNotEmpty
                                    ? employee.name[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    employee.name,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.primary,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.work_outline,
                                        size: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        employee.role,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: Colors.grey.shade700,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // 🔥 الحل: لف الزر في SizedBox بعرض ثابت
                            SizedBox(
                              width: 90,
                              child: ElevatedButton(
                                onPressed: isAssigning
                                    ? null
                                    : () => _assignEmployee(employee.id!),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.secondary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 10,
                                  ),
                                ),
                                child: isAssigning
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Text('تعيين'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
