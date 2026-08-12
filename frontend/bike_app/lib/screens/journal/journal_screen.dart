import 'package:bike_app/models/journal_post_model.dart';
import 'package:bike_app/providers/journal_provider.dart';
import 'package:bike_app/screens/journal/journal_detail_screen.dart';
import 'package:bike_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];
String _fmt(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  String _activeFilter = 'All';

  static const _filters = ['All', 'Ride Report', 'Heritage', 'Gear Guide'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JournalProvider>().fetchPosts();
    });
  }

  List<JournalPost> _filtered(List<JournalPost> all) {
    if (_activeFilter == 'All') return all;
    return all.where((p) => p.categoryLabel == _activeFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JournalProvider>();
    final posts = _filtered(provider.posts);

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width < 640 ? 1 : (width < 1000 ? 2 : 3);

            return Column(
              children: [
                _Header(onBack: () => Navigator.of(context).maybePop(), isNarrow: width < 640),
                _FilterTabs(
                  filters: _filters,
                  active: _activeFilter,
                  onSelect: (f) => setState(() => _activeFilter = f),
                ),
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.brass))
                      : posts.isEmpty
                          ? const Center(
                              child: Text(
                                'No stories here yet.',
                                style: TextStyle(fontFamily: 'IBMPlexSans', color: AppColors.muted),
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: columns == 1 ? 1.05 : 0.82,
                              ),
                              itemCount: posts.length,
                              itemBuilder: (context, i) => _PostCard(post: posts[i]),
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

class _Header extends StatelessWidget {
  final VoidCallback onBack;
  final bool isNarrow;
  const _Header({required this.onBack, required this.isNarrow});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, isNarrow ? 14 : 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.line),
                ),
                child: const Icon(Icons.arrow_back, color: AppColors.cream, size: 16),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'THE JOURNAL',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
                color: AppColors.brass,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isNarrow ? 'Ride Reports &\nHeritage.' : 'Ride Reports & Heritage.',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: isNarrow ? 26 : 30,
                fontWeight: FontWeight.w800,
                height: 1.08,
                color: AppColors.cream,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final List<String> filters;
  final String active;
  final ValueChanged<String> onSelect;

  const _FilterTabs({required this.filters, required this.active, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final f in filters)
              GestureDetector(
                onTap: () => onSelect(f),
                child: Container(
                  margin: const EdgeInsets.only(right: 24),
                  padding: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: f == active ? AppColors.brass : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    f.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: 12,
                      fontWeight: f == active ? FontWeight.w700 : FontWeight.w500,
                      letterSpacing: 1,
                      color: f == active ? AppColors.cream : AppColors.mutedDark,
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

class _PostCard extends StatelessWidget {
  final JournalPost post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => JournalDetailScreen(slug: post.slug)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: post.coverImage.isEmpty
                  ? Container(
                      color: AppColors.ink,
                      child: const Icon(Icons.menu_book_outlined, color: AppColors.mutedDark, size: 34),
                    )
                  : Image.network(
                      post.coverImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.ink,
                        child: const Icon(Icons.menu_book_outlined, color: AppColors.mutedDark, size: 34),
                      ),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.categoryLabel.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'IBMPlexSans',
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            color: AppColors.brass,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          post.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'IBMPlexSans',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.cream,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          post.excerpt,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'IBMPlexSans',
                            fontSize: 12,
                            height: 1.4,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${_fmt(post.publishedAt)}  ·  ${post.readTimeMinutes} min read',
                        style: const TextStyle(fontFamily: 'IBMPlexSans', fontSize: 10.5, color: AppColors.mutedDark),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}