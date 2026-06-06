import 'package:flutter/material.dart';
import '../../core/db_helper.dart';
import '../../models/invoice_model.dart';
import '../../models/project_model.dart';
import '../../widgets/custom_text_form.dart';
import '../../widgets/custom_button_auth.dart';
import '../../models/notification_model.dart';
import '../../core/routes_names.dart';
import '../../core/user_session.dart';

class AddInvoiceScreen extends StatefulWidget {
  const AddInvoiceScreen({super.key});

  @override
  State<AddInvoiceScreen> createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends State<AddInvoiceScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  int? _selectedProjectId;
  String _selectedStatus = 'غير مدفوعة';
  final List<String> _statusOptions = ['غير مدفوعة', 'مدفوعة', 'مدفوعة جزئياً'];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final SqlDb _sqlDb = SqlDb();
  List<Project> _projects = [];
  int currentUserId = UserSession.userId;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    List<Project> projects = await _sqlDb.getAllProjects(currentUserId);
    setState(() {
      _projects = projects;
      if (projects.isNotEmpty) {
        _selectedProjectId = projects.first.id;
      }
    });
  }

  Future<void> _saveInvoice() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedProjectId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('الرجاء اختيار مشروع')));
        return;
      }

      Invoice newInvoice = Invoice(
        projectId: _selectedProjectId!,
        userId: currentUserId,
        amount: double.tryParse(_amountController.text) ?? 0.0,
        date: _dateController.text,
        status: _selectedStatus,
        description: _descriptionController.text,
      );

      await _sqlDb.insertInvoice(newInvoice);
      // إضافة إشعار بعد حفظ الفاتورة
      await _sqlDb.insertNotification(
  NotificationModel(
    title: 'فاتورة جديدة',
    userId: currentUserId,
    body: 'تم إضافة فاتورة بقيمة: ${_amountController.text} د.ل',
    createdAt: DateTime.now(),
  ),
);

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, RoutesNames.invoices, (route) => false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('إضافة فاتورة جديدة'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'بيانات الفاتورة الجديدة',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // اختيار المشروع
                    DropdownButtonFormField<int>(
                      value: _selectedProjectId,
                      decoration: InputDecoration(
                        labelText: 'اختر المشروع',
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
                          Icons.business_center,
                          color: colorScheme.primary,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      items: _projects.map((project) {
                        return DropdownMenuItem<int>(
                          value: project.id,
                          child: Text(project.name),
                        );
                      }).toList(),
                      onChanged: (int? value) {
                        setState(() {
                          _selectedProjectId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) return 'الرجاء اختيار مشروع';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // المبلغ
                    CustomTextForm(
                      hinttext: 'أدخل المبلغ',
                      mycontroller: _amountController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال المبلغ';
                        }
                        if (double.tryParse(value) == null) {
                          return 'الرجاء إدخال رقم صحيح';
                        }
                        return null;
                      },
                      prefixIcon: Icon(
                        Icons.attach_money,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // التاريخ
                    CustomTextForm(
                      hinttext: 'YYYY-MM-DD',
                      mycontroller: _dateController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال التاريخ';
                        }
                        return null;
                      },
                      prefixIcon: Icon(
                        Icons.calendar_today,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // حالة الفاتورة
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: InputDecoration(
                        labelText: 'حالة الفاتورة',
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
                      items: _statusOptions.map((String status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedStatus = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // الوصف
                    CustomTextForm(
                      hinttext: 'الوصف (اختياري)',
                      mycontroller: _descriptionController,
                      // maxLines: 3,
                      prefixIcon: Icon(
                        Icons.description,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // زر الحفظ
                    CustomButtonAuth(
                      title: 'حفظ الفاتورة',
                      onPressed: _saveInvoice,
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
