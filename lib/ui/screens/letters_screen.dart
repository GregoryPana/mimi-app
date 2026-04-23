import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../app/providers.dart';
import '../../domain/entities.dart';
import '../theme.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/pastel_card.dart';

/// Permanent Letters screen — always accessible regardless of date.
/// Shows all available love letters in an immersive, readable layout.
/// This replaces the Valentine-only daily drip for year-round access.
class LettersScreen extends ConsumerWidget {
  const LettersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(contentProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Love Letters'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: AnimatedGradientBackground(
        child: contentAsync.when(
          data: (content) {
            if (content.letters.isEmpty) {
              return const Center(
                child: Text('No letters yet 💌'),
              );
            }
            return _LettersList(letters: content.letters);
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.pastelPink),
          ),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}

class _LettersList extends StatelessWidget {
  const _LettersList({required this.letters});

  final List<ValentineLetter> letters;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + kToolbarHeight + 12,
        20,
        24,
      ),
      itemCount: letters.length + 1, // +1 for header
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildHeader(context);
        }
        final letter = letters[index - 1];
        return _LetterCard(
          letter: letter,
          index: index - 1,
          total: letters.length,
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.pastelPink, AppColors.pastelLavender],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(LucideIcons.mail, size: 22, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${letters.length} Love Letters',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(
                    'Written from the heart 💕',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LetterCard extends StatelessWidget {
  const _LetterCard({
    required this.letter,
    required this.index,
    required this.total,
  });

  final ValentineLetter letter;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    // Alternate between pink and lavender card accents
    final isPink = index.isEven;
    final accentColor = isPink ? AppColors.pastelPink : AppColors.pastelLavender;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => _LetterReaderScreen(letter: letter, index: index),
            ),
          );
        },
        child: PastelCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Day badge
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Day',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                    ),
                    Text(
                      '${letter.dayIndex}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Preview
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Love Letter #${letter.dayIndex} 💌',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _preview(letter.text),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Chevron
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _preview(String text) {
    final clean = text.replaceAll('\n', ' ').trim();
    if (clean.length <= 80) return clean;
    return '${clean.substring(0, 77)}...';
  }
}

/// Full-screen immersive letter reader.
class _LetterReaderScreen extends StatelessWidget {
  const _LetterReaderScreen({required this.letter, required this.index});

  final ValentineLetter letter;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isPink = index.isEven;
    final gradient = isPink
        ? const [AppColors.pastelPink, AppColors.pastelLavender]
        : const [AppColors.pastelLavender, AppColors.pastelBlue];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Day ${letter.dayIndex}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: AnimatedGradientBackground(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                gradient[0].withValues(alpha: 0.15),
                gradient[1].withValues(alpha: 0.08),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              24,
              MediaQuery.of(context).padding.top + kToolbarHeight + 12,
              24,
              40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Letter header
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradient),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '💌 Love Letter #${letter.dayIndex}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Letter body
                PastelCard(
                  padding: const EdgeInsets.all(20),
                  child: SelectableText(
                    letter.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.7,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
                const SizedBox(height: 24),
                // Signature
                Center(
                  child: Text(
                    'With all my love ❤️',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
