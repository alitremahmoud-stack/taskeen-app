import 'package:flutter/material.dart';
import '../../models/employee_model.dart';

class EmployeeDetailsScreen extends StatelessWidget {
  final Employee employee;
  const EmployeeDetailsScreen({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('تفاصيل الموظف: ${employee.name}'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: colorScheme.surface.withOpacity(0.5),
                width: 1,
              ),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // الصورة الرمزية والاسم
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: colorScheme.primary.withOpacity(0.1),
                          child: Text(
                            employee.name.isNotEmpty
                                ? employee.name[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'بيانات الموظف',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 3,
                          width: 50,
                          decoration: BoxDecoration(
                            color: colorScheme.secondary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // تفاصيل الموظف (بأيقونات)
                  _buildDetailRow(
                    context,
                    icon: Icons.person_outline,
                    label: 'الاسم',
                    value: employee.name,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    context,
                    icon: Icons.location_on_outlined,
                    label: 'العنوان',
                    value: employee.address,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    context,
                    icon: Icons.phone_outlined,
                    label: 'رقم الهاتف',
                    value: employee.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    context,
                    icon: Icons.work_outline,
                    label: 'المنصب',
                    value: employee.role,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    context,
                    icon: Icons.cake_outlined,
                    label: 'تاريخ الميلاد',
                    value: employee.birthDate,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: colorScheme.primary),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
