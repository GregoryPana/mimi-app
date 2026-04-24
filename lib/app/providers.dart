import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/content_repository.dart';
import 'notification_service.dart';
import '../data/progress_repository.dart';
import '../data/user_gallery_repository.dart';
import '../domain/entities.dart';
import 'package:shared_preferences/shared_preferences.dart';

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return ContentRepository();
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository();
});

final contentProvider = FutureProvider<ContentData>((ref) async {
  return ref.watch(contentRepositoryProvider).loadAll();
});

final progressControllerProvider = AsyncNotifierProvider<AppProgressController, AppProgressState>(
  AppProgressController.new,
);

final authorProvider = AsyncNotifierProvider<AuthorController, String>(
  AuthorController.new,
);

class AuthorController extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('shared_author') ?? 'Mimi Boy';
  }

  Future<void> setAuthor(String author) async {
    state = AsyncData(author);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('shared_author', author);
  }
}

class AppProgressController extends AsyncNotifier<AppProgressState> {
  @override
  Future<AppProgressState> build() async {
    final repo = ref.watch(progressRepositoryProvider);
    final loaded = await repo.load();
    final content = ref.watch(contentProvider).valueOrNull;
    final galleryCount = content?.gallery.length ?? 0;
    final galleryCompleted = galleryCount > 0 && loaded.galleryViewedIds.length >= galleryCount;
    return loaded.copyWith(galleryCompleted: galleryCompleted);
  }

  Future<void> markTimelineCompleted() async {
    final current = state.value ?? AppProgressState.initial();
    final next = current.copyWith(timelineCompleted: true);
    state = AsyncData(next);
    await ref.read(progressRepositoryProvider).save(next);
  }

  Future<void> markGalleryViewed(String id, int totalCount) async {
    final current = state.value ?? AppProgressState.initial();
    final updatedIds = {...current.galleryViewedIds, id};
    final galleryCompleted = totalCount > 0 && updatedIds.length >= totalCount;
    final next = current.copyWith(
      galleryViewedIds: updatedIds,
      galleryCompleted: galleryCompleted,
    );
    state = AsyncData(next);
    await ref.read(progressRepositoryProvider).save(next);
  }

  Future<void> redeemVoucher(String id) async {
    final current = state.value ?? AppProgressState.initial();
    if (current.redeemedVoucherIds.contains(id)) {
      return;
    }
    final updatedIds = {...current.redeemedVoucherIds, id};
    final next = current.copyWith(redeemedVoucherIds: updatedIds);
    state = AsyncData(next);
    await ref.read(progressRepositoryProvider).save(next);
  }

  Future<void> toggleFavorite(String id) async {
    final current = state.value ?? AppProgressState.initial();
    final updated = {...current.favoriteIds};
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    final next = current.copyWith(favoriteIds: updated);
    state = AsyncData(next);
    await ref.read(progressRepositoryProvider).save(next);
  }

  Future<bool> showGalleryIntroIfNeeded() async {
    final repo = ref.read(progressRepositoryProvider);
    final seen = await repo.getGalleryIntroSeen();
    if (seen) {
      return false;
    }
    await repo.setGalleryIntroSeen(true);
    return true;
  }

  Future<void> markTodayLetterViewed(DateTime now) async {
    final repo = ref.read(progressRepositoryProvider);
    final dateKey = _formatDateKey(now);
    final lastSeen = await repo.getLastLetterViewedDate();
    if (lastSeen == dateKey) return;
    await repo.setLastLetterViewedDate(dateKey);
    await NotificationService.instance.cancelDailyLetterReminder();
  }

  Future<void> scheduleLetterReminder(DateTime now) async {
    final repo = ref.read(progressRepositoryProvider);
    final lastSeen = await repo.getLastLetterViewedDate();

    if (!_isLetterWindow(now)) {
      await NotificationService.instance.cancelDailyLetterReminder();
      return;
    }

    final todayKey = _formatDateKey(now);
    if (lastSeen == todayKey) {
      await NotificationService.instance.cancelDailyLetterReminder();
      return;
    }

    final scheduled = _nextReminderTime(now);
    if (scheduled == null) {
      await NotificationService.instance.cancelDailyLetterReminder();
      return;
    }

    await NotificationService.instance.scheduleDailyLetterReminder(
      scheduledDate: scheduled,
    );
  }

