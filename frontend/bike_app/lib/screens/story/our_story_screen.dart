import 'package:bike_app/models/story_entry.dart';
import 'package:bike_app/services/story_service.dart';
import 'package:bike_app/theme/theme.dart';
import 'package:flutter/material.dart';

class OurStoryScreen extends StatefulWidget {
  const OurStoryScreen({super.key});

  @override
  State<OurStoryScreen> createState() => _OurStoryScreenState();
}

class _OurStoryScreenState extends State<OurStoryScreen> {
  List<StoryEntry> _entries = [];
  bool _loading = true;

  int _minYear = 0;
  int _maxYear = 0;
  Map<String, RangeValues> _eraRanges = {};
  RangeValues _selectedRange = const RangeValues(0, 0);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await StoryService.fetchStoryEntries();
    final years = entries.map((e) => int.parse(e.year));
    final minYear = years.reduce((a, b) => a < b ? a : b);
    final maxYear = years.reduce((a, b) => a > b ? a : b);

    final eraRanges = {
      for (final era in storyEras)
        era.key: () {
          final eraYears = entries
              .where((e) => e.eraKey == era.key)
              .map((e) => int.parse(e.year));
          if (eraYears.isEmpty) {
            return RangeValues(minYear.toDouble(), minYear.toDouble());
          }
          return RangeValues(
            eraYears.reduce((a, b) => a < b ? a : b).toDouble(),
            eraYears.reduce((a, b) => a > b ? a : b).toDouble(),
          );
        }(),
    };

