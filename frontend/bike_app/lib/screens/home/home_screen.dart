import 'package:bike_app/screens/auth/auth_screen.dart';
import 'package:bike_app/state/auth_controller.dart';
import 'package:bike_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Data for a single Home tile. Swap [route] for whatever navigation
/// approach you're using (named routes shown here for simplicity).
class NavTileData {
  final String number;
  final String title;
  final String description;
  final String route;
  final String imageUrl;

  const NavTileData({
    required this.number,
    required this.title,
    required this.description,
    required this.route,
    required this.imageUrl,
  });
}

const List<NavTileData> homeTiles = [
  NavTileData(
    number: '01',
    title: 'Bikes',
    description:
        'Walk the full lineup. Switch models and colourways in real time.',
    route: '/bikes',
    imageUrl: 'assets/home_page/Bike.jpg',
  ),
  NavTileData(
    number: '02',
    title: 'Accessories',
    description:
        'Crash guards, touring seats, saddlebags — built for your machine.',
    route: '/accessories',
    imageUrl: 'assets/home_page/accessories.png',
  ),
  NavTileData(
    number: '03',
    title: 'Rentals',
    description: 'Ride before you own it. Book by the day or the tour.',
    route: '/rentals',
    imageUrl: 'assets/home_page/Rentals.png',
  ),
  NavTileData(
    number: '04',
    title: 'Compare',
    description: 'Two machines, side by side, spec for spec.',
    route: '/compare',
    imageUrl: 'assets/home_page/Compare.jpg',
  ),
  NavTileData(
    number: '05',
    title: 'Dealer Locator',
    description: 'Find your nearest showroom and book a visit.',
    route: '/dealers',
    imageUrl: 'assets/home_page/dealership locator.jpg',
  ),
  NavTileData(
    number: '06',
    title: 'Journal',
    description: 'Ride reports, heritage pieces, and gear guides.',
    route: '/journal',
    imageUrl: 'assets/home_page/Journal.jpg',
  ),
  NavTileData(
    number: '07',
    title: 'Our Story',
    description: 'Since 1901 — the thump that outlived a century.',
    route: '/story',
    imageUrl: 'assets/home_page/our story.png',
  ),
  NavTileData(
    number: '08',
    title: 'My Garage',
    description: 'Save the bikes and colourways you keep coming back to.',
    route: '/garage',
    imageUrl: 'assets/home_page/my garage.jpg',
  ),
];

// ---------------------------------------------------------------------
// RESPONSIVE SPEC — one place that decides how many columns, how big
// the type is, and how much padding a tile gets at a given width. Every
// screen size (small phone → ultra-wide desktop) reads from this table
// instead of scattering breakpoint checks through the widget tree.
// ---------------------------------------------------------------------
class _TileSpec {
  final int crossAxisCount;
  final double childAspectRatio;
  final double horizontalPadding;
  final double verticalPadding;
  final double numberFontSize;
  final double titleFontSize;
  final double descriptionFontSize;

  const _TileSpec({
    required this.crossAxisCount,
    required this.childAspectRatio,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.numberFontSize,
    required this.titleFontSize,
    required this.descriptionFontSize,
  });
}

_TileSpec _specFor(double width) {
  if (width < 400) {
    return const _TileSpec(
      crossAxisCount: 1,
      childAspectRatio: 1.6,
      horizontalPadding: 22,
      verticalPadding: 26,
      numberFontSize: 11,
      titleFontSize: 21,
      descriptionFontSize: 13,
    );
  }
  if (width < 600) {
    return const _TileSpec(
      crossAxisCount: 2,
      childAspectRatio: 0.95,
      horizontalPadding: 20,
      verticalPadding: 28,
      numberFontSize: 10,
      titleFontSize: 20,
      descriptionFontSize: 12,
    );
  }
  if (width < 900) {
    return const _TileSpec(
      crossAxisCount: 3,
      childAspectRatio: 1.0,
      horizontalPadding: 24,
      verticalPadding: 30,
      numberFontSize: 10.5,
      titleFontSize: 22,
      descriptionFontSize: 12.5,
    );
  }
  if (width < 1300) {
    return const _TileSpec(
      crossAxisCount: 4,
      childAspectRatio: 1.15,
      horizontalPadding: 28,
      verticalPadding: 34,
      numberFontSize: 11,
      titleFontSize: 24,
      descriptionFontSize: 13,
    );
  }
  return const _TileSpec(
    crossAxisCount: 5,
    childAspectRatio: 1.1,
    horizontalPadding: 30,
    verticalPadding: 36,
    numberFontSize: 11,
    titleFontSize: 24,
    descriptionFontSize: 13,
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final spec = _specFor(width);

                  const maxContentWidth = 1800.0;
                  final grid = GridView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: homeTiles.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: spec.crossAxisCount,
                      childAspectRatio: spec.childAspectRatio,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1,
                    ),
                    itemBuilder: (context, index) {
                      final tile = homeTiles[index];
                      return _NavTile(
                        data: tile,
                        spec: spec,
                        onTap: () =>
                            Navigator.of(context).pushNamed(tile.route),
                      );
                    },
                  );

                  if (width <= maxContentWidth) return grid;

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: maxContentWidth,
                      ),
                      child: grid,
                    ),
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

