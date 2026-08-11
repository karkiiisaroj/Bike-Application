import 'package:flutter/material.dart';
import 'package:bike_app/theme/theme.dart';

/// The four-step progress strip (Machine Selected / Period Set / Dates
/// Confirmed / Reservation). [currentStep] is 1-4. Steps before it read
/// as done, the current one is highlighted, later ones sit muted —
/// so the bar actually tells you where you are in the flow instead of
/// just decorating the top of one long page.
class RentalStepBar extends StatelessWidget {
  final int currentStep;

  const RentalStepBar({super.key, required this.currentStep});

  static const _steps = [
    ('01', 'MACHINE SELECTED'),
    ('02', 'PERIOD SET'),
    ('03', 'DATES CONFIRMED'),
    ('04', 'RESERVATION'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 560;
          final children = <Widget>[
            for (var i = 0; i < _steps.length; i++)
              Expanded(
                child: _StepTile(
                  number: _steps[i].$1,
                  label: _steps[i].$2,
                  state: i + 1 == currentStep
                      ? _StepState.active
                      : (i + 1 < currentStep
                            ? _StepState.done
                            : _StepState.upcoming),
                ),
              ),
          ];

          return isNarrow
              ? Wrap(
                  children: [
                    for (final w in children)
                      SizedBox(width: (constraints.maxWidth - 2) / 2, child: w),
                  ],
                )
              : Row(children: children);
        },
      ),
    );
  }
}

enum _StepState { done, active, upcoming }

class _StepTile extends StatelessWidget {
  final String number;
  final String label;
  final _StepState state;

  const _StepTile({
    required this.number,
    required this.label,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final numberColor = switch (state) {
      _StepState.active => AppColors.brass,
      _StepState.done => AppColors.cream,
      _StepState.upcoming => AppColors.mutedDark,
    };
    final labelColor = switch (state) {
      _StepState.active => AppColors.cream,
      _StepState.done => AppColors.muted,
      _StepState.upcoming => AppColors.mutedDark,
    };

    return Container(
      margin: const EdgeInsets.only(right: 1),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.panel,
        border: Border(
          top: BorderSide(
            color: state == _StepState.active
                ? AppColors.brass
                : AppColors.line,
            width: state == _StepState.active ? 2 : 1,
          ),
          bottom: const BorderSide(color: AppColors.line),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                number,
                style: TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: numberColor,
                ),
              ),
              if (state == _StepState.done) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.check_circle,
                  size: 14,
                  color: AppColors.brass,
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }
}
