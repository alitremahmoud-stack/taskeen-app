import 'package:flutter/material.dart';
import '../../core/db_helper.dart';
import '../../models/project_model.dart';
import '../../models/employee_model.dart';
import '../../core/routes_names.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final Project project;
  const ProjectDetailsScreen({super.key, required this.project});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final SqlDb _sqlDb = SqlDb();
  List<Employee> _assignedEmployees = [];

  @override
  void initState() {
    super.initState();
    _loadAssignedEmployees();
  }

  Future<void> _loadAssignedEmployees() async {
    List<Employee> employees = await _sqlDb.getEmployeesForProject(
      widget.project.id!,
    );
    setState(() {
      _assignedEmployees = employees;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('تفاصيل ${widget.project.name}'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة تفاصيل المشروع
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.business_center,
                            color: colorScheme.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.project.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      height: 24,
                      thickness: 1,
                      color: Color(0xFFE5E7EB),
                    ),
                    _buildDetailRow(
                      context,
                      icon: Icons.location_on,
                      label: 'الموقع',
                      value: widget.project.location,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      icon: Icons.flag,
                      label: 'الحالة',
                      value: widget.project.status,
                      valueColor: _getStatusColor(colorScheme),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      icon: Icons.attach_money,
                      label: 'الميزانية',
                      value: '${widget.project.budget.toStringAsFixed(2)} د.ل',
                      valueColor: Colors.green.shade700,
                      valueBold: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // عنوان قسم الموظفين مع زر الإضافة (مع تحديد عرض الزر لمنع الخطأ)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الموظفون المعينون',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                // 🔥 الحل: تحديد عرض ثابت للزر
                SizedBox(
                  width: 130,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        RoutesNames.assignEmployees,
                        arguments: widget.project,
                      );
                      if (result == true) {
                        _loadAssignedEmployees();
                      }
                    },
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('تعيين موظف'),
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
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // قائمة الموظفين المعينين (كما هي تماماً)
            FutureBuilder<List<Employee>>(
              future: _sqlDb.getEmployeesForProject(widget.project.id!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('خطأ: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('لا يوجد موظفون معينون لهذا المشروع'),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final employee = snapshot.data![index];
                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colorScheme.primary.withOpacity(0.1),
                          child: Text(
                            employee.name[0].toUpperCase(),
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          employee.name,
                          style: theme.textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          employee.role,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ColorScheme colorScheme) {
    switch (widget.project.status.toLowerCase()) {
      case 'قيد التنفيذ':
      case 'in progress':
        return Colors.orange;
      case 'مكتمل':
      case 'منتهي':
      case 'completed':
        return Colors.green;
      case 'ملغي':
      case 'متوقف':
      case 'cancelled':
        return Colors.red;
      default:
        return colorScheme.primary;
    }
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool valueBold = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: valueColor ?? colorScheme.primary,
              fontWeight: valueBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
