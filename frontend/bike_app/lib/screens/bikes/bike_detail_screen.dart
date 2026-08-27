import 'package:bike_app/models/bike_model.dart';
import 'package:bike_app/screens/bikes/bike_360_viewer_screen.dart';
import 'package:bike_app/theme/theme.dart';
import 'package:bike_app/widgets/bike_media_viewer.dart';
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
              // Was a raw Image.network — now goes through BikeMediaViewer
              // so swapping in the 3D/rotatable viewer later is a one-file
              // change (see bike_media_viewer.dart).
              BikeMediaViewer(bike: bike, height: 280),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => Bike360ViewerScreen(bike: bike),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.threed_rotation,
                      color: AppColors.brass,
                      size: 18,
                    ),
                    label: const Text(
                      'VIEW IN 360°',
                      style: TextStyle(
                        fontFamily: 'IBMPlexSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: AppColors.brass,
                      ),
                    ),
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

                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => Bike360ViewerScreen(bike: bike),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.brass),
                      ),
                      icon: const Icon(
                        Icons.threesixty,
                        size: 18,
                        color: AppColors.brass,
                      ),
                      label: const Text(
                        '360° VIEW',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSans',
                          fontSize: 12,
                          letterSpacing: 1,
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
