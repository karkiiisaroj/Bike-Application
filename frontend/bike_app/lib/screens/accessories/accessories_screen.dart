import 'package:bike_app/models/accessory_model.dart';
import 'package:bike_app/theme/theme.dart';
import 'package:bike_app/widgets/accessory_widgets.dart';
import 'package:flutter/material.dart';
import 'package:bike_app/services/accessory_service.dart';

/// Master accessories catalog — "ALL / HERITAGE / ADVENTURE / ..." pill
/// filter up top, responsive grid of accessory cards below, all sourced
/// from GET /api/accessories/. For a single bike's compatible
/// accessories only, use [BikeAccessoriesScreen] instead.
class AccessoriesScreen extends StatefulWidget {
  const AccessoriesScreen({super.key});

  @override
  State<AccessoriesScreen> createState() => _AccessoriesScreenState();
}

class _AccessoriesScreenState extends State<AccessoriesScreen> {
  String? _activeCategory; // null == "All"
  late Future<List<Accessory>> _future;

  @override
  void initState() {
    super.initState();
    _future = AccessoryApi.fetchAccessories();
  }

  void _selectCategory(String? category) {
    setState(() {
      _activeCategory = category;
      _future = AccessoryApi.fetchAccessories(category: category);
    });
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
                  const Text(
                    'Built For Your Machine',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColors.cream,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CategoryPillBar(
                    active: _activeCategory,
                    onSelect: _selectCategory,
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
                      onRetry: () => _selectCategory(_activeCategory),
                    );
                  }
                  final accessories = snapshot.data ?? const [];
                  if (accessories.isEmpty) {
                    return const Center(
                      child: Text(
                        'No accessories in this category yet.',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSans',
                          color: AppColors.muted,
                        ),
                      ),
                    );
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
