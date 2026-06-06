import 'package:flutter/material.dart';

class CustomButtonAuth extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? textColor;
  final bool isLoading;

  const CustomButtonAuth({
    super.key,
    required this.title,
    this.onPressed,
    this.color,
    this.textColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // اللون الأساسي: إما الممرر أو secondary من الثيم
    final buttonColor = color ?? colorScheme.secondary;
    // لون النص: إما الممرر أو الأبيض
    final foregroundColor = textColor ?? Colors.white;

    return ElevatedButton(
      onPressed: (isLoading || onPressed == null) ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: foregroundColor,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        disabledBackgroundColor: buttonColor.withOpacity(0.6),
        disabledForegroundColor: foregroundColor.withOpacity(0.7),
        textStyle: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      child: isLoading
          ? SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
              ),
            )
          : Text(title),
    );
  }
}
