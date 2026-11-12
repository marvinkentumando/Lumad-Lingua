import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class XPBadge extends StatelessWidget {
  final int xp;

  const XPBadge({super.key, required this.xp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.warmYellow,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt, color: AppColors.darkCharcoal, size: 18),
          const SizedBox(width: 4),
          Text(
            '$xp XP',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.darkCharcoal,
            ),
          ),
        ],
      ),
    );
  }
}
