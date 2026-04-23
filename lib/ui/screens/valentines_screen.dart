import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../app/providers.dart';
import '../../domain/entities.dart';
import '../../domain/valentines_logic.dart';
import '../theme.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/pastel_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/status_pill.dart';

class ValentinesScreen extends ConsumerWidget {
  const ValentinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(contentProvider);
    final progressAsync = ref.watch(progressControllerProvider);
    final status = evaluateValentinesStatus(DateTime.now());

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Valentine’s Mode'),
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
                  if (!status.isUnlocked) {
                    ValentineLetter? letter;
                    if (status.dayIndex != null) {
                      for (final item in content.letters) {
                        if (item.dayIndex == status.dayIndex) {
                          letter = item;
                          break;
                        }
                      }
                    }
                    if (status.dayIndex != null && letter != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ref
                            .read(progressControllerProvider.notifier)
                            .markTodayLetterViewed(DateTime.now());
                      });
                    }
                    final now = DateTime.now();
                    final target = DateTime(now.year, 2, 14);
                    final endTime = target.millisecondsSinceEpoch;
                    final visibleLetters = status.dayIndex == null
                        ? <ValentineLetter>[]
                        : content.letters
                            .where((item) => item.dayIndex <= status.dayIndex!)
                            .toList();

                    return ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        PastelCard(
                        gradient: const LinearGradient(
                          colors: [AppColors.pastelMint, AppColors.pastelBlue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Countdown', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            CountdownTimer(
                              endTime: endTime,
                              widgetBuilder: (context, time) {
                                if (time == null) {
                                  return Text(
                                    'It’s time 💘',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  );
                                }
                                final days = time.days ?? 0;
                                final hours = time.hours ?? 0;
                                final minutes = time.min ?? 0;
                                final seconds = time.sec ?? 0;
                                return Row(
                                  children: [
                                    _CountdownPill(label: 'Days', value: days.toString()),
                                    const SizedBox(width: 10),
                                    _CountdownPill(label: 'Hours', value: hours.toString().padLeft(2, '0')),
                                    const SizedBox(width: 10),
                                    _CountdownPill(label: 'Mins', value: minutes.toString().padLeft(2, '0')),
                                    const SizedBox(width: 10),
                                    _CountdownPill(label: 'Secs', value: seconds.toString().padLeft(2, '0')),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                        const SizedBox(height: 14),
                        if (visibleLetters.isEmpty)
                          PastelCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(LucideIcons.mail, size: 20),
                                    const SizedBox(width: 8),
                                    Text('Today’s Love Letter 💌', style: Theme.of(context).textTheme.titleMedium),
                                    const Spacer(),
                                    const StatusPill(
                                      label: 'Soon',
                                      background: AppColors.pastelLavender,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Letters begin Feb 1, my love.',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          )
                        else ...[
                          Row(
                            children: [
                              Text('Your Letters', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(width: 8),
                              StatusPill(
                                label: '${visibleLetters.length} unlocked',
                                background: AppColors.pastelBlue,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          for (final item in visibleLetters) ...[
                            _LetterAccordion(
                              item: item,
                              isToday: item.dayIndex == status.dayIndex,
                            ),
                            const SizedBox(height: 12),
                          ],
                        ],
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
                            Row(
                              children: [
                                const Icon(LucideIcons.heartHandshake, size: 22),
                                const SizedBox(width: 8),
                                Text('Unlocked', style: Theme.of(context).textTheme.titleMedium),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Happy Valentine’s Day, my baby ❤️\n\nMimi… sometimes I sit and think about how all of this started.\nTwo people matching at 3am on some random night, not knowing that it would turn into this.\n\nFrom that first official day on 02/02… I already knew I was in love with you.\nAnd then a few days later, Starbucks meeting for the first time ever.\nMe being nervous as hell.\nYou making it feel easy.\nAnd that first kiss in your park… that moment still lives in my head like it happened yesterday.\n\nYou moving in my place until it basically became our home together.\nIt all happened so fast but felt so right to me.\n\nThen life started testing us.\nBut somehow we kept choosing each other.\n\nOne Valentines we spent at Universal Studios in Singapore…\nThat Valentine’s gift wasn’t just a trip.\nIt was one of the first times I felt like we were building real memories outside of just surviving things.\nSeeing you there, excited and alive, made everything worth it.\n\nBut Seychelles with you…\nThat changed everything.\nYou made me love my country again.\nThe beaches, the food, the environment and people — none of it would’ve meant half as much without you.\nYou being there with me made it one of the best times of my life.\n\nWe’ve had our hardest goodbye too.\nThat day when I had to leave and we both wept…\nYou were so strong even when it hurt.\nAnd I\'ve realized something over the months:\nDistance doesn’t weaken what’s real. It proves it.\n\nAnd through everything — the moves, the long distance, the stress, the world being unfair —\nI still choose you, and you still choose me\n\nNot because it’s easy.\nNot because it’s perfect.\nBut because it’s you.\n\nYou are my comfort.\nMy best friend.\nMy favorite laugh.\nMy gaming partner.\nMy safe place.\nMy baby.\n\nFour years is not small.\nWe’ve built something real — something tested.\n\nHappy Valentine’s Day, Mimi.\nThank you for loving me through every version of me.\nThank you for staying.\nThank you for being mine.\n\nAnd I promise you this —\nI’m still choosing you.\nToday.\nTomorrow.\nAnd every 3am after that.\n\nI wish we were together right now so we can enjoy each other’s company but im glad at least we can still celebrate it together as valentines.\n❤️ I love you. ❤️\n\n(I cant believe my original code name was Valentine BTW)',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      PastelCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mini-game (coming soon)', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text(
                              'A sweet surprise will be here for us to play together.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text('Vouchers', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      for (final voucher in content.vouchers) ...[
                        _VoucherCard(
                          title: voucher.title,
                          description: voucher.description,
                          redeemed: progress.redeemedVoucherIds.contains(voucher.id),
                          onRedeem: () async {
                            await ref.read(progressControllerProvider.notifier).redeemVoucher(voucher.id);
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
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

class _VoucherCard extends StatelessWidget {
  const _VoucherCard({
    required this.title,
    required this.description,
    required this.redeemed,
    required this.onRedeem,
  });

  final String title;
  final String description;
  final bool redeemed;
  final VoidCallback onRedeem;

  @override
  Widget build(BuildContext context) {
    return PastelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              StatusPill(
                label: redeemed ? 'Redeemed ✅' : 'Available',
                background: redeemed ? AppColors.success : AppColors.pastelBlue,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 10),
          PrimaryButton(
            label: redeemed ? 'Redeemed' : 'Redeem voucher',
            onPressed: redeemed ? null : onRedeem,
          ),
        ],
      ),
    );
  }
}


class _LetterAccordion extends StatelessWidget {
  const _LetterAccordion({required this.item, required this.isToday});

  final ValentineLetter item;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return PastelCard(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isToday ? AppColors.pastelPeach : AppColors.pastelLavender,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(LucideIcons.mail, size: 18),
            ),
            const SizedBox(width: 10),
            Text('Day ${item.dayIndex}', style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            StatusPill(
              label: isToday ? 'Today' : 'Unlocked',
              background: isToday ? AppColors.pastelPeach : AppColors.pastelLavender,
            ),
          ],
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              item.text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownPill extends StatelessWidget {
  const _CountdownPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
