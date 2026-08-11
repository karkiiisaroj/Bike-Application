import 'package:bike_app/screens/rentals/rental_booking.dart';
import 'package:bike_app/screens/rentals/rental_header.dart';
import 'package:bike_app/screens/rentals/rental_reservation_screen.dart';
import 'package:bike_app/screens/rentals/rental_reservation_screen.dart';
import 'package:bike_app/screens/rentals/rental_step_bar.dart';
import 'package:bike_app/services/rental_service.dart';
import 'package:flutter/material.dart';
import 'package:bike_app/theme/theme.dart';

const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _formatDate(DateTime d) =>
    '${d.day} ${_monthNames[d.month - 1]} ${d.year}';

class RentalDatesScreen extends StatefulWidget {
  final RentalBooking booking;

  const RentalDatesScreen({super.key, required this.booking});

  @override
  State<RentalDatesScreen> createState() => _RentalDatesScreenState();
}

class _RentalDatesScreenState extends State<RentalDatesScreen> {
  DateTime? _startDate;
  List<DateTimeRange> _bookedRanges = [];
  bool _loadingAvailability = true;

  DateTime? get _endDate => _startDate == null
      ? null
      : _startDate!.add(Duration(days: widget.booking.days - 1));

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    try {
      final raw = await RentalService.fetchBookedRanges(widget.booking.bike.id);
      setState(() {
        _bookedRanges = raw
            .map(
              (r) => DateTimeRange(
                start: DateTime.parse(r['start_date']!),
                end: DateTime.parse(r['end_date']!),
              ),
            )
            .toList();
      });
    } catch (e) {
      debugPrint('⚠️ availability fetch failed: $e');
    } finally {
      if (mounted) setState(() => _loadingAvailability = false);
    }
  }

  // A candidate start date is only selectable if the FULL resulting
  // rental period (start .. start + days - 1) avoids every booked
  // range — not just the start day itself.
  bool _isRangeFree(DateTime start) {
    final end = start.add(Duration(days: widget.booking.days - 1));
    for (final r in _bookedRanges) {
      final overlap = !(end.isBefore(r.start) || start.isAfter(r.end));
      if (overlap) return false;
    }
    return true;
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      selectableDayPredicate: _isRangeFree,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.brass,
              onPrimary: AppColors.ink,
              surface: AppColors.panel,
              onSurface: AppColors.cream,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  void _continue() {
    if (_startDate == null) return;
    if (!_isRangeFree(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Those dates just got booked by someone else — pick another range.',
          ),
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RentalReservationScreen(
          booking: widget.booking.copyWith(startDate: _startDate),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bike = widget.booking.bike;
    final days = widget.booking.days;
    final start = _startDate;
    final end = _endDate;

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const RentalHeader(
                          eyebrow: 'RENTAL SERVICE',
                          title: 'When Do You\nWant To Ride?',
                        ),
                      ],
                    ),
                  ),
                  // Step bar widget (originally from rental_step_bar.dart)
                  // Replace with a simple spacer to avoid missing symbol errors.
                  const SizedBox(height: 24),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${bike.name}  ·  ${days == 1 ? '1 day' : '$days days'}',
                          style: const TextStyle(
                            fontFamily: 'IBMPlexSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mutedDark,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'START DATE',
                          style: TextStyle(
                            fontFamily: 'IBMPlexSans',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                            color: AppColors.mutedDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _loadingAvailability ? null : _pickStartDate,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 18,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.panel,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: start == null
                                    ? AppColors.line
                                    : AppColors.brass,
                              ),
                            ),
                            child: Row(
                              children: [
                                if (_loadingAvailability)
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.brass,
                                    ),
                                  )
                                else
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    color: AppColors.brass,
                                    size: 18,
                                  ),
                                const SizedBox(width: 12),
                                Text(
                                  _loadingAvailability
                                      ? 'Checking availability…'
                                      : (start == null
                                            ? 'Tap to choose a date'
                                            : _formatDate(start)),
                                  style: TextStyle(
                                    fontFamily: 'IBMPlexSans',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: start == null
                                        ? AppColors.mutedDark
                                        : AppColors.cream,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (!_loadingAvailability &&
                            _bookedRanges.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final r in _bookedRanges)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.ember),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${_formatDate(r.start)} – ${_formatDate(r.end)} booked',
                                    style: const TextStyle(
                                      fontFamily: 'IBMPlexSans',
                                      fontSize: 11,
                                      color: AppColors.ember,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                        if (end != null) ...[
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.panel,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.line),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _DateReadout(
                                  label: 'PICK-UP',
                                  value: _formatDate(start!),
                                ),
                                const Icon(
                                  Icons.arrow_forward,
                                  color: AppColors.mutedDark,
                                  size: 16,
                                ),
                                _DateReadout(
                                  label: 'RETURN',
                                  value: _formatDate(end),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _DatesSummaryBar(
              enabled: start != null && !_loadingAvailability,
              onContinue: _continue,
            ),
          ],
        ),
      ),
    );
  }
}

class _DateReadout extends StatelessWidget {
  final String label;
  final String value;

  const _DateReadout({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'IBMPlexSans',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: AppColors.mutedDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'IBMPlexSans',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.cream,
          ),
        ),
      ],
    );
  }
}

class _DatesSummaryBar extends StatelessWidget {
  final bool enabled;
  final VoidCallback onContinue;

  const _DatesSummaryBar({required this.enabled, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.panel,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: enabled ? onContinue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brass,
              foregroundColor: AppColors.ink,
              disabledBackgroundColor: AppColors.line,
              disabledForegroundColor: AppColors.mutedDark,
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
