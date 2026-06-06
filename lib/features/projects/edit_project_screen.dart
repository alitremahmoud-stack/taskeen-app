import 'package:flutter/material.dart';
import '../../core/db_helper.dart';
import '../../models/project_model.dart';
import '../../widgets/custom_text_form.dart';
import '../../widgets/custom_button_auth.dart';
import 'projects_screen.dart';
import '../../core/user_session.dart';

class EditProjectScreen extends StatefulWidget {
  final Project project;
  const EditProjectScreen({super.key, required this.project});

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _budgetController;

  late String _selectedStatus;
  final List<String> _statusOptions = [
    'قيد التنفيذ',
    'منتهي',
    'متوقف',
    'قيد الدراسة',
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final SqlDb _sqlDb = SqlDb();
  bool _isLoading = false;

  // Focus nodes للتنقل بين الحقول
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _locationFocusNode = FocusNode();
  final FocusNode _budgetFocusNode = FocusNode();
  int currentUserId = UserSession.userId;

  @override
  void initState() {
    super.initState();
    // تعبئة الحقول بالبيانات القديمة
    _nameController = TextEditingController(text: widget.project.name);
    _locationController = TextEditingController(text: widget.project.location);
    _budgetController = TextEditingController(
      text: widget.project.budget.toString(),
    );
    _selectedStatus = widget.project.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _budgetController.dispose();
    _nameFocusNode.dispose();
    _locationFocusNode.dispose();
    _budgetFocusNode.dispose();
    super.dispose();
  }

  Future<void> _updateProject() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // إنشاء كائن المشروع المحدث
      Project updatedProject = Project(
        id: widget.project.id,
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        status: _selectedStatus,
        budget: double.tryParse(_budgetController.text.trim()) ?? 0.0,
        userId: currentUserId,
      );

      // تحديث البيانات في قاعدة البيانات
      await _sqlDb.updateProject(updatedProject);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث المشروع بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      // العودة إلى شاشة المشاريع مع تمرير إشارة للتحديث
      // Navigator.pop(context, true);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ProjectsScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('تعديل مشروع: ${widget.project.name}'),
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
            color: colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // العنوان
                    Text(
                      'تعديل بيانات المشروع',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // اسم المشروع
                    Text(
                      'اسم المشروع',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextForm(
                      hinttext: 'أدخل اسم المشروع',
                      mycontroller: _nameController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال اسم المشروع';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                      focusNode: _nameFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_locationFocusNode);
                      },
                      prefixIcon: Icon(
                        Icons.business_center,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // موقع المشروع
                    Text(
                      'الموقع',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextForm(
                      hinttext: 'أدخل موقع المشروع',
                      mycontroller: _locationController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال الموقع';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                      focusNode: _locationFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_budgetFocusNode);
                      },
                      prefixIcon: Icon(
                        Icons.location_on,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // الميزانية
                    Text(
                      'الميزانية',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextForm(
                      hinttext: 'أدخل الميزانية (بالدولار)',
                      mycontroller: _budgetController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال الميزانية';
                        }
                        final budget = double.tryParse(value.trim());
                        if (budget == null) {
                          return 'الرجاء إدخال رقم صحيح';
                        }
                        if (budget <= 0) {
                          return 'الميزانية يجب أن تكون أكبر من 0';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                      focusNode: _budgetFocusNode,
                      prefixIcon: Icon(
                        Icons.attach_money,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // حالة المشروع (قائمة منسدلة)
                    Text(
                      'حالة المشروع',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.secondary,
                            width: 1.5,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.flag,
                          color: colorScheme.primary,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      dropdownColor: Colors.white,
                      items: _statusOptions.map((String status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(status, style: theme.textTheme.bodyLarge),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() => _selectedStatus = newValue!);
                      },
                    ),
                    const SizedBox(height: 32),

                    // زر التحديث
                    CustomButtonAuth(
                      title: 'تحديث المشروع',
                      onPressed: _isLoading ? null : _updateProject,
                      color: colorScheme.secondary,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
