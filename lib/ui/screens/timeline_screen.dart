import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../app/providers.dart';
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
                          'Keep going, Baby — I’m right here.',
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

  final List<dynamic> items;
  final bool timelineCompleted;
  final VoidCallback? onFinish;

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final parts = raw.split('-');
    if (parts.length < 2) return raw;
    final year = parts[0];
    final monthPart = parts[1];
    String monthToName(String value) {
      switch (value) {
        case '01':
          return 'Jan';
        case '02':
          return 'Feb';
        case '03':
          return 'Mar';
        case '04':
          return 'Apr';
        case '05':
          return 'May';
        case '06':
          return 'Jun';
        case '07':
          return 'Jul';
        case '08':
          return 'Aug';
        case '09':
          return 'Sep';
        case '10':
          return 'Oct';
        case '11':
          return 'Nov';
        case '12':
          return 'Dec';
        default:
          return value;
      }
    }

    if (parts.length == 2) {
      final monthText = monthPart.contains('/')
          ? monthPart.split('/').map(monthToName).join('/')
          : monthToName(monthPart);
      return '$monthText\n$year';
    }

    if (parts.length >= 3) {
      final day = parts[2];
      final monthText = monthToName(monthPart);
      return '$day $monthText\n$year';
    }

    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final total = items.length + 1;
    return Column(
      children: List.generate(total, (index) {
        final isLast = index == total - 1;
        final isFirst = index == 0;
        final duration = Duration(milliseconds: 300 + (index * 60));

        Widget content;
        if (isLast) {
          content = PastelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Finish', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  timelineCompleted
                      ? 'Story completed. Thank you, my love. ❤️'
                      : 'When you reach the end, mark it complete.',
                  style: Theme.of(context).textTheme.bodyMedium,
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
          final item = items[index];
          content = PastelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                if (item.date != null)
                  Text(item.date, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 10),
                Text(item.text, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          );
        }

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: duration,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 12 * (1 - value)),
                child: child,
              ),
            );
          },
          child: TimelineTile(
            alignment: TimelineAlign.manual,
            lineXY: 0.24,
            isFirst: isFirst,
            isLast: isLast,
            beforeLineStyle: const LineStyle(
              color: AppColors.pastelLavender,
              thickness: 2,
            ),
            afterLineStyle: const LineStyle(
              color: AppColors.pastelPink,
              thickness: 2,
            ),
            indicatorStyle: IndicatorStyle(
              width: 18,
              height: 18,
              color: isLast ? AppColors.pastelPink : AppColors.pastelLavender,
              iconStyle: isLast
                  ? IconStyle(iconData: Icons.favorite, color: AppColors.textPrimary)
                  : null,
            ),
            startChild: isLast
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 6, right: 16),
                    child: SizedBox(
                      width: 86,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _formatDate(items[index].date),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textPrimary,
                              ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ),
            endChild: Padding(
              padding: const EdgeInsets.only(left: 12, right: 24, bottom: 20),
              child: FractionallySizedBox(
                widthFactor: 0.92,
                child: content,
              ),
            ),
          ),
        );
      }),
    );
  }
}
