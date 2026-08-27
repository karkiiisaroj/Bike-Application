import 'package:bike_app/models/bike_color_variant_model.dart';
import 'package:bike_app/models/bike_model.dart';
import 'package:bike_app/services/api_services.dart';
import 'package:bike_app/theme/theme.dart';
import 'package:flutter/material.dart';

/// Interactive drag-to-spin 360° viewer with a colour swatch row. Each
/// colour has its own full 36-frame set uploaded through Django admin.
/// Falls back to the bike's flat hero image if no colour variant has
/// been configured yet, so the screen is never empty.
class Bike360ViewerScreen extends StatefulWidget {
  const Bike360ViewerScreen({super.key, required this.bike});

  final Bike bike;

  @override
  State<Bike360ViewerScreen> createState() => _Bike360ViewerScreenState();
}

class _Bike360ViewerScreenState extends State<Bike360ViewerScreen> {
  final ApiService _api = ApiService();

  List<BikeColorVariant> _variants = [];
  bool _loading = true;
  int _activeVariantIndex = 0;
  int _frameIndex = 0;
  double _dragAccumulator = 0;

  // Pixels of horizontal drag needed to advance one frame — smaller
  // number = more sensitive spin.
  static const double _pxPerFrame = 8;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final variants = await _api.getBikeColorVariants(widget.bike.id);
      setState(() {
        _variants = variants;
        _loading = false;
      });
      if (variants.isNotEmpty) {
        _precache(variants.first);
      }
    } catch (e) {
      debugPrint('⚠️ 360 viewer load failed: $e');
      setState(() => _loading = false);
    }
  }

  void _precache(BikeColorVariant variant) {
    for (final frame in variant.frames) {
      precacheImage(NetworkImage(frame.image), context);
    }
  }

  void _selectVariant(int index) {
    setState(() {
      _activeVariantIndex = index;
      _frameIndex = 0;
    });
    _precache(_variants[index]);
  }

  void _onDragUpdate(DragUpdateDetails details, int frameCount) {
    if (frameCount == 0) return;
    _dragAccumulator += details.delta.dx;
    if (_dragAccumulator.abs() >= _pxPerFrame) {
      final steps = (_dragAccumulator / _pxPerFrame).truncate();
      setState(() {
        _frameIndex = (_frameIndex - steps) % frameCount;
        if (_frameIndex < 0) _frameIndex += frameCount;
      });
      _dragAccumulator -= steps * _pxPerFrame;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasVariants = _variants.isNotEmpty;
    final activeVariant = hasVariants ? _variants[_activeVariantIndex] : null;
    final frames = activeVariant?.frames ?? [];
    final hasFrames = frames.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        title: Text(widget.bike.name),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.brass),
              )
            : Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onHorizontalDragUpdate: hasFrames
                          ? (d) => _onDragUpdate(d, frames.length)
                          : null,
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 0.9,
                            colors: [Color(0x22C08A3E), Colors.transparent],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: hasFrames
                                    ? Image.network(
                                        frames[_frameIndex].image,
                                        fit: BoxFit.contain,
                                        gaplessPlayback: true,
                                        errorBuilder: (_, __, ___) =>
                                            Image.network(
                                              widget.bike.heroImage,
                                              fit: BoxFit.contain,
                                            ),
                                      )
                                    : Image.network(
                                        widget.bike.heroImage,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(
                                              Icons.two_wheeler,
                                              size: 160,
                                              color: AppColors.mutedDark,
                                            ),
                                      ),
                              ),
                            ),
                            if (hasFrames)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.swipe,
                                      size: 16,
                                      color: AppColors.mutedDark,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Drag to spin',
                                      style: const TextStyle(
                                        fontFamily: 'IBMPlexSans',
                                        fontSize: 12,
                                        color: AppColors.mutedDark,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'No 360° set uploaded for this colour yet.',
                                  style: TextStyle(
                                    fontFamily: 'IBMPlexSans',
                                    fontSize: 12,
                                    color: AppColors.mutedDark,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (hasVariants)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 20,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: AppColors.line)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activeVariant!.name.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'IBMPlexSans',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              color: AppColors.brass,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              for (int i = 0; i < _variants.length; i++)
                                Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: GestureDetector(
                                    onTap: () => _selectVariant(i),
                                    child: Container(
                                      width: 90,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: i == _activeVariantIndex
                                              ? AppColors.brass
                                              : AppColors.line,
                                          width: i == _activeVariantIndex
                                              ? 2
                                              : 1,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: Image.network(
                                          _variants[i].tankImage,
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return const Center(
                                                  child: Icon(
                                                    Icons
                                                        .image_not_supported_outlined,
                                                    color: AppColors.line,
                                                  ),
                                                );
                                              },
                                          loadingBuilder:
                                              (
                                                context,
                                                child,
                                                loadingProgress,
                                              ) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }

                                                return const Center(
                                                  child: SizedBox(
                                                    width: 18,
                                                    height: 18,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 1.5,
                                                        ),
                                                  ),
                                                );
                                              },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
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