/// Top bar: wordmark on the left, Account / Menu on the right. Tapping
/// the account icon logs you out (with confirmation) if you're
/// signed in, or falls back to AuthScreen if somehow you're not.
class _TopBar extends StatelessWidget {
  const _TopBar();

  void _openAccount(BuildContext context) {
    final auth = context.read<AuthController>();
    final user = auth.user;

    if (auth.status != AuthStatus.authenticated || user == null) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const AuthScreen()));
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.panel,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.firstName.isNotEmpty ? user.firstName : user.username,
              style: const TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.cream,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: const TextStyle(
                fontFamily: 'IBMPlexSans',
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  Navigator.pop(sheetContext);
                  await context.read<AuthController>().logout();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const AuthScreen()),
                    );
                  }
                },
                child: const Text('LOG OUT'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isCompact = width < 400;
        final wordmarkSize = isCompact ? 15.0 : 18.0;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 16 : 24,
            vertical: isCompact ? 14 : 18,
          ),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.line)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: RichText(
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Royal Enfield  ',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSans',
                          fontWeight: FontWeight.w700,
                          fontSize: wordmarkSize,
                          color: AppColors.cream,
                        ),
                      ),
                      if (!isCompact)
                        const TextSpan(
                          text: 'ATELIER',
                          style: TextStyle(
                            fontFamily: 'IBMPlexSans',
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                            letterSpacing: 2,
                            color: AppColors.mutedDark,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _openAccount(context),
                    icon: Icon(
                      Icons.person_outline,
                      color: AppColors.cream,
                      size: isCompact ? 18 : 20,
                    ),
                    tooltip: 'Account',
                  ),
                  IconButton(
                    onPressed: () => _openMenu(context),
                    icon: Icon(
                      Icons.menu,
                      color: AppColors.cream,
                      size: isCompact ? 20 : 22,
                    ),
                    tooltip: 'Menu',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _openMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.ink,
      isScrollControlled: true,
      builder: (context) => const _MenuOverlay(),
    );
  }
}

/// A single Home tile — background image, dark gradient scrim, then
/// number / title / description layered on top.
class _NavTile extends StatefulWidget {
  final NavTileData data;
  final _TileSpec spec;
  final VoidCallback onTap;

  const _NavTile({required this.data, required this.spec, required this.onTap});

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final spec = widget.spec;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              widget.data.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                debugPrint(
                  '⚠️ Home tile image missing for "${widget.data.title}" '
                  '— expected at "${widget.data.imageUrl}".',
                );
                return Container(color: AppColors.panel);
              },
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(_hovering ? 0.15 : 0.05),
                    Colors.black.withOpacity(_hovering ? 0.55 : 0.45),
                    Colors.black.withOpacity(_hovering ? 0.92 : 0.85),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spec.horizontalPadding,
                vertical: spec.verticalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.data.number,
                    style: TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: spec.numberFontSize,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2,
                      color: AppColors.brass,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.data.title,
                    style: TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: spec.titleFontSize,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cream,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.data.description,
                    style: TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: spec.descriptionFontSize,
                      height: 1.5,
                      color: AppColors.muted,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
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

/// Full-screen menu (bottom sheet here for simplicity).
class _MenuOverlay extends StatelessWidget {
  const _MenuOverlay();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final tile in homeTiles)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Text(
                    tile.number,
                    style: const TextStyle(
                      fontFamily: 'IBMPlexSans',
                      color: AppColors.brass,
                      fontSize: 13,
                    ),
                  ),
                  title: Text(
                    tile.title,
                    style: const TextStyle(
                      fontFamily: 'IBMPlexSans',
                      color: AppColors.cream,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed(tile.route);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
