// widgets/custom_employee_card.dart
import 'package:flutter/material.dart';
import '../models/employee_model.dart';
import '../core/routes_names.dart';

class CustomEmployeeCard extends StatelessWidget {
  final Employee employee;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final Future<void> Function() onDelete;

  const CustomEmployeeCard({
    super.key,
    required this.employee,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: colorScheme.primary.withOpacity(0.1),
                child: Text(
                  employee.name.isNotEmpty ? employee.name[0].toUpperCase() : '?',
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.work_outline, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          employee.role,
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit_outlined, color: colorScheme.secondary),
                    onPressed: onEdit,
                    tooltip: 'تعديل',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('حذف الموظف'),
                          content: Text('هل أنت متأكد من حذف الموظف "${employee.name}"؟'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              child: const Text('حذف'),
                            ),
                          ],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ) ?? false;
                      if (confirm) await onDelete();
                    },
                    tooltip: 'حذف',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}