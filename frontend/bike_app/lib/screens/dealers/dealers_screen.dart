import 'dart:math';

import 'package:bike_app/models/dealer_model.dart';
import 'package:bike_app/providers/dealer_provider.dart';
import 'package:bike_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// Kathmandu (Ratna Park) — the fixed reference point "km" distances are
// measured from. Straight-line distance, not road distance.
const double _refLat = 27.7017;
const double _refLng = 85.3206;

double _deg2rad(double deg) => deg * (pi / 180);

double _distanceKm(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371.0;
  final dLat = _deg2rad(lat2 - lat1);
  final dLon = _deg2rad(lon2 - lon1);
  final a =
      sin(dLat / 2) * sin(dLat / 2) +
      cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return r * c;
}

/// Pairs a Dealer with its computed distance from the reference point,
/// so the list only has to run the haversine calc once per dealer per
/// build rather than repeatedly during sort comparisons.
class _RankedDealer {
  final Dealer dealer;
  final double km;
  _RankedDealer(this.dealer, this.km);

  latlong.LatLng get position =>
      latlong.LatLng(dealer.latitude, dealer.longitude);
}

class DealerLocatorScreen extends StatefulWidget {
  const DealerLocatorScreen({super.key});

  @override
  State<DealerLocatorScreen> createState() => _DealerLocatorScreenState();
}

