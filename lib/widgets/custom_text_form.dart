import 'package:flutter/material.dart';

class CustomTextForm extends StatelessWidget {
  // الخصائص الأساسية (تم الاحتفاظ بالقديمة)
  final String hinttext;
  final TextEditingController mycontroller;
  final bool obscureText;

  // الخصائص الجديدة (اختيارية للتوافق مع الاستخدامات القديمة)
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final void Function(String)? onFieldSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool enabled;

  const CustomTextForm({
    super.key,
    required this.hinttext,
    required this.mycontroller,
    this.obscureText = false,
    this.validator,
    this.textInputAction,
    this.focusNode,
    this.onFieldSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextFormField(
      controller: mycontroller,
      obscureText: obscureText,
      validator: validator,
      textInputAction: textInputAction,
      focusNode: focusNode,
      onFieldSubmitted: onFieldSubmitted,
      keyboardType: keyboardType,
      enabled: enabled,
      style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.primary),
      decoration: InputDecoration(
        hintText: hinttext,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: Colors.grey.shade500,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        filled: true,
        fillColor: colorScheme.surface,
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: prefixIcon,
              )
            : null,
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: suffixIcon,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.secondary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        errorStyle: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
      ),
    );
  }
}
