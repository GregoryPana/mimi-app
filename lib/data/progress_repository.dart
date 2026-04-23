import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities.dart';

class ProgressRepository {
  static const _keyTimelineCompleted = 'timelineCompleted';
  static const _keyGalleryViewedIds = 'galleryViewedIds';
  static const _keyRedeemedVoucherIds = 'redeemedVoucherIds';
  static const _keyGalleryIntroSeen = 'galleryIntroSeen';
  static const _keyLastLetterViewedDate = 'lastLetterViewedDate';
  static const _keyLastViewedComicId = 'lastViewedComicId';
  static const _keyLastComicPage = 'lastComicPage';
  static const _keyLastViewedGalleryFolder = 'lastViewedGalleryFolder';
  static const _keyLastViewedSection = 'lastViewedSection';
  static const _keyFavoriteIds = 'favoriteIds';
  static const _keyPinnedFeatureIds = 'pinnedFeatureIds';

  Future<AppProgressState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final timelineCompleted = prefs.getBool(_keyTimelineCompleted) ?? false;
    final galleryViewedIds = prefs.getStringList(_keyGalleryViewedIds) ?? <String>[];
    final redeemedVoucherIds = prefs.getStringList(_keyRedeemedVoucherIds) ?? <String>[];
    final favoriteIds = prefs.getStringList(_keyFavoriteIds) ?? <String>[];
    final lastViewedComicId = prefs.getString(_keyLastViewedComicId);
    final lastComicPage = prefs.getInt(_keyLastComicPage) ?? 0;
    final lastViewedGalleryFolder = prefs.getString(_keyLastViewedGalleryFolder);
    final lastViewedSection = prefs.getString(_keyLastViewedSection);
    final pinnedFeatureIds = prefs.getStringList(_keyPinnedFeatureIds) ?? <String>[];

    return AppProgressState(
      timelineCompleted: timelineCompleted,
      galleryViewedIds: galleryViewedIds.toSet(),
      galleryCompleted: false,
      redeemedVoucherIds: redeemedVoucherIds.toSet(),
      favoriteIds: favoriteIds.toSet(),
      lastViewedComicId: lastViewedComicId,
      lastViewedComicPage: lastComicPage,
      lastViewedGalleryFolder: lastViewedGalleryFolder,
      lastViewedSection: lastViewedSection,
      pinnedFeatureIds: pinnedFeatureIds.toSet(),
    );
  }

  Future<void> save(AppProgressState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTimelineCompleted, state.timelineCompleted);
    await prefs.setStringList(_keyGalleryViewedIds, state.galleryViewedIds.toList());
    await prefs.setStringList(_keyRedeemedVoucherIds, state.redeemedVoucherIds.toList());
    await prefs.setStringList(_keyFavoriteIds, state.favoriteIds.toList());
    await prefs.setStringList(_keyPinnedFeatureIds, state.pinnedFeatureIds.toList());
    if (state.lastViewedComicId != null) {
      await prefs.setString(_keyLastViewedComicId, state.lastViewedComicId!);
    }
    await prefs.setInt(_keyLastComicPage, state.lastViewedComicPage);
    if (state.lastViewedGalleryFolder != null) {
      await prefs.setString(_keyLastViewedGalleryFolder, state.lastViewedGalleryFolder!);
    }
    if (state.lastViewedSection != null) {
      await prefs.setString(_keyLastViewedSection, state.lastViewedSection!);
    }
  }

  Future<bool> getGalleryIntroSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyGalleryIntroSeen) ?? false;
  }

  Future<void> setGalleryIntroSeen(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyGalleryIntroSeen, value);
  }

  Future<String?> getLastLetterViewedDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastLetterViewedDate);
  }

  Future<void> setLastLetterViewedDate(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastLetterViewedDate, value);
  }

  // ── Continue-tracking: Comics ──────────────────────────
  Future<String?> getLastViewedComicId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastViewedComicId);
  }

  Future<int> getLastComicPage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyLastComicPage) ?? 0;
  }

  Future<void> setLastViewedComic(String comicId, int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastViewedComicId, comicId);
    await prefs.setInt(_keyLastComicPage, page);
  }

  // ── Continue-tracking: Gallery ─────────────────────────
  Future<String?> getLastViewedGalleryFolder() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastViewedGalleryFolder);
  }

  Future<void> setLastViewedGalleryFolder(String folder) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastViewedGalleryFolder, folder);
  }

  // ── Continue-tracking: Last section visited ────────────
  Future<String?> getLastViewedSection() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastViewedSection);
  }

  Future<void> setLastViewedSection(String section) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastViewedSection, section);
  }
}
