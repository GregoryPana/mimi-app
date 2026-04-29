import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../app/providers.dart';
import '../../core/utils/date_helpers.dart';
import '../../domain/entities.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/pastel_card.dart';
import '../widgets/primary_button.dart';
import '../theme.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(contentProvider);
    final progressAsync = ref.watch(progressControllerProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Our Timeline'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: AnimatedGradientBackground(
        child: Padding(
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
                  return ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      Text(
                        'Every step with you matters.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      _TimelineList(
                        items: content.timeline,
                        timelineCompleted: progress.timelineCompleted,
                        onFinish: progress.timelineCompleted
                            ? null
                            : () async {
                                await ref
                                    .read(progressControllerProvider.notifier)
                                    .markTimelineCompleted();
                              },
                      ),
                      const SizedBox(height: 24),
                      if (!progress.timelineCompleted)
                        Text(
                          'Keep going, Baby — I\u2019m right here.',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
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
      ),
    );
  }
}

class _TimelineList extends StatelessWidget {
  const _TimelineList({
    required this.items,
    required this.timelineCompleted,
    required this.onFinish,
  });

  final List<TimelineItem> items;
  final bool timelineCompleted;
  final VoidCallback? onFinish;

  /// Group items by year, returning a flat list of widgets with
  /// year headers inserted before each new year group.
  List<_TimelineEntry> _buildEntries() {
    final entries = <_TimelineEntry>[];
    String? lastYear;

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final parsed = DateHelpers.parseTimelineDate(item.date);
      final year = parsed?.year.toString() ?? '';

      // Insert year divider when year changes
      if (year.isNotEmpty && year != lastYear) {
        entries.add(_TimelineEntry(yearHeader: year));
        lastYear = year;
      }

      entries.add(_TimelineEntry(item: item, index: i));
    }

    // Add the finish card
    entries.add(_TimelineEntry(isFinish: true));
    return entries;
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';

    // Try to parse as a full date first
    final parsed = DateHelpers.parseTimelineDate(raw);
    if (parsed != null) {
      // Check if the raw string has a day component
      final hasDay = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(raw);
      if (hasDay) {
        return '${parsed.day} ${_monthName(parsed.month)}\n${parsed.year}';
      }
      // Month only
      return '${_monthName(parsed.month)}\n${parsed.year}';
    }

    // Handle "YYYY-MM/MM" range format
    final rangeMatch = RegExp(r'^(\d{4})-(\d{1,2})/(\d{1,2})$').firstMatch(raw);
    if (rangeMatch != null) {
      final y = rangeMatch.group(1)!;
      final m1 = int.parse(rangeMatch.group(2)!);
      final m2 = int.parse(rangeMatch.group(3)!);
      return '${_monthName(m1)}/${_monthName(m2)}\n$y';
    }

    return raw;
  }

  String _monthName(int month) {
    const months = [
      '',
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
    if (month >= 1 && month <= 12) return months[month];
    return '$month';
  }

  @override
  Widget build(BuildContext context) {
    final entries = _buildEntries();
    final total = entries.length;
    final cardTitleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w700,
    );
    final cardDateStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w600,
    );
    final cardBodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w500,
      height: 1.6,
    );

    return Column(
      children: List.generate(total, (index) {
        final entry = entries[index];
        final isFirst = index == 0;
        final isLast = index == total - 1;

        // ── Year Header ──
        if (entry.yearHeader != null) {
          return Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : 20, bottom: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.pastelPink, AppColors.pastelLavender],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    entry.yearHeader!,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 1,
                    color: AppColors.pastelLavender.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          );
        }

        // ── Finish Card ──
        Widget content;
        if (entry.isFinish) {
          content = PastelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Finish', style: cardTitleStyle),
                const SizedBox(height: 8),
                Text(
                  timelineCompleted
                      ? 'Story completed. Thank you, my love. ❤️'
                      : 'When you reach the end, mark it complete.',
                  style: cardBodyStyle,
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'I finished our story ❤️',
                  onPressed: onFinish,
                ),
              ],
            ),
          );
        } else {
          // ── Timeline Event Card ──
          final item = entry.item!;
          content = PastelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Optional image
                if (item.imageAsset != null && item.imageAsset!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        item.imageAsset!,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        cacheWidth: 600,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                Text(item.title, style: cardTitleStyle),
                const SizedBox(height: 6),
                if (item.date != null) Text(item.date!, style: cardDateStyle),
                const SizedBox(height: 10),
                Text(item.text, style: cardBodyStyle),
              ],
            ),
          );
        }

        return TimelineTile(
          alignment: TimelineAlign.manual,
          lineXY: 0.24,
          isFirst: isFirst && entry.yearHeader == null,
          isLast: isLast,
          beforeLineStyle: const LineStyle(
            color: AppColors.pastelLavender,
            thickness: 2,
          ),
          afterLineStyle: const LineStyle(
            color: AppColors.pastelPink,
            thickness: 2,
          ),
          indicatorStyle: entry.yearHeader != null
              ? const IndicatorStyle(width: 0, height: 0)
              : IndicatorStyle(
                  width: 18,
                  height: 18,
                  color: entry.isFinish
                      ? AppColors.pastelPink
                      : AppColors.pastelLavender,
                  iconStyle: entry.isFinish
                      ? IconStyle(
                          iconData: Icons.favorite,
                          color: AppColors.textPrimary,
                        )
                      : null,
                ),
          startChild: entry.yearHeader != null || entry.isFinish
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 6, right: 16),
                  child: SizedBox(
                    width: 86,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _formatDate(entry.item?.date),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ),
          endChild: entry.yearHeader != null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 24,
                    bottom: 20,
                  ),
                  child: FractionallySizedBox(
                    widthFactor: 0.92,
                    child: content,
                  ),
                ),
        );
      }),
    );
  }
}

/// Internal entry representing either a year header,
/// a timeline event, or the finish card.
class _TimelineEntry {
  _TimelineEntry({
    this.yearHeader,
    this.item,
    this.index,
    this.isFinish = false,
  });

  final String? yearHeader;
  final TimelineItem? item;
  final int? index;
  final bool isFinish;
}
