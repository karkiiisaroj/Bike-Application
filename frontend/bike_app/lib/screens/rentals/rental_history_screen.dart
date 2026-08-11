import 'package:bike_app/models/booking_record_model.dart';
import 'package:bike_app/screens/rentals/booking_detail_screen.dart';
import 'package:bike_app/screens/rentals/rental_header.dart';
import 'package:bike_app/services/rental_service.dart';
import 'package:bike_app/theme/theme.dart';
import 'package:flutter/material.dart';

class RentalHistoryScreen extends StatefulWidget {
  const RentalHistoryScreen({super.key});

  @override
  State<RentalHistoryScreen> createState() => _RentalHistoryScreenState();
}

class _RentalHistoryScreenState extends State<RentalHistoryScreen> {
  late Future<List<BookingRecord>> _future;

  @override
  void initState() {
    super.initState();
    _future = RentalService.fetchMyBookings();
  }

  static const _months = [
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
  static String _fmt(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            const RentalHeader(
              eyebrow: 'RENTAL SERVICE',
              title: 'My Bookings',
              titleFontSize: 36,
              showBookingsLink: false,
            ),
            Expanded(
              child: FutureBuilder<List<BookingRecord>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.brass),
                    );
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Could not load your bookings.',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSans',
                          color: AppColors.muted,
                        ),
                      ),
                    );
                  }
                  final bookings = snapshot.data ?? [];
                  if (bookings.isEmpty) {
                    return const Center(
                      child: Text(
                        'No bookings yet.',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSans',
                          color: AppColors.muted,
                        ),
                      ),
                    );
                  }
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: bookings.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, i) {
                          final r = bookings[i];
                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      BookingDetailScreen(booking: r),
                                ),
                              );
                              setState(
                                () => _future = RentalService.fetchMyBookings(),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
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
                                      width: 96,
                                      height: 64,
                                      color: AppColors.ink,
                                      padding: const EdgeInsets.all(6),
                                      child: r.heroImage.isEmpty
                                          ? const Icon(
                                              Icons.two_wheeler_outlined,
                                              color: AppColors.mutedDark,
                                            )
                                          : Image.network(
                                              r.heroImage,
                                              fit: BoxFit.contain,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                    Icons.two_wheeler_outlined,
                                                    color: AppColors.mutedDark,
                                                  ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          r.bikeName,
                                          style: const TextStyle(
                                            fontFamily: 'IBMPlexSans',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                            color: AppColors.cream,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${_fmt(r.startDate)} – ${_fmt(r.endDate)}',
                                          style: const TextStyle(
                                            fontFamily: 'IBMPlexSans',
                                            fontSize: 12,
                                            color: AppColors.muted,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: _statusColor(r.status),
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            r.status.toUpperCase(),
                                            style: TextStyle(
                                              fontFamily: 'IBMPlexSans',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: _statusColor(r.status),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '₹${r.totalPrice}',
                                    style: const TextStyle(
                                      fontFamily: 'IBMPlexSans',
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.brass,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
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
