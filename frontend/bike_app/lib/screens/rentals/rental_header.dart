import 'package:bike_app/screens/rentals/rental_history_screen.dart';
import 'package:bike_app/theme/theme.dart';
import 'package:flutter/material.dart';

/// The one header every rental-flow screen uses — back button, eyebrow,
/// title (with an optional brass-highlighted trailing word), optional
/// description, and a consistent "MY BOOKINGS" shortcut. Having every
/// step build this same widget is what makes back navigation and
/// layout actually consistent across the flow instead of each screen
/// improvising its own header.
class RentalHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? highlightSuffix;
  final String? description;
  final double titleFontSize;
  final bool showBookingsLink;

  const RentalHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.highlightSuffix,
    this.description,
    this.titleFontSize = 36,
    this.showBookingsLink = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BackButton(
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
              ),
              if (showBookingsLink)
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const RentalHistoryScreen(),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.history, color: AppColors.brass, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'MY BOOKINGS',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: AppColors.brass,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            eyebrow,
            style: const TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: AppColors.brass,
            ),
          ),
          const SizedBox(height: 14),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: titleFontSize,
                fontWeight: FontWeight.w800,
                height: 1.08,
                color: AppColors.cream,
              ),
              children: [
                TextSpan(text: title),
                if (highlightSuffix != null)
                  TextSpan(
                    text: highlightSuffix,
                    style: const TextStyle(color: AppColors.brass),
                  ),
              ],
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 18),
            Text(
              description!,
              style: const TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: 14,
                height: 1.6,
                color: AppColors.muted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.line),
        ),
        child: const Icon(Icons.arrow_back, color: AppColors.cream, size: 18),
      ),
    );
  }
}
