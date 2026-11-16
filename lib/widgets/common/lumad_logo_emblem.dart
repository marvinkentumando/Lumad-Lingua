import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Text(
          '"',
          style: GoogleFonts.fredoka(
            fontSize: size * 0.85,
            fontWeight: FontWeight.w700,
            color: AppColors.gold500,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
