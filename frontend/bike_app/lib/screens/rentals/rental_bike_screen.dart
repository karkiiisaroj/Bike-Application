import 'package:bike_app/providers/rental_provider.dart';
import 'package:bike_app/screens/rentals/rental_bike.dart';
import 'package:bike_app/screens/rentals/rental_booking.dart';
import 'package:bike_app/screens/rentals/rental_header.dart';
import 'package:bike_app/screens/rentals/rental_history_screen.dart';
import 'package:bike_app/screens/rentals/rental_period_screen.dart';
import 'package:bike_app/screens/rentals/rental_step_bar.dart';
import 'package:flutter/material.dart';
import 'package:bike_app/theme/theme.dart';
import 'package:provider/provider.dart';

class RentalBikeScreen extends StatefulWidget {
  const RentalBikeScreen({super.key});

  @override
  State<RentalBikeScreen> createState() => _RentalBikeScreenState();
}

class _RentalBikeScreenState extends State<RentalBikeScreen> {
  String? _selectedCategory;
  int? _selectedBikeId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RentalProvider>().fetchBikes();
    });
  }

  List<RentalBike> _visible(List<RentalBike> all, String category) =>
      all.where((b) => b.category.name == category).toList();

  RentalBike? _findSelected(List<RentalBike> all) => _selectedBikeId == null
      ? null
      : all.where((b) => b.id == _selectedBikeId).firstOrNull;

  void _selectCategory(String label, List<RentalBike> all) {
    setState(() {
      _selectedCategory = label;
      final bike = _findSelected(all);
      if (bike != null && bike.category.name != label) {
        _selectedBikeId = null;
      }
    });
  }

  void _selectBike(int id) {
    setState(() => _selectedBikeId = _selectedBikeId == id ? null : id);
  }

  void _continue(RentalBike bike) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RentalPeriodScreen(booking: RentalBooking(bike: bike)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RentalProvider>();
    final categories = provider.categoryLabels;
    final activeCategory =
        _selectedCategory ?? (categories.isNotEmpty ? categories.first : null);
    final visible = activeCategory == null
        ? const <RentalBike>[]
        : _visible(provider.bikes, activeCategory);
    final bike = _findSelected(provider.bikes);

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: provider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.brass),
                    )
                  : provider.bikes.isEmpty
                  ? const Center(
                      child: Text(
                        'No rental bikes available yet.',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSans',
                          color: AppColors.muted,
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.only(bottom: 24),
                      children: [
                        const RentalHeader(
                          eyebrow: 'RENTAL SERVICE',
                          title: 'Ride Before\nYou Own ',
                          highlightSuffix: 'It.',
                          titleFontSize: 42,
                          description:
                              'Rent any machine in the range by the day, the week, or the '
                              'tour. Full workshop-serviced condition, riding gear included.',
                        ),
                        const RentalStepBar(currentStep: 1),
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'CHOOSE YOUR MACHINE',
                            style: TextStyle(
                              fontFamily: 'IBMPlexSans',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                              color: AppColors.mutedDark,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _CategoryTabs(
                          categories: categories,
                          active: activeCategory,
                          onSelect: (label) =>
                              _selectCategory(label, provider.bikes),
                        ),
                        const SizedBox(height: 22),
                        _BikeGrid(
                          bikes: visible,
                          selectedId: _selectedBikeId,
                          onSelect: _selectBike,
                        ),
                      ],
                    ),
            ),
            if (bike != null)
              _SelectionBar(bike: bike, onContinue: () => _continue(bike)),
          ],
        ),
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

/// Back-to-home + My Bookings link, replacing the old single back
/// button so the booking history is reachable from step 1.
class _TopRow extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onHistory;

  const _TopRow({required this.onBack, required this.onHistory});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onBack,
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.cream,
              size: 24,
            ),
          ),
          GestureDetector(
            onTap: onHistory,
            child: const Row(
              children: [
                Icon(Icons.history, color: AppColors.brass, size: 18),
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
    );
  }
}

