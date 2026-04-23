import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../app/notification_service.dart';
import '../../app/providers.dart';
import '../../core/constants/app_config.dart';
import '../../core/utils/date_helpers.dart';
import '../../domain/entities.dart';
import '../theme.dart';
import '../widgets/continue_card.dart';
import '../widgets/featured_memory_card.dart';
import '../widgets/mood_selector.dart';
import '../widgets/quick_action_tile.dart';
import '../widgets/section_header.dart';
import '../widgets/today_card.dart';
import 'comics_screen.dart';
import 'gallery_screen.dart';

import 'timeline_screen.dart';
import 'valentines_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    try {
      await NotificationService.instance.init();
      final now = DateTime.now();
      final controller = ref.read(progressControllerProvider.notifier);
      await controller.scheduleLetterReminder(now);
      await controller.scheduleValentinesReminder(now);
    } catch (_) {
      // Notification setup is best-effort; don't block the app
    }
  }

  @override
  Widget build(BuildContext context) {
    final contentAsync = ref.watch(contentProvider);
    final progressAsync = ref.watch(progressControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: contentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.pastelPink)),
        error: (e, _) => Center(child: Text('Something went wrong 💔\n$e')),
        data: (content) {
          final progress = progressAsync.valueOrNull ?? AppProgressState.initial();
          return _HomeBody(content: content, progress: progress);
        },
      ),
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({required this.content, required this.progress});

  final ContentData content;
  final AppProgressState progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final daysTogether = DateHelpers.daysTogether(now);
    final todayEvent = _findTodayEvent(content.timeline, now);
    final featuredImage = _pickFeaturedImage(content.gallery, now);

    return CustomScrollView(
      slivers: [
        // ── Top gradient background ──
        SliverToBoxAdapter(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.pastelPink.withValues(alpha: 0.25),
                  AppColors.appBackground,
                ],
                stops: const [0.0, 0.6],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Section A: Welcome Header ──
                    _buildWelcomeHeader(context, daysTogether),
                    const SizedBox(height: 20),

                    // ── Section B: Today in Our Story ──
                    if (todayEvent != null) ...[
                      _buildTodayCard(context, todayEvent, now),
                      const SizedBox(height: 22),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Remaining sections ──
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ── Section C: Featured Memory ──
              if (featuredImage != null) ...[
                SectionHeader(icon: LucideIcons.star, label: 'Featured Memory'),
                _buildFeaturedMemory(context, ref, featuredImage),
                const SizedBox(height: 24),
              ],

              // ── Section D: Continue Where You Left Off ──
              SectionHeader(icon: LucideIcons.clock, label: 'Continue where you left off'),
              _buildContinueSection(context),
              const SizedBox(height: 24),

              // ── Section E: Quick Actions Grid ──
              _buildQuickActionsGrid(context),
              const SizedBox(height: 24),

              // ── Section F: Mood Selector ──
              const MoodSelector(),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }

  // ── Section A ──────────────────────────────────────────────

  Widget _buildWelcomeHeader(BuildContext context, int daysTogether) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
              ),
              Text(
                'Baby ❤️',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Day $daysTogether together ❤️',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.pastelPink,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
        // Settings gear
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(LucideIcons.settings, size: 20),
            color: AppColors.textSecondary,
            onPressed: () {
              // Future: open settings
            },
          ),
        ),
      ],
    );
  }

  // ── Section B ──────────────────────────────────────────────

  Widget _buildTodayCard(BuildContext context, TimelineItem event, DateTime now) {
    final parsed = DateHelpers.parseTimelineDate(event.date);
    final relative = parsed != null ? DateHelpers.relativeTimeText(parsed, now) : '';

    return TodayCard(
      title: event.title,
      relativeText: relative,
      imageAsset: event.imageAsset,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const TimelineScreen()),
        );
      },
    );
  }

  // ── Section C ──────────────────────────────────────────────

  Widget _buildFeaturedMemory(BuildContext context, WidgetRef ref, GalleryItem item) {
    final isFav = progress.favoriteIds.contains(item.id);
    return FeaturedMemoryCard(
      imageAsset: item.imageAsset,
      caption: item.caption,
      isFavorited: isFav,
      onFavoriteTap: () {
        ref.read(progressControllerProvider.notifier).toggleFavorite(item.id);
      },
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const GalleryScreen()),
        );
      },
    );
  }

  // ── Section D ──────────────────────────────────────────────

  Widget _buildContinueSection(BuildContext context) {
    // Show comics and gallery continue cards based on content availability
    return Row(
      children: [
        Expanded(
          child: ContinueCard(
            title: 'Comics',
            subtitle: 'Last read',
            detail: content.comics.isNotEmpty ? content.comics.first.title.split('—').last.trim() : 'Start reading',
            icon: LucideIcons.bookOpen,
            backgroundColor: AppColors.pastelPeach,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ComicsScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ContinueCard(
            title: 'Gallery',
            subtitle: 'Last viewed',
            detail: _lastGalleryFolder(),
            icon: LucideIcons.image,
            backgroundColor: AppColors.pastelLavender,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GalleryScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  String _lastGalleryFolder() {
    // Determine which folder was viewed most recently based on viewed IDs
    final seychellesCount = progress.galleryViewedIds.where((id) => id.startsWith('seychelles')).length;
    final malaysiaCount = progress.galleryViewedIds.where((id) => id.startsWith('malaysia')).length;
    if (malaysiaCount > seychellesCount) return 'Malaysia';
    if (seychellesCount > 0) return 'Seychelles';
    return 'Start exploring';
  }

  // ── Section E ──────────────────────────────────────────────

  Widget _buildQuickActionsGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: QuickActionTile(
                icon: LucideIcons.image,
                iconColor: AppColors.pastelLavender,
                backgroundColor: AppColors.pastelLavender,
                title: AppConfig.memoriesLabel,
                subtitle: AppConfig.memoriesSubtitle,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const GalleryScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionTile(
                icon: LucideIcons.calendar,
                iconColor: AppColors.pastelPeach,
                backgroundColor: AppColors.pastelPeach,
                title: AppConfig.timelineLabel,
                subtitle: AppConfig.timelineSubtitle,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TimelineScreen()),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: QuickActionTile(
                icon: LucideIcons.mail,
                iconColor: AppColors.pastelPink,
                backgroundColor: AppColors.pastelPink,
                title: AppConfig.lettersLabel,
                subtitle: AppConfig.lettersSubtitle,
                onTap: () {
                  // For now, navigate to Valentine's screen (letters)
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ValentinesScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionTile(
                icon: LucideIcons.bookOpen,
                iconColor: AppColors.pastelMint,
                backgroundColor: AppColors.pastelMint,
                title: AppConfig.comicsLabel,
                subtitle: AppConfig.comicsSubtitle,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ComicsScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────

  TimelineItem? _findTodayEvent(List<TimelineItem> items, DateTime now) {
    for (final item in items) {
      if (DateHelpers.matchesMonthDay(item.date, now)) {
        return item;
      }
    }
    return null;
  }

  GalleryItem? _pickFeaturedImage(List<GalleryItem> items, DateTime now) {
    if (items.isEmpty) return null;
    final index = DateHelpers.dailyPickIndex(items.length, now);
    return items[index];
  }
}
