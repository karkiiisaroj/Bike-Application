import 'package:flutter/material.dart';
import '../theme/theme.dart';

class AtelierTextField extends StatelessWidget {
  const AtelierTextField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'IBMPlexSans',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.6,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontFamily: 'IBMPlexSans',
            color: AppColors.cream,
            fontSize: 14,
          ),
          decoration: InputDecoration(hintText: hint),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
