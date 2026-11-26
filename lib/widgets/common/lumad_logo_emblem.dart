import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

class LumadLogoEmblem extends StatelessWidget {
  final double size;
  final double borderRadius;

  const LumadLogoEmblem({
    super.key,
    this.size = 56.0,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          'assets/images/logo_2.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.forest700,
              alignment: Alignment.center,
              child: Icon(Icons.menu_book, color: AppColors.gold500, size: size * 0.5),
            );
          },
        ),
      ),
    );
  }
}