class _DealerLocatorScreenState extends State<DealerLocatorScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  String _query = '';
  int? _activeDealerId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DealerProvider>().fetchDealers();
    });
  }

  List<_RankedDealer> _ranked(List<Dealer> all) {
    final ranked = all
        .map(
          (d) => _RankedDealer(
            d,
            _distanceKm(_refLat, _refLng, d.latitude, d.longitude),
          ),
        )
        .toList();
    ranked.sort((a, b) => a.km.compareTo(b.km));
    return ranked;
  }

  List<_RankedDealer> _filtered(List<_RankedDealer> ranked) {
    if (_query.isEmpty) return ranked;
    final q = _query.toLowerCase();
    return ranked
        .where(
          (r) =>
              r.dealer.name.toLowerCase().contains(q) ||
              r.dealer.city.toLowerCase().contains(q) ||
              r.dealer.address.toLowerCase().contains(q),
        )
        .toList();
  }

  void _selectDealer(Dealer dealer) {
    setState(() => _activeDealerId = dealer.id);
    _mapController.move(latlong.LatLng(dealer.latitude, dealer.longitude), 15);
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open $url')));
    }
  }

  void _openDirections(Dealer d) => _launch(
    'https://www.google.com/maps/search/?api=1&query='
    '${Uri.encodeComponent('${d.name}, ${d.city}, Nepal')}',
  );

  void _call(Dealer d) {
    if (d.phone.isEmpty) return;
    _launch('tel:${d.phone}');
  }

  void _bookRide(Dealer d) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Test ride request noted for ${d.name}. We\'ll be in touch.',
        ),
        backgroundColor: AppColors.panel,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DealerProvider>();

    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(title: const Text('Dealer Locator')),
      body: SafeArea(
        child: provider.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.brass),
              )
            : provider.dealers.isEmpty
            ? const Center(
                child: Text(
                  'No dealers listed yet.',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSans',
                    color: AppColors.muted,
                  ),
                ),
              )
            : _buildContent(provider.dealers),
      ),
    );
  }

  Widget _buildContent(List<Dealer> allDealers) {
    final ranked = _ranked(allDealers);
    final filtered = _filtered(ranked);
    final activeId = _activeDealerId ?? ranked.first.dealer.id;

    return Column(
      children: [
        _Hero(
          searchController: _searchController,
          resultCount: filtered.length,
          totalCount: ranked.length,
          query: _query,
          onChanged: (v) => setState(() => _query = v),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 900;
              final list = _DealerList(
                dealers: filtered,
                activeDealerId: activeId,
                onSelect: (d) => _selectDealer(d),
                onDirections: _openDirections,
                onCall: _call,
                onBookRide: _bookRide,
              );
              final map = _DealerMap(
                mapController: _mapController,
                dealers: ranked,
                activeDealerId: activeId,
                onMarkerTap: (d) => _selectDealer(d),
              );

              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 420,
                      child: Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            right: BorderSide(color: AppColors.line),
                          ),
                        ),
                        child: list,
                      ),
                    ),
                    Expanded(child: map),
                  ],
                );
              }
              return Column(
                children: [
                  Expanded(child: list),
                  SizedBox(height: 320, child: map),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------
// HERO
// -----------------------------------------------------------------------

class _Hero extends StatelessWidget {
  final TextEditingController searchController;
  final int resultCount;
  final int totalCount;
  final String query;
  final ValueChanged<String> onChanged;

  const _Hero({
    required this.searchController,
    required this.resultCount,
    required this.totalCount,
    required this.query,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DEALER LOCATOR',
            style: TextStyle(
              fontFamily: 'IBMPlexSans',
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 3,
              color: AppColors.brass,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Find Your Nearest\nShowroom',
            style: TextStyle(
              fontFamily: 'IBMPlexSans',
              fontWeight: FontWeight.w700,
              fontSize: 30,
              height: 1.08,
              color: AppColors.cream,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: searchController,
            onChanged: onChanged,
            style: const TextStyle(
              fontFamily: 'IBMPlexSans',
              color: AppColors.cream,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'Search by city, area, or dealer name',
              hintStyle: const TextStyle(
                color: AppColors.mutedDark,
                fontSize: 14,
              ),
              filled: true,
              fillColor: AppColors.ink,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2),
                borderSide: const BorderSide(color: AppColors.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2),
                borderSide: const BorderSide(color: AppColors.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2),
                borderSide: const BorderSide(color: AppColors.brass),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            query.isEmpty
                ? 'Showing $totalCount showrooms, nearest first.'
                : '$resultCount showroom${resultCount == 1 ? '' : 's'} matching "$query"',
            style: const TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 12,
              color: AppColors.mutedDark,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------
// DEALER LIST
// -----------------------------------------------------------------------

class _DealerList extends StatelessWidget {
  final List<_RankedDealer> dealers;
  final int activeDealerId;
  final ValueChanged<Dealer> onSelect;
  final ValueChanged<Dealer> onDirections;
  final ValueChanged<Dealer> onCall;
  final ValueChanged<Dealer> onBookRide;

  const _DealerList({
    required this.dealers,
    required this.activeDealerId,
    required this.onSelect,
    required this.onDirections,
    required this.onCall,
    required this.onBookRide,
  });

  @override
  Widget build(BuildContext context) {
    if (dealers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'NO SHOWROOM FOUND',
                style: TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.5,
                  color: AppColors.muted,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Try a different city or dealer name.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: 13,
                  color: AppColors.mutedDark,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: dealers.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: AppColors.line),
      itemBuilder: (context, index) {
        final r = dealers[index];
        final isActive = r.dealer.id == activeDealerId;
        return _DealerCard(
          dealer: r.dealer,
          km: r.km,
          isActive: isActive,
          onTap: () => onSelect(r.dealer),
          onDirections: () => onDirections(r.dealer),
          onCall: () => onCall(r.dealer),
          onBookRide: () => onBookRide(r.dealer),
        );
      },
    );
  }
}

class _DealerCard extends StatelessWidget {
  final Dealer dealer;
  final double km;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onDirections;
  final VoidCallback onCall;
  final VoidCallback onBookRide;

  const _DealerCard({
    required this.dealer,
    required this.km,
    required this.isActive,
    required this.onTap,
    required this.onDirections,
    required this.onCall,
    required this.onBookRide,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(isActive ? 17 : 20, 18, 20, 18),
        decoration: BoxDecoration(
          color: isActive ? AppColors.line.withOpacity(0.25) : null,
          border: Border(
            left: BorderSide(
              color: isActive ? AppColors.brass : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dealer.name,
                        style: const TextStyle(
                          fontFamily: 'IBMPlexSans',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.cream,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${dealer.address}, ${dealer.city}',
                        style: const TextStyle(
                          fontFamily: 'IBMPlexSans',
                          fontSize: 12.5,
                          height: 1.4,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${km.toStringAsFixed(1)} KM',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.brass,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Wrap(
              spacing: 6,
              children: [
                _Tag('SHOWROOM'),
                _Tag('SALES'),
                _Tag('GENUINE PARTS'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _ActionLink(label: 'DIRECTIONS', onTap: onDirections),
                const SizedBox(width: 18),
                if (dealer.phone.isNotEmpty) ...[
                  _ActionLink(label: 'CALL', onTap: onCall),
                  const SizedBox(width: 18),
                ],
                _ActionLink(label: 'BOOK RIDE', onTap: onBookRide),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          color: AppColors.mutedDark,
        ),
      ),
    );
  }
}

class _ActionLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ActionLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: AppColors.muted,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------
// MAP
// -----------------------------------------------------------------------

class _DealerMap extends StatelessWidget {
  final MapController mapController;
  final List<_RankedDealer> dealers;
  final int activeDealerId;
  final ValueChanged<Dealer> onMarkerTap;

  const _DealerMap({
    required this.mapController,
    required this.dealers,
    required this.activeDealerId,
    required this.onMarkerTap,
  });

  static const double _minZoom = 5;
  static const double _maxZoom = 17;

  void _zoomBy(double delta) {
    final camera = mapController.camera;
    final next = (camera.zoom + delta).clamp(_minZoom, _maxZoom);
    mapController.move(camera.center, next);
  }

  @override
  Widget build(BuildContext context) {
    final active = dealers.firstWhere(
      (r) => r.dealer.id == activeDealerId,
      orElse: () => dealers.first,
    );

    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: active.position,
            initialZoom: 15,
            minZoom: _minZoom,
            maxZoom: _maxZoom,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.bikeapp.royalenfield',
            ),
            MarkerLayer(
              markers: [
                for (final r in dealers)
                  Marker(
                    point: r.position,
                    width: 44,
                    height: 44,
                    alignment: Alignment.topCenter,
                    child: GestureDetector(
                      onTap: () => onMarkerTap(r.dealer),
                      child: r.dealer.id == activeDealerId
                          ? const _PulsingPin()
                          : const _Pin(),
                    ),
                  ),
              ],
            ),
          ],
        ),
        Positioned(
          left: 12,
          bottom: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.ink.withOpacity(0.85),
              border: Border.all(color: AppColors.line),
            ),
            child: const Text(
              'DEALER NETWORK',
              style: TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
                color: AppColors.mutedDark,
              ),
            ),
          ),
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: _ZoomControls(
            onZoomIn: () => _zoomBy(1),
            onZoomOut: () => _zoomBy(-1),
          ),
        ),
      ],
    );
  }
}

class _ZoomControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const _ZoomControls({required this.onZoomIn, required this.onZoomOut});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.ink.withOpacity(0.85),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ZoomButton(icon: Icons.add, onTap: onZoomIn),
          Container(height: 1, color: AppColors.line),
          _ZoomButton(icon: Icons.remove, onTap: onZoomOut),
        ],
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ZoomButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(icon, size: 18, color: AppColors.cream),
      ),
    );
  }
}

class _Pin extends StatelessWidget {
  const _Pin();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.rotate(
        angle: -0.785398,
        child: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.mutedDark,
            border: Border.all(color: AppColors.ink, width: 1.5),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(7),
              topRight: Radius.circular(7),
              bottomRight: Radius.circular(7),
            ),
          ),
        ),
      ),
    );
  }
}

class _PulsingPin extends StatefulWidget {
  const _PulsingPin();

  @override
  State<_PulsingPin> createState() => _PulsingPinState();
}

class _PulsingPinState extends State<_PulsingPin>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = _controller.value;
              return Opacity(
                opacity: (1 - t).clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 0.4 + t * 2.2,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.brass,
                    ),
                  ),
                ),
              );
            },
          ),
          Transform.rotate(
            angle: -0.785398,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.brass,
                border: Border.all(color: AppColors.ink, width: 1.5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(9),
                  topRight: Radius.circular(9),
                  bottomRight: Radius.circular(9),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brass.withOpacity(0.55),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
