import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_config.dart';
import '../theme.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/pastel_card.dart';

class SharedMemoriesScreen extends StatelessWidget {
  const SharedMemoriesScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch \$url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Shared Memories'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: AnimatedGradientBackground(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            MediaQuery.of(context).padding.top + kToolbarHeight + 12,
            20,
            24,
          ),
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _LinkCard(
              title: 'Our Photo Album',
              subtitle: 'Google Drive folder with all our original pictures',
              icon: LucideIcons.image,
              gradient: const LinearGradient(
                colors: [AppColors.pastelPeach, AppColors.pastelPink],
              ),
              onTap: () => _launchUrl(AppConfig.drivePicturesUrl),
            ),
            const SizedBox(height: 16),
            _LinkCard(
              title: 'Our Video Collection',
              subtitle: 'Google Drive folder with all our captured videos',
              icon: LucideIcons.video,
              gradient: const LinearGradient(
                colors: [AppColors.pastelLavender, AppColors.pastelBlue],
              ),
              onTap: () => _launchUrl(AppConfig.driveVideosUrl),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.pastelPink, AppColors.pastelPeach],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(LucideIcons.cloud, size: 24, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Cloud Storage',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Our full collection of high-resolution photos and videos safely stored in the cloud.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
        ),
      ],
    );
  }
}

class _LinkCard extends StatelessWidget {
  const _LinkCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: PastelCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 24, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.appBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.externalLink, size: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
