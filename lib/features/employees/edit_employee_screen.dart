import 'package:flutter/material.dart';
import '../../core/db_helper.dart';
import '../../models/employee_model.dart';
import '../../widgets/custom_text_form.dart';
import '../../widgets/custom_button_auth.dart';
import 'employees_screen.dart';
import '../../core/user_session.dart';

class EditEmployeeScreen extends StatefulWidget {
  final Employee employee;
  const EditEmployeeScreen({super.key, required this.employee});

  @override
  State<EditEmployeeScreen> createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends State<EditEmployeeScreen> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _roleController;
  late TextEditingController _birthDateController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final SqlDb _sqlDb = SqlDb();
  bool _isLoading = false;

  // Focus nodes للتنقل
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _roleFocusNode = FocusNode();
  final FocusNode _birthDateFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.employee.name);
    _addressController = TextEditingController(text: widget.employee.address);
    _phoneController = TextEditingController(text: widget.employee.phone);
    _roleController = TextEditingController(text: widget.employee.role);
    _birthDateController = TextEditingController(
      text: widget.employee.birthDate,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _roleController.dispose();
    _birthDateController.dispose();
    _nameFocusNode.dispose();
    _addressFocusNode.dispose();
    _phoneFocusNode.dispose();
    _roleFocusNode.dispose();
    _birthDateFocusNode.dispose();
    super.dispose();
  }

  Future<void> _updateEmployee() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      Employee updatedEmployee = Employee(
        id: widget.employee.id,
        userId: UserSession.userId,
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        role: _roleController.text.trim(),
        birthDate: _birthDateController.text.trim(),
      );

      await _sqlDb.updateEmployee(updatedEmployee);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث الموظف بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      // Navigator.pop(context, true); // العودة مع تحديث القائمة
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const EmployeesScreen()),
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
        title: Text('تعديل موظف: ${widget.employee.name}'),
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
                      'تعديل بيانات الموظف',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // اسم الموظف
                    Text(
                      'اسم الموظف',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextForm(
                      hinttext: 'أدخل اسم الموظف',
                      mycontroller: _nameController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال اسم الموظف';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                      focusNode: _nameFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_addressFocusNode);
                      },
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // العنوان
                    Text(
                      'العنوان',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextForm(
                      hinttext: 'أدخل عنوان الموظف',
                      mycontroller: _addressController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال العنوان';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                      focusNode: _addressFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_phoneFocusNode);
                      },
                      prefixIcon: Icon(
                        Icons.location_on_outlined,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // رقم الهاتف
                    Text(
                      'رقم الهاتف',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextForm(
                      hinttext: 'أدخل رقم الهاتف',
                      mycontroller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال رقم الهاتف';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                      focusNode: _phoneFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_roleFocusNode);
                      },
                      prefixIcon: Icon(
                        Icons.phone_outlined,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // المنصب
                    Text(
                      'المنصب',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextForm(
                      hinttext: 'أدخل منصب الموظف',
                      mycontroller: _roleController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال المنصب';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                      focusNode: _roleFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(
                          context,
                        ).requestFocus(_birthDateFocusNode);
                      },
                      prefixIcon: Icon(
                        Icons.work_outline,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // تاريخ الميلاد
                    Text(
                      'تاريخ الميلاد',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextForm(
                      hinttext: 'YYYY-MM-DD',
                      mycontroller: _birthDateController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال تاريخ الميلاد';
                        }
                        final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                        if (!regex.hasMatch(value.trim())) {
                          return 'الصيغة المطلوبة: YYYY-MM-DD';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.done,
                      focusNode: _birthDateFocusNode,
                      onFieldSubmitted: (_) => _updateEmployee(),
                      prefixIcon: Icon(
                        Icons.cake_outlined,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // زر التحديث
                    CustomButtonAuth(
                      title: 'تحديث الموظف',
                      onPressed: _isLoading ? null : _updateEmployee,
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
