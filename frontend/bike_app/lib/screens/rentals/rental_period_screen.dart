import 'package:bike_app/screens/rentals/rental_booking.dart';
import 'package:bike_app/screens/rentals/rental_dates_screen.dart';
import 'package:bike_app/screens/rentals/rental_header.dart';
import 'package:bike_app/screens/rentals/rental_step_bar.dart';
import 'package:flutter/material.dart';
import 'package:bike_app/theme/theme.dart';

/// STEP 2 — how many days is this rental for. Quick-pick chips plus a
/// stepper for anything custom.
class RentalPeriodScreen extends StatefulWidget {
  final RentalBooking booking;

  const RentalPeriodScreen({super.key, required this.booking});

  @override
  State<RentalPeriodScreen> createState() => _RentalPeriodScreenState();
}

class _RentalPeriodScreenState extends State<RentalPeriodScreen> {
  static const _quickPicks = [1, 3, 7, 14];
  late int _days = widget.booking.days;

  void _setDays(int value) {
    setState(() => _days = value.clamp(1, 60));
  }

  void _continue() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            RentalDatesScreen(booking: widget.booking.copyWith(days: _days)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bike = widget.booking.bike;
    final total = bike.pricePerDay * _days;

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  const RentalHeader(
                    eyebrow: 'RENTAL SERVICE',
                    title: 'How Long\nDo You Need It?',
                  ),
                  const RentalStepBar(currentStep: 2),
                  const SizedBox(height: 28),
                  _SelectedBikeCard(
                    name: bike.name,
                    tagline: bike.tagline,
                    pricePerDay: bike.pricePerDay,
                    heroImage: bike.heroImage,
                  ),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'QUICK PICK',
                          style: TextStyle(
                            fontFamily: 'IBMPlexSans',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                            color: AppColors.mutedDark,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final d in _quickPicks)
                              _DurationChip(
                                label: d == 1 ? '1 Day' : '$d Days',
                                selected: _days == d,
                                onTap: () => _setDays(d),
                              ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'OR SET EXACTLY',
                          style: TextStyle(
                            fontFamily: 'IBMPlexSans',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                            color: AppColors.mutedDark,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _DaysStepper(days: _days, onChanged: _setDays),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _PeriodSummaryBar(days: _days, total: total, onContinue: _continue),
          ],
        ),
      ),
    );
  }
}

/// Compact readout of the bike chosen in step 1, so people don't lose
/// context once they leave the grid page behind. Shows the actual
/// bike photo, not a generic icon.
class _SelectedBikeCard extends StatelessWidget {
  final String name;
  final String tagline;
  final int pricePerDay;
  final String heroImage;

  const _SelectedBikeCard({
    required this.name,
    required this.tagline,
    required this.pricePerDay,
    required this.heroImage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 66,
                height: 44,
                color: AppColors.ink,
                padding: const EdgeInsets.all(4),
                child: heroImage.isEmpty
                    ? const Icon(
                        Icons.two_wheeler_outlined,
                        color: AppColors.brass,
                        size: 22,
                      )
                    : Image.network(
                        heroImage,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.two_wheeler_outlined,
                          color: AppColors.brass,
                          size: 22,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cream,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tagline,
                    style: const TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: 12,
                      color: AppColors.mutedDark,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '₹$pricePerDay/day',
              style: const TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.brass,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DurationChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DurationChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.brass : AppColors.panel,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.brass : AppColors.line,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'IBMPlexSans',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.ink : AppColors.cream,
          ),
        ),
      ),
    );
  }
}

class _DaysStepper extends StatelessWidget {
  final int days;
  final ValueChanged<int> onChanged;

  const _DaysStepper({required this.days, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          _StepperButton(icon: Icons.remove, onTap: () => onChanged(days - 1)),
          Expanded(
            child: Center(
              child: Text(
                days == 1 ? '1 Day' : '$days Days',
                style: const TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cream,
                ),
              ),
            ),
          ),
          _StepperButton(icon: Icons.add, onTap: () => onChanged(days + 1)),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: AppColors.cream, size: 18),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _PeriodSummaryBar extends StatelessWidget {
  final int days;
  final int total;
  final VoidCallback onContinue;

  const _PeriodSummaryBar({
    required this.days,
    required this.total,
    required this.onContinue,
  });

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
                  'ESTIMATED TOTAL',
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
                  '₹$total  ·  ${days == 1 ? '1 day' : '$days days'}',
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
