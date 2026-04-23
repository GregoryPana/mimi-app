import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/sanity_repository.dart';
import '../theme.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/pastel_card.dart';

class SharedHubScreen extends ConsumerStatefulWidget {
  const SharedHubScreen({super.key});

  @override
  ConsumerState<SharedHubScreen> createState() => _SharedHubScreenState();
}

class _SharedHubScreenState extends ConsumerState<SharedHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Our Shared Hub'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.pastelPink,
          labelColor: AppColors.pastelPink,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(icon: Icon(LucideIcons.image), text: 'Images'),
            Tab(icon: Icon(LucideIcons.stickyNote), text: 'Notes'),
            Tab(icon: Icon(LucideIcons.clapperboard), text: 'Watchlist'),
          ],
        ),
      ),
      body: AnimatedGradientBackground(
        child: TabBarView(
          controller: _tabController,
          children: [
            _ImagesTab(),
            _NotesTab(),
            _WatchlistTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, _tabController.index),
        backgroundColor: AppColors.pastelPink,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }

  void _showAddDialog(BuildContext context, int tabIndex) {
    final titles = ['Shared Photo', 'New Note', 'Add Movie'];
    final icons = [LucideIcons.image, LucideIcons.stickyNote, LucideIcons.clapperboard];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => PastelCard(
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Icon(icons[tabIndex], size: 32, color: AppColors.pastelPink),
            const SizedBox(height: 12),
            Text(titles[tabIndex], style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 24),
            Text(
              'This will be synced to Sanity CMS\n(Implementation pending API key)',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pastelPink,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Got it!'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagesAsync = ref.watch(sharedImagesProvider);

    return imagesAsync.when(
      data: (images) => images.isEmpty
          ? _buildEmptyState(context, 'No photos shared yet', LucideIcons.image)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 160, 20, 24),
              itemCount: images.length,
              itemBuilder: (context, index) => _SharedImageCard(data: images[index]),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => _buildErrorState(context, err),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Config Required: $error\nPlease set your Sanity Project ID in sanity_repository.dart',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.redAccent),
        ),
      ),
    );
  }
}

class _SharedImageCard extends StatelessWidget {
  final dynamic data;
  const _SharedImageCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: PastelCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                color: AppColors.pastelPeach.withValues(alpha: 0.1),
              ),
              child: const Center(child: Icon(LucideIcons.image, color: AppColors.pastelPeach)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['caption'] ?? 'No caption', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text('Shared on ${data['timestamp'] ?? 'Recently'}', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(sharedNotesProvider);

    return notesAsync.when(
      data: (notes) => notes.isEmpty
          ? _buildEmptyState(context, 'No notes shared yet', LucideIcons.stickyNote)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 160, 20, 24),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PastelCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(note['title'] ?? 'Untitled', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 8),
                        Text(note['content'] ?? '', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 12),
                        Text('By ${note['author'] ?? 'Unknown'}', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                );
              },
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => _buildErrorState(context, err),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(child: Text('Sanity Error: $error', style: const TextStyle(color: Colors.redAccent)));
  }
}

class _WatchlistTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlistAsync = ref.watch(watchlistProvider);

    return watchlistAsync.when(
      data: (movies) => movies.isEmpty
          ? _buildEmptyState(context, 'Watchlist is empty', LucideIcons.clapperboard)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 160, 20, 24),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PastelCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.pastelLavender.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(LucideIcons.film, color: AppColors.pastelLavender),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(movie['title'] ?? 'Movie', style: Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: 4),
                              Row(
                                children: List.generate(
                                  5,
                                  (i) => Icon(
                                    Icons.star,
                                    size: 12,
                                    color: (movie['rating'] ?? 0) > i ? Colors.amber : Colors.grey.shade300,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Checkbox(
                          value: movie['isWatched'] ?? false,
                          onChanged: (_) {},
                          activeColor: AppColors.pastelPink,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => _buildErrorState(context, err),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(child: Text('Sanity Error: $error', style: const TextStyle(color: Colors.redAccent)));
  }
}
