import 'package:flutter/material.dart';
import '../../core/db_helper.dart';
import '../../widgets/custom_logo_auth.dart';
import '../../widgets/custom_text_form.dart';
import '../../widgets/custom_button_auth.dart';
import '../../core/user_session.dart';
import '../../core/routes_names.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final SqlDb _sqlDb = SqlDb();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _loginUser() async {
    // التحقق من صحة الحقول باستخدام Form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    String username = _usernameController.text.trim();
    String password = _passwordController.text;

    try {
      // 1. جلب المستخدم من قاعدة البيانات
      Map<String, dynamic>? user = await _sqlDb.getUserByUsername(username);
      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('اسم المستخدم غير موجود'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 2. التحقق من كلمة المرور
      if (user['password'] != password) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('كلمة المرور غير صحيحة'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // ✅ تخزين بيانات المستخدم في المتغيرات الثابتة
      UserSession.userId = user['id'];
      UserSession.username = user['username'];
      UserSession.email = user['email'];

      // 3. تسجيل الدخول بنجاح
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تسجيل الدخول بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, RoutesNames.dashboard);
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
    _passwordController.dispose();
    _usernameFocusNode.dispose();
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
                        "مرحباً بك",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "تسجيل الدخول للمتابعة",
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
                        obscureText: false,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال اسم المستخدم';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                        focusNode: _usernameFocusNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(
                            context,
                          ).requestFocus(_passwordFocusNode);
                        },
                        prefixIcon: Icon(
                          Icons.person_outline,
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
                        hinttext: "أدخل كلمة المرور",
                        mycontroller: _passwordController,
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى إدخال كلمة المرور';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.done,
                        focusNode: _passwordFocusNode,
                        onFieldSubmitted: (_) => _loginUser(),
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

                      // زر تسجيل الدخول الرئيسي
                      CustomButtonAuth(
                        title: "تسجيل الدخول",
                        onPressed: _loginUser,
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
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "ليس لديك حساب؟ ",
                            style: theme.textTheme.bodyMedium,
                          ),
                          GestureDetector(
                            onTap: _isLoading
                                ? null
                                : () {
                                    Navigator.pushNamed(
                                      context,
                                      RoutesNames.signUp,
                                    );
                                  },
                            child: Text(
                              "إنشاء حساب",
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
