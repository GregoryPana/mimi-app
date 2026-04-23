import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../app/providers.dart';
import '../theme.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/pastel_card.dart';

class SurpriseGiftScreen extends ConsumerWidget {
  const SurpriseGiftScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressControllerProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Special Moments'),
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
          child: progressAsync.when(
            data: (progress) {
              final progressUnlocked = progress.timelineCompleted && progress.galleryCompleted;
              final now = DateTime.now();
              final anniversaryDate = DateTime(now.year, 2, 2);
              final dateUnlocked = !now.isBefore(anniversaryDate);
              final unlocked = progressUnlocked && dateUnlocked;
              if (!unlocked) {
                if (progressUnlocked && !dateUnlocked) {
                  final daysUntil = anniversaryDate
                      .difference(DateTime(now.year, now.month, now.day))
                      .inDays;
                  return ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      PastelCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.pastelPeach,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(LucideIcons.calendarHeart, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Text('Almost there', style: Theme.of(context).textTheme.titleMedium),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Your surprise opens on Feb 2. Only $daysUntil day(s) left, my love.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    PastelCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.pastelLavender,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(LucideIcons.lock, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Text('Locked for now', style: Theme.of(context).textTheme.titleMedium),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Complete both to unlock your surprise, my love.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _ChecklistItem(
                      label: 'Finish our timeline',
                      done: progress.timelineCompleted,
                    ),
                    const SizedBox(height: 10),
                    _ChecklistItem(
                      label: 'View all gallery memories',
                      done: progress.galleryCompleted,
                    ),
                  ],
                );
              }

              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  PastelCard(
                    gradient: const LinearGradient(
                      colors: [AppColors.pastelPeach, AppColors.pastelPink],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Happy 4 Years Together ❤️', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 10),
                      Text(
                        'Happy Anniversary my love ❤️\n\nBaby… today isn’t just a date to me.\nIt’s a reminder of how lucky I am that I found you, and that we’ve kept choosing each other through everything.\n\nMimi, from the day it started… you became more than just someone I love.\nYou became my peace. My safe place. My comfort.\nYou became the person I think about when something good happens, the person I want to run to when life gets heavy, and the person I want beside me in every future I can imagine.\n\nI love you for the big things — the way you care, the way you love with your whole heart, the way you make the people around you feel seen.\nBut I also love you for the little things…\nThe way you smile when you’re happy, the way your voice changes when you’re excited, the way you can turn a normal moment into something I never want to forget.\n\nBaby, you’ve made me feel loved in a way that’s real.\nNot perfect… but honest.\nThe kind of love that feels like home.\n\nAnd I just want you to know that I don’t take you for granted.\nI notice the effort you put in.\nI notice the love you give.\nI notice the way you show up even when you’re tired, even when things aren’t easy.\nAnd I’m so proud of you, Mimi… more than you know.\n\nThank you for being my baby.\nThank you for being my best friend.\nThank you for being the one person who can calm my heart just by being near me.\n\nI promise you this:\nI will keep choosing you.\nI will keep loving you gently.\nI will keep protecting what we have.\nI will keep trying, learning, growing — for you, for us, for the life we’re building together.\n\nHappy 4 Year Anniversary Mimi 💕\nYou’re my favorite thing in this world… and I’m grateful that I get to love you.\n\nAlways you. Always us. ❤️💙 💜',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      ],
                    ),
                  ),
                ],
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

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({required this.label, required this.done});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return PastelCard(
      child: Row(
        children: [
          Icon(
            done ? LucideIcons.checkCircle2 : LucideIcons.circle,
            color: done ? AppColors.success : AppColors.textMuted,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
