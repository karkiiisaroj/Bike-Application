import 'package:bike_app/models/bike_model.dart';
import 'package:bike_app/theme/theme.dart';
import 'package:flutter/material.dart';

/// Renders a bike's hero media on BikeDetailScreen (and anywhere else you
/// show "the bike" as a focal image).
///
/// Today this just renders [Bike.heroImage] as a static network image —
/// functionally identical to what BikeDetailScreen already did. The point
/// of pulling it into its own widget is so that when you add the real
/// rotatable 3D viewer, you change ONE file:
///
///   - swap the body of `build()` below for e.g. a `ModelViewer` (from
///     the `model_viewer_plus` package) pointed at a glTF/GLB URL, or a
///     drag-to-rotate image-sequence widget fed by frame URLs from Django.
///   - every call site (BikeDetailScreen, BikesScreen, banners, etc.)
///     keeps working unchanged since they only ever talk to
///     BikeMediaViewer, not Image.network directly.
///
/// Suggested next step on the Bike model / Django side: add either a
/// `model3dUrl` (glTF) field or a `rotationFrames: List<String>` field,
/// then branch here — if `model3dUrl` is set, show the 3D viewer; else
/// fall back to this static image.
class BikeMediaViewer extends StatelessWidget {
  const BikeMediaViewer({
    super.key,
    required this.bike,
    this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: 40),
  });

  final Bike bike;
  final double? height;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.8,
          colors: [Color(0x22C08A3E), Colors.transparent],
        ),
      ),
      padding: padding,
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
    );
  }
}
