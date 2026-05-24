import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({
    super.key,
    required this.category,
    this.radius = 20,
  });

  final String category;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final letter =
        category.isNotEmpty ? category.substring(0, 1).toUpperCase() : '?';
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryLight,
      child: Text(
        letter,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: radius * 0.9,
        ),
      ),
    );
  }
}
