import 'package:bike_app/models/accessory_model.dart';
import 'package:bike_app/screens/accessories/accessory_detail_screen.dart';
import 'package:bike_app/theme/theme.dart';
import 'package:flutter/material.dart';

/// Simple back-button row, top-left, shared by every accessories screen.
class BackBar extends StatelessWidget {
  const BackBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.cream),
          ),
        ],
      ),
    );
  }
}

class CategoryPillBar extends StatelessWidget {
  final String? active; // null == "All"
  final ValueChanged<String?> onSelect;

  const CategoryPillBar({
    super.key,
    required this.active,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Pill(
            label: 'All',
            selected: active == null,
            onTap: () => onSelect(null),
          ),
          for (final entry in accessoryCategoryLabels.entries)
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: _Pill(
                label: entry.value,
                selected: active == entry.key,
                onTap: () => onSelect(entry.key),
              ),
            ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? AppColors.brass : AppColors.line,
            width: 1.4,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: 'IBMPlexSans',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: selected ? AppColors.brass : AppColors.muted,
          ),
        ),
      ),
    );
  }
}

/// One accessory tile — tap through to its detail/purchase screen.
class AccessoryCard extends StatelessWidget {
  final Accessory accessory;

  const AccessoryCard({super.key, required this.accessory});

  @override
  Widget build(BuildContext context) {
    final categoryLabel =
        accessoryCategoryLabels[accessory.category] ?? accessory.category;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AccessoryDetailScreen(slug: accessory.slug),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.panel,
                    border: Border.all(color: AppColors.line),
                  ),
                  child: AccessoryImage(url: accessory.imageUrl),
                ),
                if (!accessory.inStock)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      color: AppColors.ink.withOpacity(0.85),
                      child: const Text(
                        'SOLD OUT',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            accessory.name,
            style: const TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.cream,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${formatRupees(accessory.price)} · $categoryLabel',
            style: const TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 13,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared image block — network photo if the accessory has one,
/// otherwise a centered camera-outline placeholder (same fallback the
/// old asset-based version used for missing images).
class AccessoryImage extends StatelessWidget {
  final String? url;

  const AccessoryImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Center(
        child: Icon(
          Icons.camera_alt_outlined,
          size: 56,
          color: AppColors.mutedDark,
        ),
      );
    }
    return Image.network(
      url!,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: CircularProgressIndicator(
            color: AppColors.brass,
            strokeWidth: 2,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => Center(
        child: Icon(
          Icons.camera_alt_outlined,
          size: 56,
          color: AppColors.mutedDark,
        ),
      ),
    );
  }
}

class AccessoriesErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const AccessoriesErrorState({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off, size: 40, color: AppColors.mutedDark),
          const SizedBox(height: 12),
          const Text(
            'Could not load accessories.',
            style: TextStyle(fontFamily: 'IBMPlexSans', color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.brass),
            ),
            onPressed: onRetry,
            child: const Text(
              'RETRY',
              style: TextStyle(
                fontFamily: 'IBMPlexSans',
                color: AppColors.brass,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
