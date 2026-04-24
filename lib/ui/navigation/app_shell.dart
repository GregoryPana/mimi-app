import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/home_screen.dart';
import '../screens/shared_hub_screen.dart';
import '../screens/surprise_gift_screen.dart';
import '../theme.dart';
import '../screens/favorites_screen.dart';
import '../widgets/persistent_header.dart';
import '../../data/sanity_repository.dart';
import '../../app/notification_service.dart';

/// Main navigation shell with bottom navigation bar.
/// Wraps the primary screens (Home, Favorites, Unlocks, Profile).
/// The (+) center button is a decorative FAB placeholder.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 0;

  static const _screens = [
    HomeScreen(),
    FavoritesScreen(),
    SurpriseGiftScreen(),
    SharedHubScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Listen for new shared content to show notifications
    ref.listen(sharedNotesProvider, (previous, next) {
      final items = next.valueOrNull;
      final prevItems = previous?.valueOrNull;
      if (items != null && prevItems != null && items.length > prevItems.length) {
        final newNote = items.first;
        NotificationService.instance.showInstantNotification(
          id: 101,
          title: 'New Shared Note 📝',
          body: '${newNote['author']} just shared: "${newNote['title']}"',
        );
      }
    });

    ref.listen(sharedImagesProvider, (previous, next) {
      final items = next.valueOrNull;
      final prevItems = previous?.valueOrNull;
      if (items != null && prevItems != null && items.length > prevItems.length) {
        final newImg = items.first;
        NotificationService.instance.showInstantNotification(
          id: 102,
          title: 'New Photo Shared 📸',
          body: '${newImg['uploadedBy']} uploaded a new memory!',
        );
      }
    });

    ref.listen(watchlistProvider, (previous, next) {
      final items = next.valueOrNull;
      final prevItems = previous?.valueOrNull;
      if (items != null && prevItems != null && items.length > prevItems.length) {
        final newMovie = items.first;
        NotificationService.instance.showInstantNotification(
          id: 103,
          title: 'Movie Added to Watchlist 🍿',
          body: 'New movie added: ${newMovie['title']}',
        );
      }
    });

    ref.listen(seychellesPackingProvider, (previous, next) {
      final items = next.valueOrNull;
      final prevItems = previous?.valueOrNull;
      if (items != null && prevItems != null && items.length > prevItems.length) {
        final newItem = items.last; // Packing is ordered _createdAt asc
        NotificationService.instance.showInstantNotification(
          id: 104,
          title: 'New Packing Item 🧳',
          body: 'Don\'t forget to pack: ${newItem['item']}',
        );
      }
    });

    ref.listen(seychellesItineraryProvider, (previous, next) {
      final items = next.valueOrNull;
      final prevItems = previous?.valueOrNull;
      if (items != null && prevItems != null && items.length > prevItems.length) {
        final newItem = items.last; // Itinerary is ordered _createdAt asc
        NotificationService.instance.showInstantNotification(
          id: 105,
          title: 'New Trip Plan! ✈️',
          body: '${newItem['day']}: ${newItem['title']}',
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: PersistentHeader(),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.pastelPink.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isActive: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  icon: Icons.favorite_rounded,
                  label: 'Favorites',
                  isActive: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),

                _NavItem(
                  icon: Icons.card_giftcard_rounded,
                  label: 'Unlocks',
                  isActive: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _NavItem(
                  icon: Icons.cloud_outlined,
                  label: 'Cloud',
                  isActive: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? AppColors.pastelPink : AppColors.textSecondary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.pastelPink : AppColors.textSecondary,
              ),
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 3),
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: AppColors.pastelPink,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

