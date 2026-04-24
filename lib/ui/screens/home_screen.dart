import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
import '../widgets/pinned_shortcut_bar.dart';
import 'comics_screen.dart';
import 'gallery_screen.dart';
import 'letters_screen.dart';
import 'seychelles_screen.dart';
import 'timeline_screen.dart';

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
    } catch (_) {}
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
    final todayEvent = _findTodayEvent(content.timeline, now);
    final featuredImage = _pickFeaturedImage(content.gallery, now);
    final flightRemaining = AppConfig.seychellesFlight.difference(now);
    final daysToFlight = flightRemaining.inDays;
    final showSeychellesTeaser = daysToFlight >= 0 && daysToFlight <= 60;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.of(context).padding.top + 80),
        ),
        // ── Top gradient hero section ──
        SliverToBoxAdapter(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.pastelPink.withValues(alpha: 0.22),
                  AppColors.appBackground,
                ],
                stops: const [0.0, 0.65],
              ),
            ),
            child: SafeArea(
              bottom: false,
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Hero greeting ──
                    _HeroHeader(now: now)
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: -0.04, end: 0, curve: Curves.easeOut),

                    const SizedBox(height: 20),

                    // Pinned shortcuts
                    _buildPinnedShortcuts(context, progress)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 60.ms)
                        .slideY(begin: 0.04, end: 0, curve: Curves.easeOut),

                    if (progress.pinnedFeatureIds.isNotEmpty)
                      const SizedBox(height: 20),

                    // Seychelles teaser — prominent when trip is near
                    if (showSeychellesTeaser) ...[
                      _SeychellesTeaser(
                        daysLeft: daysToFlight,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const SeychellesScreen()),
                        ),
                      )
                          .animate(delay: 120.ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.04, end: 0, curve: Curves.easeOut),
                      const SizedBox(height: 20),
                    ],

                    // Today in our story
                    if (todayEvent != null) ...[
                      _buildTodayCard(context, todayEvent, now)
                          .animate(delay: 180.ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.04, end: 0, curve: Curves.easeOut),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Main content ──
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Featured Memory
              if (featuredImage != null) ...[
                SectionHeader(
                  icon: LucideIcons.star,
                  label: 'Featured Memory',
                  trailing: GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const GalleryScreen()),
                    ),
                    child: Text(
                      'See gallery',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.pastelLavender.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ),
                _buildFeaturedMemory(context, ref, featuredImage)
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.04, end: 0),
                const SizedBox(height: 28),
              ],

              // Continue reading
              SectionHeader(
                icon: LucideIcons.clock,
                label: 'Continue reading',
              ),
              _buildContinueSection(context)
                  .animate(delay: 260.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.04, end: 0),
              const SizedBox(height: 28),

              // Quick Actions
              SectionHeader(icon: LucideIcons.grid, label: 'Explore'),
              _buildQuickActionsGrid(context, ref)
                  .animate(delay: 320.ms)
                  .fadeIn(duration: 400.ms),
              const SizedBox(height: 28),

              // Mood
              const MoodSelector()
                  .animate(delay: 380.ms)
                  .fadeIn(duration: 400.ms),
              const SizedBox(height: 16),
            ]),
          ),
        ),
      ],
    );
  }

  // ── Pinned shortcuts ───────────────────────────────────────────────────────

  Widget _buildPinnedShortcuts(BuildContext context, AppProgressState progress) {
    final allFeatures = [
      PinnedFeature(id: 'gallery', label: 'Memories', icon: LucideIcons.image, color: AppColors.pastelLavender),
      PinnedFeature(id: 'timeline', label: 'Timeline', icon: LucideIcons.calendar, color: AppColors.pastelPeach),
      PinnedFeature(id: 'letters', label: 'Letters', icon: LucideIcons.mail, color: AppColors.pastelPink),
      PinnedFeature(id: 'comics', label: 'Comics', icon: LucideIcons.bookOpen, color: AppColors.pastelMint),
      PinnedFeature(id: 'seychelles', label: 'Trip', icon: LucideIcons.plane, color: AppColors.pastelBlue),
    ];
    final pinned = allFeatures.where((f) => progress.pinnedFeatureIds.contains(f.id)).toList();
    return PinnedShortcutBar(
      pinnedItems: pinned,
      onTap: (feature) => _navigateToFeature(context, feature.id),
    );
  }

  void _navigateToFeature(BuildContext context, String id) {
    Widget? screen;
    switch (id) {
      case 'gallery': screen = const GalleryScreen();
      case 'timeline': screen = const TimelineScreen();
      case 'letters': screen = const LettersScreen();
      case 'comics': screen = const ComicsScreen();
      case 'seychelles': screen = const SeychellesScreen();
    }
    if (screen != null) Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen!));
  }

  // ── Today card ─────────────────────────────────────────────────────────────

  Widget _buildTodayCard(BuildContext context, TimelineItem event, DateTime now) {
    final parsed = DateHelpers.parseTimelineDate(event.date);
    final relative = parsed != null ? DateHelpers.relativeTimeText(parsed, now) : '';
    return TodayCard(
      title: event.title,
      relativeText: relative,
      imageAsset: event.imageAsset,
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TimelineScreen())),
    );
  }

  // ── Featured memory ────────────────────────────────────────────────────────

  Widget _buildFeaturedMemory(BuildContext context, WidgetRef ref, GalleryItem item) {
    final isFav = progress.favoriteIds.contains(item.id);
    return FeaturedMemoryCard(
      imageAsset: item.imageAsset,
      caption: item.caption,
      isFavorited: isFav,
      onFavoriteTap: () => ref.read(progressControllerProvider.notifier).toggleFavorite(item.id),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GalleryScreen())),
    );
  }

  // ── Continue section ───────────────────────────────────────────────────────

  Widget _buildContinueSection(BuildContext context) {
    if (progress.lastViewedSection == 'gallery') {
      final folder = progress.lastViewedGalleryFolder;
      return ContinueCard(
        title: 'Memories',
        subtitle: folder ?? 'Photo Gallery',
        detail: folder != null ? 'Resume viewing' : 'Discover memories',
        icon: LucideIcons.image,
        backgroundColor: AppColors.pastelLavender,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GalleryScreen())),
      );
    }

    final lastComicId = progress.lastViewedComicId;
    final lastComicPage = progress.lastViewedComicPage;
    final lastComic = lastComicId != null
        ? content.comics.cast<ComicItem?>().firstWhere((c) => c?.id == lastComicId, orElse: () => null)
        : null;

    return ContinueCard(
      title: 'Comics',
      subtitle: lastComic?.title.split('—').last.trim() ?? 'Start reading',
      detail: lastComicId != null ? 'Page ${lastComicPage + 1}' : 'Discover story',
      icon: LucideIcons.bookOpen,
      backgroundColor: AppColors.pastelPeach,
      onTap: () {
        if (lastComic != null) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ComicViewerScreen(item: lastComic, initialPage: lastComicPage),
          ));
        } else {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ComicsScreen()));
        }
      },
    );
  }

  // ── Quick actions grid ─────────────────────────────────────────────────────

  Widget _buildQuickActionsGrid(BuildContext context, WidgetRef ref) {
    bool isPinned(String id) => progress.pinnedFeatureIds.contains(id);
    void toggle(String id) => ref.read(progressControllerProvider.notifier).togglePinnedFeature(id);

    final tiles = [
      _TileData(
        id: 'gallery', icon: LucideIcons.image, color: AppColors.pastelLavender,
        title: AppConfig.memoriesLabel, subtitle: AppConfig.memoriesSubtitle,
        screen: const GalleryScreen(),
      ),
      _TileData(
        id: 'timeline', icon: LucideIcons.calendar, color: AppColors.pastelPeach,
        title: AppConfig.timelineLabel, subtitle: AppConfig.timelineSubtitle,
        screen: const TimelineScreen(),
      ),
      _TileData(
        id: 'letters', icon: LucideIcons.mail, color: AppColors.pastelPink,
        title: AppConfig.lettersLabel, subtitle: AppConfig.lettersSubtitle,
        screen: const LettersScreen(),
      ),
      _TileData(
        id: 'comics', icon: LucideIcons.bookOpen, color: AppColors.pastelMint,
        title: AppConfig.comicsLabel, subtitle: AppConfig.comicsSubtitle,
        screen: const ComicsScreen(),
      ),
    ];

    return Column(
      children: [
        // 2×2 main grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: tiles.asMap().entries.map((e) {
            final tile = e.value;
            return QuickActionTile(
              icon: tile.icon,
              iconColor: tile.color,
              backgroundColor: tile.color,
              title: tile.title,
              subtitle: tile.subtitle,
              isPinned: isPinned(tile.id),
              onPinToggle: () => toggle(tile.id),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => tile.screen)),
            )
                .animate(delay: (e.key * 50).ms)
                .fadeIn(duration: 300.ms)
                .scale(begin: const Offset(0.96, 0.96));
          }).toList(),
        ),

        const SizedBox(height: 12),

        // Seychelles — full-width accent tile
        _SeychellesActionTile(
          isPinned: isPinned('seychelles'),
          onPinToggle: () => toggle('seychelles'),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SeychellesScreen())),
        )
            .animate(delay: 200.ms)
            .fadeIn(duration: 300.ms)
            .scale(begin: const Offset(0.96, 0.96)),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  TimelineItem? _findTodayEvent(List<TimelineItem> items, DateTime now) {
    for (final item in items) {
      if (DateHelpers.matchesMonthDay(item.date, now)) return item;
    }
    return null;
  }

  GalleryItem? _pickFeaturedImage(List<GalleryItem> items, DateTime now) {
    if (items.isEmpty) return null;
    return items[DateHelpers.dailyPickIndex(items.length, now)];
  }
}

