import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pdfx/pdfx.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../app/providers.dart';
import '../../domain/entities.dart';
import '../theme.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/pastel_card.dart';
import '../widgets/skeleton_loader.dart';

// Cover gradient presets per comic index — gives each comic its own identity
const _kCoverGradients = [
  [Color(0xFFE56B98), Color(0xFF9D7AE0)], // pink → lavender
  [Color(0xFF5AB1F9), Color(0xFF38CC98)], // blue → mint
  [Color(0xFFFA8155), Color(0xFFE56B98)], // peach → pink
  [Color(0xFF9D7AE0), Color(0xFF5AB1F9)], // lavender → blue
];

const _kCoverIcons = [
  LucideIcons.heart,
  LucideIcons.clock,
  LucideIcons.map,
  LucideIcons.coffee,
];

class ComicsScreen extends ConsumerStatefulWidget {
  const ComicsScreen({super.key});

  @override
  ConsumerState<ComicsScreen> createState() => _ComicsScreenState();
}

class _ComicsScreenState extends ConsumerState<ComicsScreen> {
  late final PageController _pageController;
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.78);
    _pageController.addListener(() {
      setState(() => _currentPage = _pageController.page ?? 0);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(progressControllerProvider.notifier).updateLastViewedSection('comic');
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contentAsync = ref.watch(contentProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Comics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: AnimatedGradientBackground(
        child: contentAsync.when(
          data: (content) => _ComicsList(
            comics: content.comics,
            pageController: _pageController,
            currentPage: _currentPage,
          ),
          loading: () => _LoadingState(),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}

class _ComicsList extends ConsumerWidget {
  const _ComicsList({
    required this.comics,
    required this.pageController,
    required this.currentPage,
  });

  final List<ComicItem> comics;
  final PageController pageController;
  final double currentPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressControllerProvider).valueOrNull;
    final lastComicId = progress?.lastViewedComicId;

    final topPad = MediaQuery.of(context).padding.top + kToolbarHeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: topPad + 16),

        // Header blurb
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Our Comics',
                style: Theme.of(context).textTheme.titleLarge,
              ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.04),
              const SizedBox(height: 4),
              Text(
                '${comics.length} stories just for us.',
                style: Theme.of(context).textTheme.bodyMedium,
              ).animate(delay: 80.ms).fadeIn(duration: 400.ms).slideX(begin: -0.04),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // Comic carousel
        SizedBox(
          height: 420,
          child: PageView.builder(
            controller: pageController,
            itemCount: comics.length,
            itemBuilder: (context, index) {
              final comic = comics[index];
              final isCurrent = (currentPage - index).abs() < 0.5;
              final isContinue = comic.id == lastComicId;
              final lastPage = isContinue ? (progress?.lastViewedComicPage ?? 0) : 0;

              final scale = (1 - (currentPage - index).abs() * 0.08).clamp(0.88, 1.0);

              return Transform.scale(
                scale: scale,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _ComicCard(
                    comic: comic,
                    index: index,
                    isCurrent: isCurrent,
                    isContinue: isContinue,
                    lastPage: lastPage,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ComicViewerScreen(
                            item: comic,
                            initialPage: isContinue ? lastPage : 0,
                          ),
                        ),
                      );
                    },
                  ).animate().fadeIn(duration: 500.ms, delay: (index * 80).ms)
                   .slideY(begin: 0.06, end: 0, curve: Curves.easeOut),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        // Page indicator
        Center(
          child: SmoothPageIndicator(
            controller: pageController,
            count: comics.length,
            effect: ExpandingDotsEffect(
              dotHeight: 8,
              dotWidth: 8,
              expansionFactor: 3,
              spacing: 6,
              dotColor: Colors.white.withValues(alpha: 0.3),
              activeDotColor: AppColors.pastelPink,
            ),
          ),
        ),

        const SizedBox(height: 12),

        Center(
          child: Text(
            'Swipe to browse',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _ComicCard extends StatelessWidget {
  const _ComicCard({
    required this.comic,
    required this.index,
    required this.isCurrent,
    required this.isContinue,
    required this.lastPage,
    required this.onTap,
  });

  final ComicItem comic;
  final int index;
  final bool isCurrent;
  final bool isContinue;
  final int lastPage;
  final VoidCallback onTap;

  List<Color> get _gradient => _kCoverGradients[index % _kCoverGradients.length];
  IconData get _icon => _kCoverIcons[index % _kCoverIcons.length];

  @override
  Widget build(BuildContext context) {
    return PastelCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cover area
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Decorative circles
                  Positioned(
                    top: -30,
                    right: -30,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -20,
                    left: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  // Icon + number
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          child: Icon(_icon, size: 34, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '#${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // "Continue" badge
                  if (isContinue)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.bookmark, size: 12, color: _gradient[0]),
                            const SizedBox(width: 4),
                            Text(
                              'p.$lastPage',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _gradient[0],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Info + CTA area
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comic.title,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        isContinue ? 'Continue reading' : 'Start reading',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _gradient[0],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: onTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: _gradient),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: _gradient[0].withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isContinue ? LucideIcons.play : LucideIcons.arrowRight,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isContinue ? 'Continue' : 'Open',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
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
    );
  }
}

class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top + kToolbarHeight;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, topPad + 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLoader(height: 32, width: 160),
          const SizedBox(height: 8),
          const SkeletonLoader(height: 16, width: 220),
          const SizedBox(height: 32),
          Expanded(
            child: Center(child: const SkeletonLoader()),
          ),
        ],
      ),
    );
  }
}

