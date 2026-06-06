import 'package:flutter/material.dart';
import '../../core/db_helper.dart';
import '../../models/invoice_model.dart';
import '../../models/project_model.dart';
import '../../widgets/custom_text_form.dart';
import '../../widgets/custom_button_auth.dart';
import '../../core/routes_names.dart';
import '../../core/user_session.dart';


class EditInvoiceScreen extends StatefulWidget {
  final Invoice invoice;
  const EditInvoiceScreen({super.key, required this.invoice});

  @override
  State<EditInvoiceScreen> createState() => _EditInvoiceScreenState();
}

class _EditInvoiceScreenState extends State<EditInvoiceScreen> {
  late TextEditingController _amountController;
  late TextEditingController _dateController;
  late TextEditingController _descriptionController;
  int? _selectedProjectId;
  late String _selectedStatus;
  final List<String> _statusOptions = ['غير مدفوعة', 'مدفوعة', 'مدفوعة جزئياً'];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final SqlDb _sqlDb = SqlDb();
  List<Project> _projects = [];
  bool _isLoadingProjects = true;
  bool _isSaving = false;

  // Focus nodes
  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _dateFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  int currentUserId = UserSession.userId;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.invoice.amount.toString(),
    );
    _dateController = TextEditingController(text: widget.invoice.date);
    _descriptionController = TextEditingController(
      text: widget.invoice.description,
    );
    _selectedProjectId = widget.invoice.projectId;
    _selectedStatus = widget.invoice.status;
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoadingProjects = true);
    try {
      List<Project> projects = await _sqlDb.getAllProjects(currentUserId);
      if (mounted) {
        setState(() {
          _projects = projects;
          _isLoadingProjects = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingProjects = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل المشاريع: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateInvoice() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;
    if (_selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار مشروع'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      Invoice updatedInvoice = Invoice(
        id: widget.invoice.id,
        userId: currentUserId,
        projectId: _selectedProjectId!,
        amount: double.tryParse(_amountController.text.trim()) ?? 0.0,
        date: _dateController.text.trim(),
        status: _selectedStatus,
        description: _descriptionController.text.trim(),
      );

      await _sqlDb.updateInvoice(updatedInvoice, currentUserId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث الفاتورة بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      // Navigator.pop(context, true);
      Navigator.pushNamedAndRemoveUntil(
        context,
        RoutesNames.invoices,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    _amountFocusNode.dispose();
    _dateFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('تعديل فاتورة #${widget.invoice.id}'),
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
                    Text(
                      'تعديل بيانات الفاتورة',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // اختيار المشروع
                    Text(
                      'المشروع',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isLoadingProjects
                        ? const Center(child: CircularProgressIndicator())
                        : DropdownButtonFormField<int>(
                            value: _selectedProjectId,
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
                                child: Text(
                                  project.name,
                                  style: theme.textTheme.bodyLarge,
                                ),
                              );
                            }).toList(),
                            onChanged: (int? value) {
                              setState(() => _selectedProjectId = value);
                            },
                            validator: (value) {
                              if (value == null) return 'الرجاء اختيار مشروع';
                              return null;
                            },
                          ),
                    const SizedBox(height: 20),

                    // المبلغ
                    Text(
                      'المبلغ',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextForm(
                      hinttext: 'أدخل المبلغ',
                      mycontroller: _amountController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال المبلغ';
                        }
                        final amount = double.tryParse(value.trim());
                        if (amount == null) return 'الرجاء إدخال رقم صحيح';
                        if (amount <= 0) return 'المبلغ يجب أن يكون أكبر من 0';
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                      focusNode: _amountFocusNode,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_dateFocusNode),
                      prefixIcon: Icon(
                        Icons.attach_money,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // التاريخ
                    Text(
                      'التاريخ',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextForm(
                      hinttext: 'YYYY-MM-DD',
                      mycontroller: _dateController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال التاريخ';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                      focusNode: _dateFocusNode,
                      onFieldSubmitted: (_) => FocusScope.of(
                        context,
                      ).requestFocus(_descriptionFocusNode),
                      prefixIcon: Icon(
                        Icons.calendar_today,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // حالة الفاتورة
                    Text(
                      'حالة الفاتورة',
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
                    const SizedBox(height: 20),

                    // الوصف
                    Text(
                      'الوصف (اختياري)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextForm(
                      hinttext: 'أدخل وصفاً للفاتورة',
                      mycontroller: _descriptionController,
                      textInputAction: TextInputAction.done,
                      focusNode: _descriptionFocusNode,
                      onFieldSubmitted: (_) => _updateInvoice(),
                      prefixIcon: Icon(
                        Icons.description,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // زر التحديث
                    CustomButtonAuth(
                      title: 'تحديث الفاتورة',
                      onPressed: _isSaving ? null : _updateInvoice,
                      color: colorScheme.secondary,
                      isLoading: _isSaving,
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
