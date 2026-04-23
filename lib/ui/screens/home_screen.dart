import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/providers.dart';
import '../../domain/valentines_logic.dart';
import '../theme.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/pastel_card.dart';
import '../widgets/secondary_button.dart';
import '../widgets/status_pill.dart';
import 'comics_screen.dart';
import 'gallery_screen.dart';
import 'surprise_gift_screen.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(progressControllerProvider.notifier).scheduleLetterReminder(DateTime.now());
      ref.read(progressControllerProvider.notifier).scheduleValentinesReminder(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final contentAsync = ref.watch(contentProvider);
    final progressAsync = ref.watch(progressControllerProvider);
    final now = DateTime.now();
    final valentinesStatus = evaluateValentinesStatus(now);
    final isAnniversary = now.month == 2 && now.day == 2;
    final isValentines = now.month == 2 && now.day == 14;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('For Mimi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: AnimatedGradientBackground(
        child: Stack(
          children: [
            const Positioned(
              top: -120,
              left: -80,
              child: _GlowOrb(
                size: 220,
                colors: [Color(0x66FF8A80), Color(0x00FF8A80)],
              ),
            ),
            const Positioned(
              bottom: -160,
              right: -80,
              child: _GlowOrb(
                size: 260,
                colors: [Color(0x66B39DDB), Color(0x00B39DDB)],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top + kToolbarHeight + 12,
                20,
                12,
              ),
              child: contentAsync.when(
                data: (content) {
                  return progressAsync.when(
                    data: (progress) {
                      final galleryTotal = content.gallery.length;
                      final galleryViewed = progress.galleryViewedIds.length;
                final progressUnlocked = progress.timelineCompleted && progress.galleryCompleted;
                final now = DateTime.now();
                final anniversaryDate = DateTime(now.year, 2, 2);
                final dateUnlocked = !now.isBefore(anniversaryDate);
                final giftUnlocked = progressUnlocked && dateUnlocked;
                final daysUntilGift = dateUnlocked
                    ? 0
                    : anniversaryDate.difference(DateTime(now.year, now.month, now.day)).inDays;

                      return ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withValues(alpha: 0.25),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isValentines
                                          ? 'Happy Valentine\'s Day my Smelly Girl!'
                                          : isAnniversary
                                              ? 'Happy Anniversary Smelly Girl!'
                                              : 'Welcome back, Baby',
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'A soft place for our memories.',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                      _HomeCard(
                        icon: LucideIcons.image,
                        title: 'Memory Gallery',
                        subtitle: '$galleryViewed of $galleryTotal viewed',
                            status: StatusPill(
                              label: progress.galleryCompleted ? 'Completed' : 'In progress',
                              background: progress.galleryCompleted ? AppColors.success : AppColors.pastelBlue,
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const GalleryScreen()),
                              );
                            },
                      ),
                      const SizedBox(height: 14),
                    _HomeCard(
                      icon: LucideIcons.bookOpen,
                      title: 'Comics',
                      subtitle: '${content.comics.length} stories to read',
                      status: const StatusPill(
                        label: 'New',
                        background: AppColors.pastelPeach,
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ComicsScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    _HomeCard(
                      icon: LucideIcons.history,
                      title: 'Our Timeline',
                            subtitle: progress.timelineCompleted ? 'Story completed' : 'Continue our story',
                            status: StatusPill(
                              label: progress.timelineCompleted ? 'Completed' : 'In progress',
                              background: progress.timelineCompleted ? AppColors.success : AppColors.pastelLavender,
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const TimelineScreen()),
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                      _HomeCard(
                        icon: LucideIcons.gift,
                        title: 'Surprise Gift',
                      subtitle: giftUnlocked
                          ? 'Open your surprise'
                          : progressUnlocked
                              ? 'Opens in $daysUntilGift days'
                              : 'Complete gallery + timeline',
                      status: StatusPill(
                        label: giftUnlocked
                            ? 'Unlocked'
                            : progressUnlocked
                                ? 'Waiting'
                                : 'Locked',
                        background: giftUnlocked
                            ? AppColors.success
                            : progressUnlocked
                                ? AppColors.pastelPeach
                                : AppColors.disabled,
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SurpriseGiftScreen()),
                        );
                            },
                          ),
                          const SizedBox(height: 14),
                          _HomeCard(
                            icon: LucideIcons.heart,
                            title: 'Valentine’s Mode',
                            subtitle: valentinesStatus.isUnlocked
                                ? 'Unlocked for today'
                                : '${valentinesStatus.daysUntil} days to Feb 14',
                            status: StatusPill(
                              label: valentinesStatus.isUnlocked ? 'Unlocked' : 'Countdown',
                              background: valentinesStatus.isUnlocked ? AppColors.success : AppColors.pastelPeach,
                            ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ValentinesScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    _LinksCard(
                      onOpenVideos: () => _openLink(
                        'https://drive.google.com/drive/folders/1ZRhE56GaNFpg9YX7Gvm2_TN6yEN4DeUc',
                      ),
                      onOpenPhotos: () => _openLink(
                        'https://drive.google.com/drive/folders/19keZduWmLdKdOWIfyS9aa5Kl0KZZUq9k',
                      ),
                    ),
                        ],
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Text('Error: $error'),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Text('Error: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _openLink(String url) async {
  final uri = Uri.parse(url);
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

class _LinksCard extends StatelessWidget {
  const _LinksCard({required this.onOpenVideos, required this.onOpenPhotos});

  final VoidCallback onOpenVideos;
  final VoidCallback onOpenPhotos;

  @override
  Widget build(BuildContext context) {
    return PastelCard(
      gradient: const LinearGradient(
        colors: [Color(0xFFFFFBF4), Color(0xFFFFF7FA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.pastelPeach,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(LucideIcons.link, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Links', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('Seychelles folders', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'Videos',
                  onPressed: onOpenVideos,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SecondaryButton(
                  label: 'Pictures',
                  onPressed: onOpenPhotos,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0x33FF6B81),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: PastelCard(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFCFE), Color(0xFFF7FBFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: InkWell(
          onTap: onTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFC1CC), Color(0xFFDCC6FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(icon, color: AppColors.textPrimary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              status,
            ],
          ),
        ),
      ),
    );
  }
}
