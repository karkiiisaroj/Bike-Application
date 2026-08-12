import 'package:bike_app/models/journal_post_model.dart';
import 'package:bike_app/services/journal_service.dart';
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

class JournalDetailScreen extends StatefulWidget {
  const JournalDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  State<JournalDetailScreen> createState() => _JournalDetailScreenState();
}

class _JournalDetailScreenState extends State<JournalDetailScreen> {
  late Future<JournalPost> _future;

  @override
  void initState() {
    super.initState();
    _future = JournalService.fetchPost(widget.slug);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: FutureBuilder<JournalPost>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.brass),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Could not load this story.',
                      style: TextStyle(
                        fontFamily: 'IBMPlexSans',
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: const Text(
                        'GO BACK',
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

            final post = snapshot.data!;
            final paragraphs = (post.content ?? '')
                .split(RegExp(r'\n\s*\n'))
                .map((p) => p.trim())
                .where((p) => p.isNotEmpty)
                .toList();

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 260,
                      width: double.infinity,
                      child: post.coverImage.isEmpty
                          ? Container(color: AppColors.panel)
                          : Image.network(
                              post.coverImage,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Container(color: AppColors.panel),
                            ),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.ink.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: AppColors.cream,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.categoryLabel.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'IBMPlexSans',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: AppColors.brass,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            post.title,
                            style: const TextStyle(
                              fontFamily: 'IBMPlexSans',
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                              color: AppColors.cream,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            '${post.authorName}  ·  ${_fmt(post.publishedAt)}  ·  ${post.readTimeMinutes} min read',
                            style: const TextStyle(
                              fontFamily: 'IBMPlexSans',
                              fontSize: 12,
                              color: AppColors.mutedDark,
                            ),
                          ),
                          const SizedBox(height: 28),
                          for (final para in paragraphs) ...[
                            Text(
                              para,
                              style: const TextStyle(
                                fontFamily: 'IBMPlexSans',
                                fontSize: 15,
                                height: 1.75,
                                color: AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: 18),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
