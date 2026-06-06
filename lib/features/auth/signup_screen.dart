import 'package:flutter/material.dart';
import '../../core/db_helper.dart';
import '../../widgets/custom_logo_auth.dart';
import '../../widgets/custom_text_form.dart';
import '../../widgets/custom_button_auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final SqlDb _sqlDb = SqlDb();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _registerUser() async {
    // التحقق من صحة الحقول
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    try {
      // 1. التحقق من وجود اسم مستخدم مكرر
      bool usernameExists = await _sqlDb.checkUsernameExists(username);
      if (usernameExists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('اسم المستخدم موجود بالفعل'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 2. التحقق من وجود بريد إلكتروني مكرر
      bool emailExists = await _sqlDb.checkEmailExists(email);
      if (emailExists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('البريد الإلكتروني موجود بالفعل'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 3. إضافة المستخدم
      await _sqlDb.insertUser(username, email, password);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تسجيل الحساب بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // العودة إلى شاشة الدخول
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // الشعار
                      const CustomLogoAuth(),
                      const SizedBox(height: 24),

                      // العنوان الرئيسي
                      Text(
                        "إنشاء حساب",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "سجل الآن للاستمرار",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // حقل اسم المستخدم
                      Text(
                        "اسم المستخدم",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextForm(
                        hinttext: "أدخل اسم المستخدم",
                        mycontroller: _usernameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال اسم المستخدم';
                          }
                          if (value.trim().length < 3) {
                            return 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                        focusNode: _usernameFocusNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_emailFocusNode);
                        },
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // حقل البريد الإلكتروني
                      Text(
                        "البريد الإلكتروني",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextForm(
                        hinttext: "example@company.com",
                        mycontroller: _emailController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال البريد الإلكتروني';
                          }
                          final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'يرجى إدخال بريد إلكتروني صحيح';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                        focusNode: _emailFocusNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(
                            context,
                          ).requestFocus(_passwordFocusNode);
                        },
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // حقل كلمة المرور
                      Text(
                        "كلمة المرور",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextForm(
                        hinttext: "أدخل كلمة المرور (6 أحرف على الأقل)",
                        mycontroller: _passwordController,
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى إدخال كلمة المرور';
                          }
                          if (value.length < 6) {
                            return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.done,
                        focusNode: _passwordFocusNode,
                        onFieldSubmitted: (_) => _registerUser(),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: colorScheme.primary,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: colorScheme.primary,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 32),

                      // زر التسجيل
                      CustomButtonAuth(
                        title: "إنشاء حساب",
                        onPressed: _isLoading ? null : _registerUser,
                        color: colorScheme.secondary,
                      ),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFFF7A00),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),

                      // رابط العودة إلى تسجيل الدخول
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "لديك حساب بالفعل؟ ",
                            style: theme.textTheme.bodyMedium,
                          ),
                          GestureDetector(
                            onTap: _isLoading
                                ? null
                                : () {
                                    Navigator.pop(context);
                                  },
                            child: Text(
                              "تسجيل الدخول",
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