// ── Tile data model ────────────────────────────────────────────────────────────

class _TileData {
  const _TileData({
    required this.id,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.screen,
  });
  final String id;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Widget screen;
}

// ── Seychelles teaser banner ───────────────────────────────────────────────────

class _SeychellesTeaser extends StatelessWidget {
  const _SeychellesTeaser({required this.daysLeft, required this.onTap});

  final int daysLeft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDeparted = daysLeft == 0;
    final label = isDeparted ? "We're flying today! 🎉" : '$daysLeft days to Seychelles';

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background image attempt + ocean gradient fallback
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0A3D6B), Color(0xFF14A8A4)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
            // Decorative circle
            Positioned(
              right: -24,
              top: -24,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.planeTakeoff, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'May 10–11, 2026 • Indian Ocean 🌊',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_right, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Seychelles full-width action tile ──────────────────────────────────────────

class _SeychellesActionTile extends StatefulWidget {
  const _SeychellesActionTile({
    required this.isPinned,
    required this.onPinToggle,
    required this.onTap,
  });
  final bool isPinned;
  final VoidCallback onPinToggle;
  final VoidCallback onTap;

  @override
  State<_SeychellesActionTile> createState() => _SeychellesActionTileState();
}

class _SeychellesActionTileState extends State<_SeychellesActionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF5AB1F9), Color(0xFF38CC98)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.plane, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConfig.seychellesLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      AppConfig.seychellesSubtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: widget.onPinToggle,
                icon: Icon(
                  widget.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                  color: Colors.white.withValues(alpha: widget.isPinned ? 1.0 : 0.6),
                  size: 20,
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white70, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Hero Header ───────────────────────────────────────────────────────────────

class _HeroHeader extends StatefulWidget {
  const _HeroHeader({required this.now});
  final DateTime now;

  @override
  State<_HeroHeader> createState() => _HeroHeaderState();
}

class _HeroHeaderState extends State<_HeroHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _heartCtrl;
  int _nameIndex = 0;

  static const _names = ['Baby', 'My love', 'Mimi'];
  static const _messages = [
    'Every day with you is my favourite day ❤️',
    'You make the ordinary extraordinary 🌸',
    'The best adventure is the one with you 🌊',
    'Falling for you, always 💕',
  ];

  @override
  void initState() {
    super.initState();
    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    // Rotate name index daily
    _nameIndex = widget.now.day % _names.length;
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diff = _RelationshipDuration.from(
        AppConfig.relationshipStart, widget.now);
    final name = _names[_nameIndex];
    final message = _messages[widget.now.dayOfYear % _messages.length];

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.pastelPink.withValues(alpha: 0.18),
                AppColors.pastelLavender.withValues(alpha: 0.12),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.55),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good ${_timeOfDay(widget.now)},',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.pastelPink,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Pulsing heart
                  AnimatedBuilder(
                    animation: _heartCtrl,
                    builder: (_, __) {
                      final double value = _heartCtrl.value;
                      double scale = 1.0;
                      
                      // Double pulse heartbeat logic
                      if (value < 0.15) {
                        scale = 1.0 + (0.18 * (value / 0.15));
                      } else if (value < 0.3) {
                        scale = 1.18 - (0.12 * ((value - 0.15) / 0.15));
                      } else if (value < 0.45) {
                        scale = 1.06 + (0.1 * ((value - 0.3) / 0.15));
                      } else if (value < 0.8) {
                        scale = 1.16 - (0.16 * ((value - 0.45) / 0.35));
                      }

                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.pastelPink.withValues(alpha: 0.28 * (scale - 0.95)),
                                AppColors.pastelPink.withValues(alpha: 0.0),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.pastelPink.withValues(alpha: 0.12 * (scale - 0.95)),
                                blurRadius: 12 * scale,
                                spreadRadius: 1.5 * scale,
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.favorite_rounded,
                                color: AppColors.pastelPink.withValues(alpha: 0.35),
                                size: 28 * scale,
                              ),
                              const Icon(
                                Icons.favorite_rounded,
                                color: AppColors.pastelPink,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Relationship duration counter
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _DurationUnit(value: diff.years, label: 'years'),
                    _Divider(),
                    _DurationUnit(value: diff.months, label: 'months'),
                    _Divider(),
                    _DurationUnit(value: diff.days, label: 'days'),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Daily message
              Text(
                message,
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary.withValues(alpha: 0.85),
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeOfDay(DateTime now) {
    final h = now.hour;
    if (h < 12) return 'morning';
    if (h < 17) return 'afternoon';
    return 'evening';
  }
}

class _DurationUnit extends StatelessWidget {
  const _DurationUnit({required this.value, required this.label});
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.pastelPink,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      color: AppColors.pastelPink.withValues(alpha: 0.2),
    );
  }
}

// ── Relationship duration math ─────────────────────────────────────────────────

class _RelationshipDuration {
  const _RelationshipDuration({
    required this.years,
    required this.months,
    required this.days,
  });

  final int years;
  final int months;
  final int days;

  factory _RelationshipDuration.from(DateTime start, DateTime now) {
    int y = now.year - start.year;
    int m = now.month - start.month;
    int d = now.day - start.day;
    if (d < 0) {
      m--;
      final prevMonth = DateTime(now.year, now.month, 0);
      d += prevMonth.day;
    }
    if (m < 0) {
      y--;
      m += 12;
    }
    return _RelationshipDuration(years: y, months: m, days: d);
  }
}

extension on DateTime {
  int get dayOfYear {
    final start = DateTime(year, 1, 1);
    return difference(start).inDays;
  }
}
