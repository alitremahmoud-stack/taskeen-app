import 'package:flutter/material.dart';
import '../models/project_model.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
    this.onDelete,
    this.onEdit,
  });

  // دالة مساعدة لتحديد لون الحالة
  Color _getStatusColor(ColorScheme colorScheme) {
    switch (project.status.toLowerCase()) {
      case 'قيد التنفيذ':
      case 'in progress':
        return Colors.orange;
      case 'مكتمل':
      case 'completed':
        return Colors.green;
      case 'ملغي':
      case 'cancelled':
        return Colors.red;
      default:
        return colorScheme.primary;
    }
  }

  // دالة مساعدة لتحديد أيقونة الحالة
  IconData _getStatusIcon() {
    switch (project.status.toLowerCase()) {
      case 'قيد التنفيذ':
      case 'in progress':
        return Icons.construction;
      case 'مكتمل':
      case 'completed':
        return Icons.check_circle;
      case 'ملغي':
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.business_center;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = _getStatusColor(colorScheme);
    final statusIcon = _getStatusIcon();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.surface.withOpacity(0.5),
          width: 0.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الصف العلوي: الاسم + حالة المشروع
              Row(
                children: [
                  // أيقونة الحالة (دائرية صغيرة)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(statusIcon, size: 20, color: statusColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      project.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // علامة الحالة (Chip)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      project.status,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // صف الموقع
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      project.location,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // أزرار التعديل والحذف (محاذاة لليمين)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // زر التعديل
                  if (onEdit != null)
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: colorScheme.secondary,
                      ),
                      label: Text(
                        'تعديل',
                        style: TextStyle(color: colorScheme.secondary),
                      ),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  // زر الحذف
                  if (onDelete != null)
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.red,
                      ),
                      label: const Text(
                        'حذف',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
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