  Future<void> scheduleValentinesReminder(DateTime now) async {
    final target = DateTime(now.year, 2, 14);
    if (!now.isBefore(target)) {
      await NotificationService.instance.cancelValentinesReminder();
      return;
    }
    final times = [
      const Duration(hours: 0),
      const Duration(hours: 4),
      const Duration(hours: 10),
      const Duration(hours: 14),
    ];
    for (var i = 0; i < times.length; i++) {
      final scheduled = DateTime(target.year, target.month, target.day)
          .add(times[i]);
      await NotificationService.instance.scheduleValentinesReminder(
        scheduledDate: scheduled,
        notificationId: NotificationService.valentinesNotificationId + i,
      );
    }
  }

  Future<void> updateLastComicProgress(String comicId, int page) async {
    final current = state.value ?? AppProgressState.initial();
    final next = current.copyWith(
      lastViewedComicId: comicId,
      lastViewedComicPage: page,
      lastViewedSection: 'comic',
    );
    state = AsyncData(next);
    await ref.read(progressRepositoryProvider).save(next);
  }

  Future<void> updateLastGalleryFolder(String folder) async {
    final current = state.value ?? AppProgressState.initial();
    final next = current.copyWith(
      lastViewedGalleryFolder: folder,
      lastViewedSection: 'gallery',
    );
    state = AsyncData(next);
    await ref.read(progressRepositoryProvider).save(next);
  }

  Future<void> updateLastViewedSection(String section) async {
    final current = state.value ?? AppProgressState.initial();
    if (current.lastViewedSection == section) return;
    
    final next = current.copyWith(lastViewedSection: section);
    state = AsyncData(next);
    await ref.read(progressRepositoryProvider).save(next);
  }

  Future<void> togglePinnedFeature(String id) async {
    final current = state.value ?? AppProgressState.initial();
    final updated = {...current.pinnedFeatureIds};
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    final next = current.copyWith(pinnedFeatureIds: updated);
    state = AsyncData(next);
    await ref.read(progressRepositoryProvider).save(next);
  }
}

final userGalleryControllerProvider = AsyncNotifierProvider<UserGalleryController, List<UserGalleryCollection>>(
  UserGalleryController.new,
);

class UserGalleryController extends AsyncNotifier<List<UserGalleryCollection>> {
  @override
  Future<List<UserGalleryCollection>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final repo = UserGalleryRepository(prefs);
    return repo.loadCollections();
  }

  Future<void> addCollection(String name) async {
    final current = state.value ?? [];
    final collection = UserGalleryCollection(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      images: [],
    );
    final next = [...current, collection];
    state = AsyncData(next);
    final prefs = await SharedPreferences.getInstance();
    await UserGalleryRepository(prefs).saveCollections(next);
  }

  Future<void> addImageToCollection(String collectionId, String filePath, String caption) async {
    final current = state.value ?? [];
    final next = current.map((c) {
      if (c.id == collectionId) {
        final image = UserGalleryImage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          filePath: filePath,
          caption: caption,
        );
        return UserGalleryCollection(
          id: c.id,
          name: c.name,
          images: [...c.images, image],
        );
      }
      return c;
    }).toList();
    state = AsyncData(next);
    final prefs = await SharedPreferences.getInstance();
    await UserGalleryRepository(prefs).saveCollections(next);
  }
}

String _formatDateKey(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

bool _isLetterWindow(DateTime now) {
  return now.month == 2 && now.day >= 1 && now.day <= 13;
}

DateTime? _nextReminderTime(DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  if (!_isLetterWindow(now)) return null;

  final todayAtTwo = DateTime(now.year, now.month, now.day, 14);
  if (now.isBefore(todayAtTwo)) {
    return todayAtTwo;
  }

  final tomorrow = today.add(const Duration(days: 1));
  if (tomorrow.month == 2 && tomorrow.day <= 13) {
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 14);
  }

  return null;
}
