import 'package:bike_app/screens/rentals/rental_booking.dart';
import 'package:bike_app/screens/rentals/rental_header.dart';
import 'package:bike_app/screens/rentals/rental_history_screen.dart';
import 'package:bike_app/screens/rentals/rental_step_bar.dart';
import 'package:bike_app/services/api_client.dart';
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

class RentalReservationScreen extends StatefulWidget {
  final RentalBooking booking;

  const RentalReservationScreen({super.key, required this.booking});

  @override
  State<RentalReservationScreen> createState() =>
      _RentalReservationScreenState();
}

class _RentalReservationScreenState extends State<RentalReservationScreen> {
  bool _submitting = false;

  Future<void> _confirm() async {
    setState(() => _submitting = true);
    try {
      await RentalService.createBooking(
        bikeId: widget.booking.bike.id,
        startDate: widget.booking.startDate!,
        endDate: widget.booking.endDate!,
      );
      if (!mounted) return;
      _showSuccessDialog();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.firstError),
            backgroundColor: AppColors.ember,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Couldn't reach the server. Check your connection."),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showSuccessDialog() {
    final booking = widget.booking;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.panel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: AppColors.brass, size: 44),
              const SizedBox(height: 16),
              const Text(
                'Reservation Confirmed',
                style: TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cream,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${booking.bike.name} is booked for ${_formatDate(booking.startDate!)} – ${_formatDate(booking.endDate!)}.',
                style: const TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: 13,
                  color: AppColors.muted,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const RentalHistoryScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.brass),
                  ),
                  child: const Text(
                    'VIEW MY BOOKINGS',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSans',
                      color: AppColors.brass,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brass,
                    foregroundColor: AppColors.ink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final bike = booking.bike;
    final start = booking.startDate!;
    final end = booking.endDate!;

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
                          title: 'Review &\nReserve.',
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Review &\nReserve.',
                          style: TextStyle(
                            fontFamily: 'IBMPlexSans',
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            color: AppColors.cream,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const RentalStepBar(currentStep: 4),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.panel,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: 80,
                                  height: 56,
                                  color: AppColors.ink,
                                  padding: const EdgeInsets.all(6),
                                  child: bike.heroImage.isEmpty
                                      ? const Icon(
                                          Icons.two_wheeler_outlined,
                                          color: AppColors.brass,
                                          size: 28,
                                        )
                                      : Image.network(
                                          bike.heroImage,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
                                                Icons.two_wheeler_outlined,
                                                color: AppColors.brass,
                                                size: 28,
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
                                      bike.name,
                                      style: const TextStyle(
                                        fontFamily: 'IBMPlexSans',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.cream,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      bike.tagline,
                                      style: const TextStyle(
                                        fontFamily: 'IBMPlexSans',
                                        fontSize: 12,
                                        color: AppColors.mutedDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 18),
                            child: Divider(color: AppColors.line, height: 1),
                          ),
                          _SummaryRow(
                            label: 'Pick-up',
                            value: _formatDate(start),
                          ),
                          const SizedBox(height: 12),
                          _SummaryRow(label: 'Return', value: _formatDate(end)),
                          const SizedBox(height: 12),
                          _SummaryRow(
                            label: 'Duration',
                            value: booking.days == 1
                                ? '1 day'
                                : '${booking.days} days',
                          ),
                          const SizedBox(height: 12),
                          _SummaryRow(
                            label: 'Rate',
                            value: '₹${bike.pricePerDay}/day',
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 18),
                            child: Divider(color: AppColors.line, height: 1),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'TOTAL',
                                style: TextStyle(
                                  fontFamily: 'IBMPlexSans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                  color: AppColors.mutedDark,
                                ),
                              ),
                              Text(
                                '₹${booking.totalPrice}',
                                style: const TextStyle(
                                  fontFamily: 'IBMPlexSans',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.brass,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: AppColors.panel,
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brass,
                    foregroundColor: AppColors.ink,
                    disabledBackgroundColor: AppColors.line,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.ink,
                          ),
                        )
                      : const Text(
                          'Confirm Reservation',
                          style: TextStyle(
                            fontFamily: 'IBMPlexSans',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
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

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'IBMPlexSans',
            fontSize: 13,
            color: AppColors.muted,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'IBMPlexSans',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.cream,
          ),
        ),
      ],
    );
  }
}
