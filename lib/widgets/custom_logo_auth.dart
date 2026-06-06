import 'package:flutter/material.dart';

class CustomLogoAuth extends StatelessWidget {
  final double size;
  final String imagePath;

  const CustomLogoAuth({
    super.key,
    this.size = 80,
    this.imagePath = "assets/images/logo.jpg",
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  Icons.business_center,
                  size: size * 0.5,
                  color: colorScheme.primary,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
