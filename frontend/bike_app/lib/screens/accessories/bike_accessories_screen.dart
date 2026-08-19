import 'package:bike_app/models/accessory_model.dart';
import 'package:bike_app/models/bike_model.dart';
import 'package:bike_app/screens/bikes/bikes_category_screen.dart';
import 'package:bike_app/theme/theme.dart';
import 'package:bike_app/widgets/accessory_widgets.dart';
import 'package:flutter/material.dart';
import 'package:bike_app/services/accessory_service.dart';

/// Accessories filtered to a single bike — link to this from that
/// bike's detail screen, e.g.:
///
/// ```dart
/// OutlinedButton(
///   onPressed: () => Navigator.push(
///     context,
///     MaterialPageRoute(builder: (_) => BikeAccessoriesScreen(bike: bike)),
///   ),
///   child: const Text('View Accessories'),
/// )
/// ```
///
/// Matching now happens server-side: GET /api/accessories/?bike=<name>
/// &category=<segment> returns accessories explicitly tagged for this
/// bike, or — if none have been tagged yet — falls back to the whole
/// category so the page is never empty. [Bike] still has no `category`
/// field, so [categoryForBike] (the same TEMPORARY mapping used
/// elsewhere) supplies the fallback segment; delete this indirection
/// once the backend adds a real `category` field to Bike.
class BikeAccessoriesScreen extends StatefulWidget {
  final Bike bike;

  const BikeAccessoriesScreen({super.key, required this.bike});

  @override
  State<BikeAccessoriesScreen> createState() => _BikeAccessoriesScreenState();
}

class _BikeAccessoriesScreenState extends State<BikeAccessoriesScreen> {
  late Future<List<Accessory>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Accessory>> _load() {
    return AccessoryApi.fetchAccessories(
      bikeName: widget.bike.name,
      category: categoryForBike(widget.bike),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const BackBar(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACCESSORIES',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: AppColors.brass,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'For Your ${widget.bike.name}',
                    style: const TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.cream,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Accessory>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.brass),
                    );
                  }
                  if (snapshot.hasError) {
                    return AccessoriesErrorState(
                      onRetry: () => setState(() => _future = _load()),
                    );
                  }
                  final accessories = snapshot.data ?? const [];
                  if (accessories.isEmpty) {
                    return _EmptyState(bikeName: widget.bike.name);
                  }
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final columns = width > 1200
                          ? 5
                          : width > 900
                          ? 4
                          : width > 600
                          ? 3
                          : 2;
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 24,
                          crossAxisSpacing: 20,
                          childAspectRatio: 0.78,
                        ),
                        itemCount: accessories.length,
                        itemBuilder: (context, index) =>
                            AccessoryCard(accessory: accessories[index]),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String bikeName;

  const _EmptyState({required this.bikeName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.build_outlined, size: 48, color: AppColors.mutedDark),
            const SizedBox(height: 16),
            Text(
              'No accessories listed yet for $bikeName.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: 14,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
