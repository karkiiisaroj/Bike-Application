import 'package:flutter/material.dart';
import '../theme/theme.dart';

class AuthSegmentedTabs extends StatelessWidget {
  const AuthSegmentedTabs({
    super.key,
    required this.isLogin,
    required this.onChanged,
  });

  final bool isLogin;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        children: [
          Expanded(
            child: _segment(
              label: 'LOG IN',
              active: isLogin,
              onTap: () => onChanged(true),
            ),
          ),
          Container(width: 1, color: AppColors.line),
          Expanded(
            child: _segment(
              label: 'REGISTER',
              active: !isLogin,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _segment({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Material(
      color: active ? AppColors.brass : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: active ? AppColors.ink : AppColors.cream,
            ),
          ),
        ),
      ),
    );
  }
}
