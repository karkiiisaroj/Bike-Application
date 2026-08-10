import 'package:bike_app/models/bike_model.dart';
import 'package:bike_app/providers/bike_provider.dart';
import 'package:bike_app/screens/bikes/bike_detail_screen.dart';
import 'package:bike_app/theme/theme.dart';
import 'package:bike_app/widgets/atelier_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// TEMPORARY client-side category mapping.
///
/// Your `Bike` model (from the Django API) has no `category` field yet,
/// so we fake it here until the backend adds one. Key on bike `name`
/// (switch to `id` if names aren't guaranteed unique/stable).
///
/// Anything not listed falls back to [_defaultCategory] rather than
/// disappearing from the list entirely.
///
/// TODO: delete this map once `Bike.category` exists, and change
/// `categoryForBike` below to just return `bike.category`.
String categoryForBike(Bike bike) {
  switch (bike.category.toLowerCase()) {
    case 'heritage':
      return 'Heritage';
    case 'scrambler':
      return 'Scrambler';
    case 'pure_sport':
      return 'Pure Sport';
    case 'roadster':
      return 'Roadster';
    case 'adventure':
      return 'Adventure';
    case 'cruiser':
      return 'Cruiser';
    default:
      return 'Heritage';
  }
}

const List<String> bikeCategories = [
  'Heritage',
  'Scrambler',
  'Pure Sport',
  'Roadster',
  'Adventure',
  'Cruiser',
];

class BikesScreen extends StatefulWidget {
  const BikesScreen({super.key});

  @override
  State<BikesScreen> createState() => _BikesScreenState();
}

class _BikesScreenState extends State<BikesScreen> {
  String _activeCategory = bikeCategories.first;
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fire the fetch after the first frame so BikeProvider is fully
    // wired into the widget tree via Provider before we call it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BikeProvider>().fetchBikes();
    });
  }

  List<Bike> _filterBikes(List<Bike> all) {
    return all.where((b) => categoryForBike(b) == _activeCategory).toList();
  }

  void _selectCategory(String category) {
    setState(() {
      _activeCategory = category;
      _activeIndex = 0;
    });
  }

  void _selectIndex(int index) {
    setState(() => _activeIndex = index);
  }

  // Uses context.read (safe outside build) instead of context.watch —
  // this runs from a button's onPressed, not during the widget's
  // build phase, so watch() would throw and silently block the
  // setState() below it.
  void _step(int delta) {
    final all = context.read<BikeProvider>().bikes;
    final len = _filterBikes(all).length;
    if (len == 0) return;
    setState(() => _activeIndex = (_activeIndex + delta + len) % len);
  }

  @override
  Widget build(BuildContext context) {
    final allBikes = context.watch<BikeProvider>().bikes;
    final filtered = _filterBikes(allBikes);
    final safeIndex = filtered.isEmpty
        ? 0
        : _activeIndex.clamp(0, filtered.length - 1);

    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(title: const Text('Bikes')),
      body: SafeArea(
        child: Column(
          children: [
            _CategoryTabs(
              categories: bikeCategories,
              active: _activeCategory,
              onSelect: _selectCategory,
            ),
            if (filtered.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'No bikes in this category yet.',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSans',
                      color: AppColors.muted,
                    ),
                  ),
                ),
              )
            else ...[
              _ModelCarousel(
                bikes: filtered,
                activeIndex: safeIndex,
                onPrev: () => _step(-1),
                onNext: () => _step(1),
                onSelect: _selectIndex,
              ),
              Expanded(child: _BikeVisual(bike: filtered[safeIndex])),
            ],
          ],
        ),
      ),
    );
  }
}

/// Category tab row — the active tab is picked out in cream with a soft
/// brass "spotlight" trapezoid underneath it.
///
/// Wrapped in a horizontally-scrolling SingleChildScrollView so that on
/// narrower screens/windows, where the full category row doesn't fit,
/// the user can swipe left/right to reach every category instead of the
/// row silently overflowing.
class _CategoryTabs extends StatelessWidget {
  final List<String> categories;
  final String active;
  final ValueChanged<String> onSelect;

