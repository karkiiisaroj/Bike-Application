import 'package:flutter/material.dart';
import '../theme/theme.dart';

class GoogleAuthButton extends StatelessWidget {
  const GoogleAuthButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
  });

  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.line),
        ),
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.brass,
                ),
              )
            : const Icon(Icons.g_mobiledata, size: 26, color: AppColors.brass),
        label: const Text(
          'CONTINUE WITH GOOGLE',
          style: TextStyle(
            fontFamily: 'IBMPlexSans',
            fontSize: 12,
            letterSpacing: 1,
            color: AppColors.cream,
          ),
        ),
      ),
    );
  }
}