    setState(() {
      _entries = entries;
      _minYear = minYear;
      _maxYear = maxYear;
      _eraRanges = eraRanges;
      _selectedRange = RangeValues(minYear.toDouble(), maxYear.toDouble());
      _loading = false;
    });
  }

  /// If the current selection exactly matches one of the preset eras,
  /// that era's key — used to highlight the active chip. Null when the
  /// user has dragged to a custom range that doesn't match any preset.
  String? get _activeEraKey {
    for (final entry in _eraRanges.entries) {
      if (entry.value.start == _selectedRange.start &&
          entry.value.end == _selectedRange.end) {
        return entry.key;
      }
    }
    return null;
  }

  void _selectEra(String eraKey) {
    setState(() => _selectedRange = _eraRanges[eraKey]!);
  }

  /// Entries whose year falls inside the currently selected range,
  /// kept in the same chronological order as [_entries].
  List<StoryEntry> get _filteredEntries {
    final start = _selectedRange.start.round();
    final end = _selectedRange.end.round();
    return _entries.where((e) {
      final y = int.parse(e.year);
      return y >= start && y <= end;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(title: const Text('Our Story')),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.brass),
              )
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final entries = _filteredEntries;

    return Column(
      children: [
        _EraPresetChips(
          eras: storyEras,
          activeEraKey: _activeEraKey,
          onSelect: _selectEra,
        ),
        _YearRangeTimeline(
          minYear: _minYear,
          maxYear: _maxYear,
          selected: _selectedRange,
          onChanged: (range) => setState(() => _selectedRange = range),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${entries.length} milestone${entries.length == 1 ? '' : 's'}',
              style: const TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: 12,
                color: AppColors.mutedDark,
              ),
            ),
          ),
        ),
        Expanded(
          child: entries.isEmpty
              ? const Center(
                  child: Text(
                    'No milestones in this range.',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSans',
                      color: AppColors.muted,
                      fontSize: 14,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 40, top: 8),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final isFirstOfEra =
                        index == 0 || entries[index - 1].eraKey != entry.eraKey;

                    return _StoryEntryCard(
                      entry: entry,
                      isMilestone: isFirstOfEra,
                      isFirstOverall: index == 0,
                      isLastOverall: index == entries.length - 1,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// A horizontal row of preset era chips. Tapping one snaps the range
/// slider below straight to that era's actual first/last year.
class _EraPresetChips extends StatelessWidget {
  final List<StoryEra> eras;
  final String? activeEraKey;
  final ValueChanged<String> onSelect;

  const _EraPresetChips({
    required this.eras,
    required this.activeEraKey,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final era in eras)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onSelect(era.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: era.key == activeEraKey
                          ? AppColors.brass
                          : AppColors.panel,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: era.key == activeEraKey
                            ? AppColors.brass
                            : AppColors.line,
                      ),
                    ),
                    child: Text(
                      era.label,
                      style: TextStyle(
                        fontFamily: 'IBMPlexSans',
                        fontSize: 13,
                        fontWeight: era.key == activeEraKey
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: era.key == activeEraKey
                            ? AppColors.ink
                            : AppColors.muted,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A "From -- to --" year range timeline. Dragging either handle filters
/// the list below directly.
class _YearRangeTimeline extends StatelessWidget {
  final int minYear;
  final int maxYear;
  final RangeValues selected;
  final ValueChanged<RangeValues> onChanged;

  const _YearRangeTimeline({
    required this.minYear,
    required this.maxYear,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _YearLabel(label: 'From', year: selected.start.round()),
              _YearLabel(label: 'To', year: selected.end.round()),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.brass,
              inactiveTrackColor: AppColors.line,
              thumbColor: AppColors.brass,
              overlayColor: AppColors.brass.withOpacity(0.15),
              rangeThumbShape: const RoundRangeSliderThumbShape(
                enabledThumbRadius: 8,
              ),
              trackHeight: 3,
              valueIndicatorColor: AppColors.brass,
              valueIndicatorTextStyle: const TextStyle(
                fontFamily: 'IBMPlexSans',
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            child: RangeSlider(
              min: minYear.toDouble(),
              max: maxYear.toDouble(),
              divisions: (maxYear - minYear) > 0 ? maxYear - minYear : 1,
              values: selected,
              labels: RangeLabels(
                selected.start.round().toString(),
                selected.end.round().toString(),
              ),
              onChanged: onChanged,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _YearLabel extends StatelessWidget {
  final String label;
  final int year;

  const _YearLabel({required this.label, required this.year});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'IBMPlexSans',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: AppColors.mutedDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          year.toString(),
          style: const TextStyle(
            fontFamily: 'IBMPlexSans',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.cream,
          ),
        ),
      ],
    );
  }
}

/// One milestone: a connecting timeline rail on the left, and the ghost
/// year + photo + description on the right.
class _StoryEntryCard extends StatelessWidget {
  final StoryEntry entry;
  final bool isMilestone;
  final bool isFirstOverall;
  final bool isLastOverall;

  const _StoryEntryCard({
    required this.entry,
    required this.isMilestone,
    required this.isFirstOverall,
    required this.isLastOverall,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TimelineRail(
            isMilestone: isMilestone,
            showTopLine: !isFirstOverall,
            showBottomLine: !isLastOverall,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 34, 24, 40),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -18,
                    left: -2,
                    child: Text(
                      entry.year,
                      style: TextStyle(
                        fontFamily: 'IBMPlexSans',
                        fontSize: isWide ? 140 : 84,
                        fontWeight: FontWeight.w700,
                        height: 1,
                        color: AppColors.panel,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 26),
                    child: isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _StoryImage(
                                id: entry.id,
                                asset: entry.imageAsset,
                              ),
                              const SizedBox(width: 44),
                              Expanded(child: _StoryText(entry: entry)),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _StoryImage(
                                id: entry.id,
                                asset: entry.imageAsset,
                              ),
                              const SizedBox(height: 22),
                              _StoryText(entry: entry),
                            ],
                          ),
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

class _TimelineRail extends StatelessWidget {
  final bool isMilestone;
  final bool showTopLine;
  final bool showBottomLine;

  const _TimelineRail({
    required this.isMilestone,
    required this.showTopLine,
    required this.showBottomLine,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Column(
        children: [
          SizedBox(
            height: 34,
            child: showTopLine
                ? Center(child: Container(width: 2, color: AppColors.line))
                : null,
          ),
          Container(
            width: isMilestone ? 14 : 9,
            height: isMilestone ? 14 : 9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isMilestone ? AppColors.brass : AppColors.mutedDark,
              border: isMilestone
                  ? Border.all(color: AppColors.ink, width: 2)
                  : null,
            ),
          ),
          Expanded(
            child: showBottomLine
                ? Container(width: 2, color: AppColors.line)
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}

class _StoryImage extends StatelessWidget {
  final String id;
  final String asset;

  const _StoryImage({required this.id, required this.asset});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 190,
      decoration: BoxDecoration(border: Border.all(color: AppColors.line)),
      child: Image.asset(
        asset,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint(
            '⚠️ Story image missing for id "$id" — expected at "$asset".',
          );
          return const Icon(
            Icons.photo_camera_back_outlined,
            color: AppColors.mutedDark,
            size: 40,
          );
        },
      ),
    );
  }
}

class _StoryText extends StatelessWidget {
  final StoryEntry entry;

  const _StoryText({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          entry.year,
          style: const TextStyle(
            fontFamily: 'IBMPlexSans',
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: AppColors.cream,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          entry.description,
          style: const TextStyle(
            fontFamily: 'IBMPlexSans',
            fontSize: 14.5,
            height: 1.7,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}
