import 'package:bike_app/models/booking_record_model.dart';
import 'package:bike_app/services/api_client.dart';
import 'package:bike_app/services/rental_service.dart';
import 'package:bike_app/theme/theme.dart';
import 'package:flutter/material.dart';

const _months = [
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
String _fmt(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';
String _fmtDateTime(DateTime d) =>
    '${_fmt(d)} at ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// Full detail view for a single booking — reached by tapping a card
/// in RentalHistoryScreen. Shows everything about that reservation and,
/// for still-confirmed bookings, offers a Cancel action that actually
/// calls the backend rather than just changing local state.
class BookingDetailScreen extends StatefulWidget {
  const BookingDetailScreen({super.key, required this.booking});

  final BookingRecord booking;

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  late BookingRecord _booking = widget.booking;
  bool _cancelling = false;

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return AppColors.brassHigh;
      case 'cancelled':
        return AppColors.ember;
      default:
        return AppColors.mutedDark;
    }
  }

  Future<void> _confirmCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.panel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.ember,
                size: 40,
              ),
              const SizedBox(height: 16),
              const Text(
                'Cancel this booking?',
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
                '${_booking.bikeName} for ${_fmt(_booking.startDate)} – ${_fmt(_booking.endDate)} will be released. This can\'t be undone.',
                style: const TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: 13,
                  color: AppColors.muted,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.line),
                      ),
                      child: const Text(
                        'KEEP IT',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSans',
                          color: AppColors.cream,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.ember,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'CANCEL BOOKING',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSans',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true) return;

    setState(() => _cancelling = true);
    try {
      final updated = await RentalService.cancelBooking(_booking.id);
      if (mounted) {
        setState(() {
          _booking = updated;
          _cancelling = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Booking cancelled.')));
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _cancelling = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.firstError),
            backgroundColor: AppColors.ember,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _cancelling = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Couldn't reach the server. Check your connection."),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = _booking;
    final isConfirmed = b.status == 'confirmed';

    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        title: const Text('Booking Details'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Signals whenever _booking gets replaced (e.g. after
            // successful cancel), navigator.pop needs a way to tell the
            // history list to re-fetch — done by popping true below,
            // caught in RentalHistoryScreen's .then().
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                height: 200,
                color: AppColors.panel,
                padding: const EdgeInsets.all(24),
                child: b.heroImage.isEmpty
                    ? const Center(
                        child: Icon(
                          Icons.two_wheeler_outlined,
                          color: AppColors.mutedDark,
                          size: 60,
                        ),
                      )
                    : Image.network(
                        b.heroImage,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.two_wheeler_outlined,
                            color: AppColors.mutedDark,
                            size: 60,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.bikeName,
                        style: const TextStyle(
                          fontFamily: 'IBMPlexSans',
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.cream,
                        ),
                      ),
                      if (b.bikeTagline.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          b.bikeTagline,
                          style: const TextStyle(
                            fontFamily: 'IBMPlexSans',
                            fontSize: 13,
                            color: AppColors.mutedDark,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: _statusColor(b.status)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    b.status.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _statusColor(b.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (b.bikeCategory.isNotEmpty) ...[
                    _DetailRow(label: 'Category', value: b.bikeCategory),
                    const SizedBox(height: 12),
                  ],
                  _DetailRow(label: 'Booking ID', value: '#${b.id}'),
                  const SizedBox(height: 12),
                  _DetailRow(label: 'Pick-up', value: _fmt(b.startDate)),
                  const SizedBox(height: 12),
                  _DetailRow(label: 'Return', value: _fmt(b.endDate)),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Duration',
                    value: b.days == 1 ? '1 day' : '${b.days} days',
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(label: 'Rate', value: '₹${b.pricePerDay}/day'),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Booked on',
                    value: _fmtDateTime(b.createdAt),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Divider(color: AppColors.line, height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL PAID',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: AppColors.mutedDark,
                        ),
                      ),
                      Text(
                        '₹${b.totalPrice}',
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
            if (isConfirmed) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _cancelling ? null : _confirmCancel,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.ember),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _cancelling
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.ember,
                          ),
                        )
                      : const Text(
                          'CANCEL BOOKING',
                          style: TextStyle(
                            fontFamily: 'IBMPlexSans',
                            fontWeight: FontWeight.w700,
                            color: AppColors.ember,
                          ),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

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