  const _CategoryTabs({
    required this.categories,
    required this.active,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final category in categories)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () => onSelect(category),
                  child: _CategoryTab(
                    label: category,
                    isActive: category == active,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  final String label;
  final bool isActive;

  const _CategoryTab({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: 'IBMPlexSans',
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: 1.5,
            color: isActive ? AppColors.cream : AppColors.mutedDark,
          ),
        ),
        const SizedBox(height: 12),
        // The brass "spotlight" indicator under the active tab.
        Container(
          width: isActive ? 90 : 0,
          height: 4,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.brass, Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }
}

/// Prev / current / next model name row with arrow controls.
///
/// With exactly 2 bikes in a category, prev/current/next would show the
/// same "other" bike on both sides of current — so 2-item categories
/// show current + the one other (no duplicate), and 3+ items keep the
/// original prev/current/next layout. 1 item shows just itself.
class _ModelCarousel extends StatelessWidget {
  final List<Bike> bikes;
  final int activeIndex;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<int> onSelect;

  const _ModelCarousel({
    required this.bikes,
    required this.activeIndex,
    required this.onPrev,
    required this.onNext,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final len = bikes.length;

    Widget arrows({required Widget child}) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: len > 1 ? onPrev : null,
            icon: const Icon(
              Icons.chevron_left,
              color: AppColors.muted,
              size: 30,
            ),
          ),
          Expanded(child: child),
          IconButton(
            onPressed: len > 1 ? onNext : null,
            icon: const Icon(
              Icons.chevron_right,
              color: AppColors.muted,
              size: 30,
            ),
          ),
        ],
      );
    }

    if (len <= 1) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 12),
        child: arrows(
          child: _ModelName(
            label: bikes[activeIndex].name,
            isCurrent: true,
            onTap: () {},
          ),
        ),
      );
    }

    if (len == 2) {
      // Only one "other" bike exists — show it once (as the upcoming
      // model) instead of duplicating it on both sides of current.
      final otherIndex = (activeIndex + 1) % len;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 12),
        child: arrows(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: _ModelName(
                  label: bikes[activeIndex].name,
                  isCurrent: true,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 28),
              Flexible(
                child: _ModelName(
                  label: bikes[otherIndex].name,
                  isCurrent: false,
                  onTap: () => onSelect(otherIndex),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 3 or more bikes — original prev / current / next layout.
    final prevIndex = (activeIndex - 1 + len) % len;
    final nextIndex = (activeIndex + 1) % len;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 12),
      child: arrows(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: _ModelName(
                label: bikes[prevIndex].name,
                isCurrent: false,
                onTap: () => onSelect(prevIndex),
              ),
            ),
            const SizedBox(width: 28),
            Flexible(
              child: _ModelName(
                label: bikes[activeIndex].name,
                isCurrent: true,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 28),
            Flexible(
              child: _ModelName(
                label: bikes[nextIndex].name,
                isCurrent: false,
                onTap: () => onSelect(nextIndex),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModelName extends StatelessWidget {
  final String label;
  final bool isCurrent;
  final VoidCallback onTap;

  const _ModelName({
    required this.label,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'IBMPlexSans',
            fontSize: isCurrent ? 28 : 16,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            color: isCurrent ? AppColors.cream : AppColors.mutedDark,
          ),
        ),
      ),
    );
  }
}

/// Large centred bike image with a soft brass glow behind it, plus the
/// bike name as a caption underneath and an Explore button that opens
/// BikeDetailScreen for the currently shown bike.
///
/// Image loads from the network (`bike.heroImage`) with a loading
/// spinner while it fetches and a fallback icon if the URL fails.
/// Large centred bike image with a soft brass glow behind it, plus the
/// bike name as a caption underneath and an Explore button that opens
/// BikeDetailScreen for the currently shown bike.
///
/// Image loads from the network (`bike.heroImage`) with a loading
/// spinner while it fetches and a fallback icon if the URL fails.
class _BikeVisual extends StatelessWidget {
  final Bike bike;

  const _BikeVisual({required this.bike});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.8,
          colors: [Color(0x22C08A3E), Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
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
          ),
          const SizedBox(height: 20),
          Text(
            bike.name,
            style: const TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.cream,
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => BikeDetailScreen(bike: bike)),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.brass),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            child: const Text(
              'EXPLORE',
              style: TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: AppColors.brass,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
