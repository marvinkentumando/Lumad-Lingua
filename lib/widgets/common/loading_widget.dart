import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.forestGreen),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              message!,
              style: const TextStyle(
                color: AppColors.darkCharcoal,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
