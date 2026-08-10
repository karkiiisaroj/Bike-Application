import 'package:bike_app/models/bike_model.dart';
import 'package:bike_app/theme/theme.dart';
import 'package:flutter/material.dart';

/// Detail screen for a single bike, reached from the Explore button on
/// BikesScreen. Currently only shows fields confirmed to exist on the
/// Bike model (name, category, heroImage) — extend with real specs
/// (engine, price, colours, etc.) once the model has them.
class BikeDetailScreen extends StatelessWidget {
  const BikeDetailScreen({super.key, required this.bike});

  final Bike bike;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(backgroundColor: AppColors.ink, title: Text(bike.name)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 280,
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [Color(0x22C08A3E), Colors.transparent],
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Image.network(
                  bike.heroImage,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.brass),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.two_wheeler,
                    size: 160,
                    color: AppColors.mutedDark,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bike.name,
                      style: const TextStyle(
                        fontFamily: 'IBMPlexSans',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cream,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.panel,
                        border: Border.all(color: AppColors.line),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        bike.category.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'IBMPlexSans',
                          fontSize: 11,
                          letterSpacing: 1.2,
                          color: AppColors.brass,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // TODO: once Bike has real fields (price, engine,
                    // description, colours, etc.), render them here —
                    // e.g. a spec table like the one on the Our Story
                    // timeline cards.
                    const Text(
                      'Full specifications coming soon.',
                      style: TextStyle(
                        fontFamily: 'IBMPlexSans',
                        color: AppColors.muted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
