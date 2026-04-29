import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_config.dart';
import '../../data/sanity_repository.dart';
import '../../app/widget_sync_service.dart';
import '../../app/providers.dart';
import '../theme.dart';
import '../widgets/sanity_error_state.dart';

class SeychellesScreen extends ConsumerStatefulWidget {
  final int initialTab;
  const SeychellesScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<SeychellesScreen> createState() => _SeychellesScreenState();
}

class _SeychellesScreenState extends ConsumerState<SeychellesScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late Timer _timer;
  DateTime _now = DateTime.now();

  late AnimationController _waveController;
  late AnimationController _floatController;
  final Map<String, bool> _loadingPackingItems = {};
  bool _isAddingItem = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 8),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final previous = _now;
      _now = DateTime.now();

      final flightDone = !AppConfig.seychellesFlight.isAfter(_now);
      final wasFlightDone = !AppConfig.seychellesFlight.isAfter(previous);
      if (flightDone && !wasFlightDone) _confettiController.play();

      final tdDone = !AppConfig.seychellesTouchdown.isAfter(_now);
      final wasTdDone = !AppConfig.seychellesTouchdown.isAfter(previous);
      if (tdDone && !wasTdDone) _confettiController.play();

      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _confettiController.dispose();
    _waveController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flightRemaining = AppConfig.seychellesFlight.difference(_now);
    final flightDone = flightRemaining.isNegative;
    final daysLeft = flightDone ? 0 : flightRemaining.inDays;

    ref.listen(seychellesPackingProvider, (prev, next) {
      if (next is AsyncData) {
        final items = next.value as List<dynamic>;
        setState(() {
          _loadingPackingItems.removeWhere((id, targetState) {
            final item =
                items.firstWhere((i) => i['_id'] == id, orElse: () => null);
            if (item == null) return true; // Item deleted
            return item['isPacked'] == targetState;
          });
        });
      }
    });

    return DefaultTabController(
      initialIndex: widget.initialTab,
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF051937),
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 48),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: AppBar(
                title: const Text(
                  'Seychelles 🌴',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                centerTitle: true,
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                elevation: 0,
                surfaceTintColor: Colors.transparent,
                iconTheme: const IconThemeData(color: Colors.white),
                bottom: TabBar(
                  dividerColor: Colors.white.withValues(alpha: 0.1),
                  indicatorColor: const Color(0xFF14A8A4),
                  indicatorWeight: 3,
                  unselectedLabelColor: Colors.white54,
                  labelColor: Colors.white,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                  tabs: const [
                    Tab(text: 'Countdown'),
                    Tab(text: 'Packing'),
                    Tab(text: 'Itinerary'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            // ── Top Persistent Header Mask ──
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).padding.top + kToolbarHeight + 48,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF051937),
                          const Color(0xFF051937).withValues(alpha: 0.8),
                          const Color(0xFF051937).withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Positioned.fill(child: _StarField()),

            TabBarView(
              children: [
                _buildCountdownTab(context, flightDone, daysLeft),
                _buildPackingTab(context),
                _buildItineraryTab(context),
              ],
            ),

            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  AppColors.pastelPink,
                  Color(0xFF14A8A4),
                  AppColors.pastelBlue,
                  AppColors.pastelMint,
                  Colors.white,
                ],
                numberOfParticles: 40,
              ),
            ),
          ],
        ),
        floatingActionButton: SizedBox(
          height: 56,
          child: FloatingActionButton(
            heroTag: 'seychelles_party_fab',
            backgroundColor: const Color(0xFF14A8A4),
            onPressed: () => _confettiController.play(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(LucideIcons.partyPopper, color: Colors.white),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }

  Widget _buildCountdownTab(
    BuildContext context,
    bool flightDone,
    int daysLeft,
  ) {
    return Stack(
      children: [
        // Animated wave at bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedBuilder(
            animation: _waveController,
            builder: (_, __) => CustomPaint(
              painter: _WavePainter(_waveController.value),
              size: const Size(double.infinity, 120),
            ),
          ),
        ),
        Positioned.fill(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              24,
              MediaQuery.of(context).padding.top + kToolbarHeight + 64,
              24,
              120,
            ),
            child: Column(
              children: [
                _HeroPhoto(floatController: _floatController),
                const SizedBox(height: 32),
                if (!flightDone) _DaysHero(daysLeft: daysLeft),
                if (flightDone) _ArrivalBanner(),
                const SizedBox(height: 32),
                _CountdownCard(
                  title: 'Time to Flight',
                  subtitle: 'Departing May 10, 2026',
                  target: AppConfig.seychellesFlight,
                  now: _now,
                  icon: LucideIcons.plane,
                  accentColors: const [Color(0xFFE56B98), Color(0xFF9D7AE0)],
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.08),
                const SizedBox(height: 16),
                _CountdownCard(
                  title: 'Touchdown in Paradise',
                  subtitle: 'Arriving May 11, 2026',
                  target: AppConfig.seychellesTouchdown,
                  now: _now,
                  icon: LucideIcons.mapPin,
                  accentColors: const [Color(0xFF14A8A4), Color(0xFF5AB1F9)],
                ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.08),
                const SizedBox(height: 24),
                _TripHighlights(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPackingTab(BuildContext context) {
    final packingData = ref.watch(seychellesPackingProvider);

    return packingData.when(
      data: (items) {
        final Map<String, List<dynamic>> groupedItems = {};
        for (final item in items) {
          final cat = item['category'] as String? ?? 'General';
          groupedItems.putIfAbsent(cat, () => []).add(item);
        }

        if (items.isEmpty) {
          return _buildEmptyState(
            icon: LucideIcons.luggage,
            title: 'Packing List is Empty',
            subtitle: 'Start adding items for our big trip!',
            onAdd: () => _showAddPackingDialog(context),
          );
        }

        return Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24,
                MediaQuery.of(context).padding.top + kToolbarHeight + 64,
                24,
                120,
              ),
              child: Column(
                children: groupedItems.entries.map((entry) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                color: Color(0xFF14A8A4),
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Icon(
                              LucideIcons.package,
                              color: Colors.white24,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...entry.value.map((item) {
                          final isPacked = item['isPacked'] as bool? ?? false;
                          final itemId = item['_id'] as String;
                          final isLoading =
                              _loadingPackingItems.containsKey(itemId);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: InkWell(
                              onTap: isLoading
                                  ? null
                                  : () async {
                                      setState(() =>
                                          _loadingPackingItems[itemId] =
                                              !isPacked);
                                      try {
                                        await ref
                                            .read(sanityRepositoryProvider)
                                            .togglePackingItem(
                                              itemId,
                                              !isPacked,
                                            );
                                        await WidgetSyncService.syncAll(ref);
                                      } catch (e) {
                                        if (context.mounted) {
                                          setState(() => _loadingPackingItems
                                              .remove(itemId));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content:
                                                  Text(sanityErrorMessage(e)),
                                            ),
                                          );
                                        }
                                      }
                                    },
                              onLongPress: isLoading
                                  ? null
                                  : () => _confirmDelete(
                                        context,
                                        'Delete item?',
                                        () => ref
                                            .read(sanityRepositoryProvider)
                                            .deleteSeychellesPackingItem(
                                              itemId,
                                            ),
                                      ),
                              borderRadius: BorderRadius.circular(12),
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: isLoading ? 0.6 : 1.0,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: isLoading
                                            ? const CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Color(0xFF14A8A4),
                                              )
                                            : Icon(
                                                isPacked
                                                    ? LucideIcons.checkCircle2
                                                    : LucideIcons.circle,
                                                size: 20,
                                                color: isPacked
                                                    ? const Color(0xFF14A8A4)
                                                    : Colors.white
                                                        .withValues(alpha: 0.4),
                                              ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          item['item'] as String? ?? '',
                                          style: TextStyle(
                                            color: isPacked
                                                ? Colors.white54
                                                : Colors.white,
                                            fontSize: 15,
                                            decoration: isPacked
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                        ),
                                      ),
                                      if (item['addedBy'] != null)
                                        Text(
                                          item['addedBy'] as String,
                                          style: const TextStyle(
                                            color: Colors.white24,
                                            fontSize: 10,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            Positioned(
              right: 24,
              bottom: 24,
              child: SizedBox(
                height: 56,
                child: FloatingActionButton.extended(
                  onPressed: () => _showAddPackingDialog(context),
                  backgroundColor: const Color(0xFF14A8A4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  icon: const Icon(LucideIcons.plus, color: Colors.white),
                  label: const Text(
                    'Add Item',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
      error: (e, _) => SanityErrorState(
        title: 'Could not load packing list',
        error: e,
        onRetry: () => ref.invalidate(seychellesPackingProvider),
        dark: true,
      ),
    );
  }

  Widget _buildItineraryTab(BuildContext context) {
    final itineraryData = ref.watch(seychellesItineraryProvider);

    return itineraryData.when(
      data: (items) {
        if (items.isEmpty) {
          return _buildEmptyState(
            icon: LucideIcons.calendarDays,
            title: 'No Plans Yet',
            subtitle: 'Let\'s dream up our adventure together!',
            onAdd: () => _showAddItineraryDialog(context),
          );
        }

        return Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24,
                MediaQuery.of(context).padding.top + kToolbarHeight + 64,
                24,
                120,
              ),
              child: Column(
                children: items.asMap().entries.map((entry) {
                  final item = entry.value;
                  return IntrinsicHeight(
                        child: Row(
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF14A8A4),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    width: 2,
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: InkWell(
                                onLongPress: () => _confirmDelete(
                                  context,
                                  'Delete plan?',
                                  () => ref
                                      .read(sanityRepositoryProvider)
                                      .deleteSeychellesItineraryItem(
                                        item['_id'] as String,
                                      ),
                                ),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 24),
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.05,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item['day'] as String? ?? '',
                                                  style: const TextStyle(
                                                    color: Colors.white60,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                Text(
                                                  item['title'] as String? ??
                                                      '',
                                                  style: const TextStyle(
                                                    color: Color(0xFF14A8A4),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () => _confirmDelete(
                                              context,
                                              'Delete plan?',
                                              () => ref
                                                  .read(
                                                    sanityRepositoryProvider,
                                                  )
                                                  .deleteSeychellesItineraryItem(
                                                    item['_id'] as String,
                                                  ),
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: const Icon(
                                              LucideIcons.trash2,
                                              size: 14,
                                              color: Colors.white24,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        item['description'] as String? ?? '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (item['addedBy'] != null) ...[
                                        const SizedBox(height: 12),
                                        Text(
                                          'Added by ${item['addedBy']}',
                                          style: const TextStyle(
                                            color: Colors.white24,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate(delay: (entry.key * 100).ms)
                      .fadeIn()
                      .slideY(begin: 0.1);
                }).toList(),
              ),
            ),
            Positioned(
              right: 24,
              bottom: 24,
              child: SizedBox(
                height: 56,
                child: FloatingActionButton.extended(
                  onPressed: () => _showAddItineraryDialog(context),
                  backgroundColor: const Color(0xFF14A8A4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  icon: const Icon(LucideIcons.plus, color: Colors.white),
                  label: const Text(
                    'Add Plan',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
      error: (e, _) => SanityErrorState(
        title: 'Could not load itinerary',
        error: e,
        onRetry: () => ref.invalidate(seychellesItineraryProvider),
        dark: true,
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onAdd,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14A8A4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(LucideIcons.plus),
            label: const Text('Add First Item'),
          ),
        ],
      ),
    );
  }

  void _showAddPackingDialog(BuildContext context) {
    final itemController = TextEditingController();
    final catController = TextEditingController(text: 'Essentials');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A3D6B),
        title: const Text(
          'Add Packing Item',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: itemController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Item Name',
                labelStyle: TextStyle(color: Colors.white60),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: catController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Category',
                labelStyle: TextStyle(color: Colors.white60),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white60),
            ),
          ),
          StatefulBuilder(
            builder: (context, setDialogState) {
              return ElevatedButton(
                onPressed: _isAddingItem
                    ? null
                    : () async {
                        if (itemController.text.isNotEmpty) {
                          setDialogState(() => _isAddingItem = true);
                          try {
                            await ref
                                .read(sanityRepositoryProvider)
                                .addPackingItem(
                                  category: catController.text,
                                  item: itemController.text,
                                  addedBy: ref.read(authorProvider).value ??
                                      'Mimi Boy',
                                );
                            await WidgetSyncService.syncAll(ref);
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(sanityErrorMessage(e))),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setDialogState(() => _isAddingItem = false);
                            }
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14A8A4),
                  minimumSize: const Size(80, 40),
                ),
                child: _isAddingItem
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Add',
                        style: TextStyle(color: Colors.white),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddItineraryDialog(BuildContext context) {
    final dayController = TextEditingController(text: 'Day 1');
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A3D6B),
        title: const Text(
          'Add Trip Plan',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dayController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Day (e.g. Day 1)',
                labelStyle: TextStyle(color: Colors.white60),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Location/Title',
                labelStyle: TextStyle(color: Colors.white60),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.white60),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white60),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                try {
                  await ref
                      .read(sanityRepositoryProvider)
                      .addItineraryItem(
                        day: dayController.text,
                        title: titleController.text,
                        description: descController.text,
                        addedBy: ref.read(authorProvider).value ?? 'Mimi Boy',
                      );
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(sanityErrorMessage(e))),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14A8A4),
            ),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    String title,
    Future<void> Function() onDelete,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A3D6B),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white60),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await onDelete();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(sanityErrorMessage(e))),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Hero photo section ────────────────────────────────────────────────────────

class _HeroPhoto extends StatelessWidget {
  const _HeroPhoto({required this.floatController});
  final AnimationController floatController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: floatController,
      builder: (_, child) {
        final offset = Tween<double>(begin: -4, end: 4).evaluate(
          CurvedAnimation(parent: floatController, curve: Curves.easeInOut),
        );
        return Transform.translate(offset: Offset(0, offset), child: child);
      },
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF14A8A4).withValues(alpha: 0.4),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/seychelles/seychelles_beach.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF14A8A4), Color(0xFF0E6E8A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.palmtree,
                    size: 64,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
            // Caption
            const Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SEYCHELLES',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    ),
                  ),
                  Text(
                    'Indian Ocean, Africa 🌊',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            // Plane icon top-right
            const Positioned(
              top: 16,
              right: 16,
              child: Icon(
                LucideIcons.planeTakeoff,
                size: 28,
                color: Colors.white60,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.06),
    );
  }
}

// ── Days hero ─────────────────────────────────────────────────────────────────

class _DaysHero extends StatelessWidget {
  const _DaysHero({required this.daysLeft});
  final int daysLeft;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  height: 1.1,
                ),
                children: [
                  TextSpan(
                    text: '$daysLeft',
                    style: const TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const TextSpan(
                    text: '\ndays to go',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.white60,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            )
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(begin: const Offset(0.9, 0.9)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: const Text(
            'until we fly to paradise 🌴',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _ArrivalBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('🎉', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 12),
        const Text(
          "We're in Seychelles!",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'We made it, baby.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 16,
          ),
        ),
      ],
    ).animate().fadeIn().scale(
      begin: const Offset(0.8, 0.8),
      curve: Curves.elasticOut,
    );
  }
}

// ── Countdown card ────────────────────────────────────────────────────────────

class _CountdownCard extends StatelessWidget {
  const _CountdownCard({
    required this.title,
    required this.subtitle,
    required this.target,
    required this.now,
    required this.icon,
    required this.accentColors,
  });

  final String title;
  final String subtitle;
  final DateTime target;
  final DateTime now;
  final IconData icon;
  final List<Color> accentColors;

  @override
  Widget build(BuildContext context) {
    final remaining = target.difference(now);
    final isDone = remaining.isNegative;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: accentColors),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: accentColors[0].withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (isDone)
                Center(
                  child: Text(
                    '✅ We\'re there!',
                    style: TextStyle(
                      color: accentColors[0],
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _SplitFlapUnit(
                      value: remaining.inDays.toString().padLeft(2, '0'),
                      label: 'Days',
                      accentColor: accentColors[0],
                    ),
                    _Separator(),
                    _SplitFlapUnit(
                      value: (remaining.inHours % 24).toString().padLeft(
                        2,
                        '0',
                      ),
                      label: 'Hrs',
                      accentColor: accentColors[0],
                    ),
                    _Separator(),
                    _SplitFlapUnit(
                      value: (remaining.inMinutes % 60).toString().padLeft(
                        2,
                        '0',
                      ),
                      label: 'Min',
                      accentColor: accentColors[0],
                    ),
                    _Separator(),
                    _SplitFlapUnit(
                      value: (remaining.inSeconds % 60).toString().padLeft(
                        2,
                        '0',
                      ),
                      label: 'Sec',
                      accentColor: accentColors[0],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: Colors.white30,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: Colors.white30,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

class _SplitFlapUnit extends StatelessWidget {
  const _SplitFlapUnit({
    required this.value,
    required this.label,
    required this.accentColor,
  });

  final String value;
  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SplitFlapDigit(value: value, accentColor: accentColor),
        const SizedBox(height: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

// ── Trip highlights ───────────────────────────────────────────────────────────

class _TripHighlights extends StatelessWidget {
  static const _highlights = [
    (icon: LucideIcons.waves, label: 'Crystal Waters'),
    (icon: LucideIcons.sun, label: 'Beach Days'),
    (icon: LucideIcons.utensils, label: 'Creole Food'),
    (icon: LucideIcons.camera, label: 'New Memories'),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What awaits us ✨',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _highlights.asMap().entries.map((e) {
                  final item = e.value;
                  return Expanded(
                    child:
                        Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    item.icon,
                                    color: Colors.white70,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.visible,
                                ),
                              ],
                            )
                            .animate(delay: (e.key * 80).ms)
                            .fadeIn()
                            .slideY(begin: 0.1),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.06);
  }
}

// ── Star field background ─────────────────────────────────────────────────────

class _StarField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _StarPainter(), size: Size.infinite);
  }
}

class _StarPainter extends CustomPainter {
  static final _rng = math.Random(42);
  static final List<Offset> _positions = List.generate(60, (_) {
    return Offset(_rng.nextDouble(), _rng.nextDouble() * 0.55);
  });
  static final List<double> _sizes = List.generate(
    60,
    (_) => _rng.nextDouble() * 2 + 0.5,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.6);
    for (var i = 0; i < _positions.length; i++) {
      canvas.drawCircle(
        Offset(_positions[i].dx * size.width, _positions[i].dy * size.height),
        _sizes[i],
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Wave painter ──────────────────────────────────────────────────────────────

class _WavePainter extends CustomPainter {
  const _WavePainter(this.phase);
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    _drawWave(
      canvas,
      size,
      phase,
      const Color(0xFF14A8A4).withValues(alpha: 0.3),
      0.6,
    );
    _drawWave(
      canvas,
      size,
      phase + 0.3,
      const Color(0xFF0E6E8A).withValues(alpha: 0.4),
      0.75,
    );
    _drawWave(
      canvas,
      size,
      phase + 0.6,
      const Color(0xFF0A3D6B).withValues(alpha: 0.5),
      0.9,
    );
  }

  void _drawWave(
    Canvas canvas,
    Size size,
    double phaseOffset,
    Color color,
    double heightFraction,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = size.height * 0.15;
    final baseline = size.height * heightFraction;

    path.moveTo(0, baseline);
    for (var x = 0.0; x <= size.width; x++) {
      final y =
          baseline +
          math.sin(
                (x / size.width * 2 * math.pi) + (phaseOffset * 2 * math.pi),
              ) *
              waveHeight;
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => oldDelegate.phase != phase;
}

// ── Split-flap digit ──────────────────────────────────────────────────────────
// (Kept from original but restyled with ocean colours)

class _SplitFlapDigit extends StatefulWidget {
  final String value;
  final Color accentColor;

  const _SplitFlapDigit({required this.value, required this.accentColor});

  @override
  State<_SplitFlapDigit> createState() => _SplitFlapDigitState();
}

class _SplitFlapDigitState extends State<_SplitFlapDigit>
    with SingleTickerProviderStateMixin {
  late String _currentValue;
  late String _nextValue;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
    _nextValue = widget.value;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _currentValue = _nextValue);
        _controller.reset();
      }
    });
  }

  @override
  void didUpdateWidget(_SplitFlapDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _nextValue = widget.value;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildHalf(String val, Alignment alignment) {
    return ClipRect(
      child: Align(
        alignment: alignment,
        heightFactor: 0.5,
        child: Container(
          width: 58,
          height: 68,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            val,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: widget.accentColor.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final val = _animation.value;
          final isFirstHalf = val < 0.5;

          return Stack(
            children: [
              Positioned(
                top: 0,
                child: _buildHalf(_nextValue, Alignment.topCenter),
              ),
              Positioned(
                bottom: 0,
                child: _buildHalf(_currentValue, Alignment.bottomCenter),
              ),

              if (isFirstHalf)
                Positioned(
                  top: 0,
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.003)
                      ..rotateX(val * math.pi),
                    alignment: Alignment.bottomCenter,
                    child: _buildHalf(_currentValue, Alignment.topCenter),
                  ),
                )
              else
                Positioned(
                  bottom: 0,
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.003)
                      ..rotateX(-(1 - val) * math.pi),
                    alignment: Alignment.topCenter,
                    child: _buildHalf(_nextValue, Alignment.bottomCenter),
                  ),
                ),

              if (!isFirstHalf)
                Positioned(
                  bottom: 0,
                  child: Opacity(
                    opacity: (1 - val) * 0.4,
                    child: Container(
                      width: 58,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),

              Align(
                alignment: Alignment.center,
                child: Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