// ── Comic Viewer ──────────────────────────────────────────────────────────────

class ComicViewerScreen extends ConsumerStatefulWidget {
  const ComicViewerScreen({super.key, required this.item, this.initialPage});

  final ComicItem item;
  final int? initialPage;

  @override
  ConsumerState<ComicViewerScreen> createState() => _ComicViewerScreenState();
}

class _ComicViewerScreenState extends ConsumerState<ComicViewerScreen> {
  late final PdfController _controller;
  bool _uiVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = PdfController(
      document: PdfDocument.openAsset(widget.item.fileAsset),
      initialPage: widget.initialPage ?? 0,
    );
    _controller.pageListenable.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    final page = _controller.pageListenable.value;
    ref.read(progressControllerProvider.notifier).updateLastComicProgress(widget.item.id, page);
  }

  @override
  void dispose() {
    _controller.pageListenable.removeListener(_onPageChanged);
    _controller.dispose();
    super.dispose();
  }

  void _toggleUi() {
    setState(() => _uiVisible = !_uiVisible);
    if (_uiVisible) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedOpacity(
          opacity: _uiVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: AppBar(
            title: Text(
              widget.item.title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            backgroundColor: Colors.black.withValues(alpha: 0.5),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: _toggleUi,
        child: Stack(
          children: [
            // PDF content
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  0,
                  _uiVisible ? MediaQuery.of(context).padding.top + kToolbarHeight : 0,
                  0,
                  _uiVisible ? 72 : 0,
                ),
                child: PdfView(
                  controller: _controller,
                  scrollDirection: Axis.horizontal,
                  pageSnapping: true,
                  builders: PdfViewBuilders<DefaultBuilderOptions>(
                    options: const DefaultBuilderOptions(),
                    pageBuilder: (context, pageImage, index, document) {
                      return PhotoViewGalleryPageOptions.customChild(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image(
                                image: PdfPageImageProvider(pageImage, index, document.id),
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                          ),
                        ),
                        minScale: PhotoViewComputedScale.contained * 0.9,
                        maxScale: PhotoViewComputedScale.covered * 2.5,
                      );
                    },
                  ),
                ),
              ),
            ),

            // Bottom page indicator bar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: 0,
              right: 0,
              bottom: _uiVisible ? 0 : -80,
              child: _PageBar(controller: _controller),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageBar extends StatelessWidget {
  const _PageBar({required this.controller});
  final PdfController controller;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            24,
            12,
            24,
            12 + MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
          ),
          child: ValueListenableBuilder<int>(
            valueListenable: controller.pageListenable,
            builder: (context, page, child) {
              final count = controller.pagesCount ?? 0;
              if (count <= 1) return const SizedBox.shrink();

              final progress = count > 0 ? (page - 1) / (count - 1) : 0.0;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'Page $page',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$count pages',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.pastelPink),
                      minHeight: 4,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