class _RentalsHero extends StatelessWidget {
  const _RentalsHero();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RENTAL SERVICE',
            style: TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: AppColors.brass,
            ),
          ),
          const SizedBox(height: 14),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: 42,
                fontWeight: FontWeight.w800,
                height: 1.05,
                color: AppColors.cream,
              ),
              children: [
                TextSpan(text: 'Ride Before\nYou Own '),
                TextSpan(
                  text: 'It.',
                  style: TextStyle(color: AppColors.brass),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Rent any machine in the range by the day, the week, or the '
            'tour. Full workshop-serviced condition, riding gear included.',
            style: TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 14,
              height: 1.6,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  final List<String> categories;
  final String? active;
  final ValueChanged<String> onSelect;

  const _CategoryTabs({
    required this.categories,
    required this.active,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          for (final category in categories)
            GestureDetector(
              onTap: () => onSelect(category),
              child: Container(
                margin: const EdgeInsets.only(right: 28),
                padding: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: category == active
                          ? AppColors.brass
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  category.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'IBMPlexSans',
                    fontSize: 13,
                    fontWeight: category == active
                        ? FontWeight.w700
                        : FontWeight.w500,
                    letterSpacing: 1,
                    color: category == active
                        ? AppColors.cream
                        : AppColors.mutedDark,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BikeGrid extends StatelessWidget {
  final List<RentalBike> bikes;
  final int? selectedId;
  final ValueChanged<int> onSelect;

  const _BikeGrid({
    required this.bikes,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (bikes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Center(
          child: Text(
            'No machines in this category yet.',
            style: TextStyle(
              fontFamily: 'IBMPlexSans',
              color: AppColors.muted,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          for (final bike in bikes) ...[
            _BikeCard(
              bike: bike,
              selected: bike.id == selectedId,
              onTap: () => onSelect(bike.id),
            ),
            if (bike != bikes.last) const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _BikeCard extends StatelessWidget {
  final RentalBike bike;
  final bool selected;
  final VoidCallback onTap;

  const _BikeCard({
    required this.bike,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.brass : AppColors.line,
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: AppColors.ink,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: _HeroImage(url: bike.heroImage),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      bike.name,
                      style: const TextStyle(
                        fontFamily: 'IBMPlexSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cream,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '₹${bike.pricePerDay}/day',
                    style: const TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brass,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sizes itself to the loaded image's real aspect ratio, so the bike
/// fills the card width edge-to-edge instead of leaving side gaps.
/// (The old fixed-height box forced BoxFit.contain to shrink wide
/// cards down to image height, leaving empty space left/right.)
class _HeroImage extends StatefulWidget {
  final String url;
  const _HeroImage({required this.url});

  @override
  State<_HeroImage> createState() => _HeroImageState();
}

class _HeroImageState extends State<_HeroImage> {
  double? _ratio;
  ImageStream? _stream;
  ImageStreamListener? _listener;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant _HeroImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _ratio = null;
      _resolve();
    }
  }

  void _resolve() {
    final provider = NetworkImage(widget.url);
    final stream = provider.resolve(const ImageConfiguration());
    _stream?.removeListener(_listener!);
    _listener = ImageStreamListener((info, _) {
      if (!mounted) return;
      final ratio = info.image.width / info.image.height;
      if (ratio != _ratio) setState(() => _ratio = ratio);
    });
    stream.addListener(_listener!);
    _stream = stream;
  }

  @override
  void dispose() {
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _ratio ?? 16 / 9, // placeholder until real size loads
      child: Image.network(
        widget.url,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: CircularProgressIndicator(color: AppColors.brass),
          );
        },
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(
            Icons.two_wheeler_outlined,
            color: AppColors.mutedDark,
            size: 40,
          ),
        ),
      ),
    );
  }
}

class _SelectionBar extends StatelessWidget {
  final RentalBike bike;
  final VoidCallback onContinue;

  const _SelectionBar({required this.bike, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.panel,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'SELECTED',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: AppColors.mutedDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${bike.name} — ₹${bike.pricePerDay}/day',
                  style: const TextStyle(
                    fontFamily: 'IBMPlexSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cream,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brass,
              foregroundColor: AppColors.ink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(
                fontFamily: 'IBMPlexSans',
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
