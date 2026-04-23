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

class ComicsScreen extends ConsumerStatefulWidget {
  const ComicsScreen({super.key});

  @override
  ConsumerState<ComicsScreen> createState() => _ComicsScreenState();
}

class _ComicsScreenState extends ConsumerState<ComicsScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.86);
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
        child: Stack(
          children: [
            Positioned.fill(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(color: Colors.white.withValues(alpha: 0.08)),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                0,
                MediaQuery.of(context).padding.top + kToolbarHeight + 12,
                0,
                24,
              ),
              child: contentAsync.when(
                data: (content) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Swipe through our comics, Baby.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: content.comics.length,
                          itemBuilder: (context, index) {
                            final comic = content.comics[index];
                            return AnimatedBuilder(
                              animation: _pageController,
                              builder: (context, child) {
                                double value = 1;
                                if (_pageController.hasClients) {
                                  final page = _pageController.page ?? _pageController.initialPage.toDouble();
                                  value = (1 - (page - index).abs() * 0.12).clamp(0.86, 1.0);
                                }
                                return Transform.scale(
                                  scale: value,
                                  child: child,
                                );
                              },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: _ComicCard(
                                    comic: comic,
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      final progressState = ref.read(progressControllerProvider).value;
                                      final initialPage = progressState?.lastViewedComicId == comic.id ? progressState?.lastViewedComicPage : 0;
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ComicViewerScreen(item: comic, initialPage: initialPage),
                                        ),
                                      );
                                    },
                                  )
                                    .animate()
                                    .fadeIn(duration: 500.ms)
                                    .slideY(begin: 0.08, end: 0, curve: Curves.easeOut),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: content.comics.length,
                        effect: ExpandingDotsEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          expansionFactor: 3,
                          spacing: 6,
                          dotColor: Colors.white.withValues(alpha: 0.4),
                          activeDotColor: AppColors.pastelPink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Swipe left or right to explore.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  );
                },
                loading: () => Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: SkeletonLoader(height: 20, width: 220),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: const SkeletonLoader(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const SkeletonLoader(height: 8, width: 80),
                    const SizedBox(height: 8),
                    const SkeletonLoader(height: 16, width: 140),
                  ],
                ),
                error: (error, _) => Text('Error: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComicCard extends StatelessWidget {
  const _ComicCard({required this.comic, required this.onTap});

  final ComicItem comic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PastelCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.pastelPink, AppColors.pastelLavender],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.pastelPink.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(LucideIcons.bookOpen, size: 26),
          ),
          const SizedBox(height: 16),
          Text(
            comic.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Text(
            'Tap to read',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(LucideIcons.arrowRight),
              label: const Text('Open'),
            ),
          ),
        ],
      ),
    );
  }
}

class ComicViewerScreen extends ConsumerStatefulWidget {
  const ComicViewerScreen({super.key, required this.item, this.initialPage});

  final ComicItem item;
  final int? initialPage;

  @override
  ConsumerState<ComicViewerScreen> createState() => _ComicViewerScreenState();
}

class _ComicViewerScreenState extends ConsumerState<ComicViewerScreen> {
  late final PdfController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PdfController(
      document: PdfDocument.openAsset(widget.item.fileAsset),
      initialPage: widget.initialPage ?? 0,
    );
    // Listen for page changes and save progress
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.item.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: AnimatedGradientBackground(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                0,
                MediaQuery.of(context).padding.top + kToolbarHeight + 12,
                0,
                0,
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
                          child: PastelCard(
                            padding: const EdgeInsets.all(10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image(
                                image: PdfPageImageProvider(pageImage, index, document.id),
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                          ),
                        ),
                      ),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2.0,
                    );
                  },
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: ValueListenableBuilder<int>(
                valueListenable: _controller.pageListenable,
                builder: (context, page, child) {
                  final count = _controller.pagesCount ?? 0;
                  if (count <= 1) return const SizedBox.shrink();
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: AnimatedSmoothIndicator(
                        activeIndex: (page - 1).clamp(0, count - 1),
                        count: count,
                        effect: ExpandingDotsEffect(
                          dotHeight: 6,
                          dotWidth: 6,
                          spacing: 6,
                          expansionFactor: 3,
                          dotColor: Colors.black.withValues(alpha: 0.15),
                          activeDotColor: AppColors.pastelPink,
                        ),
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
