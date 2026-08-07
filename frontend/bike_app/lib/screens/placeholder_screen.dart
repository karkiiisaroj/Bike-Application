import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Simple "coming soon" screen shown for any home-grid tile that
/// doesn't have a real screen wired up yet. Reached automatically via
/// MaterialApp's onUnknownRoute in main.dart — nothing else needs to
/// reference this directly.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'IBMPlexSans',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.hourglass_empty,
              color: AppColors.mutedDark,
              size: 40,
            ),
            const SizedBox(height: 16),
            Text(
              '$title — coming soon',
              style: const TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: 16,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
