import 'package:bike_app/theme/theme.dart';
import 'package:flutter/material.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final String orderNumber;

  const OrderConfirmationScreen({super.key, required this.orderNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 56,
                  color: AppColors.brass,
                ),
                const SizedBox(height: 20),
                const Text(
                  'ORDER PLACED',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: AppColors.brass,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  orderNumber,
                  style: const TextStyle(
                    fontFamily: 'IBMPlexSans',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.cream,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "We'll reach out to confirm delivery details.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'IBMPlexSans',
                    fontSize: 14,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.brass),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => Navigator.of(
                      context,
                    ).popUntil((route) => route.isFirst),
                    child: const Text(
                      'BACK TO HOME',
                      style: TextStyle(
                        fontFamily: 'IBMPlexSans',
                        fontWeight: FontWeight.w700,
                        color: AppColors.brass,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
