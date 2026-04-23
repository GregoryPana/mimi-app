import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities.dart';

class ProgressRepository {
  static const _keyTimelineCompleted = 'timelineCompleted';
  static const _keyGalleryViewedIds = 'galleryViewedIds';
  static const _keyRedeemedVoucherIds = 'redeemedVoucherIds';
  static const _keyGalleryIntroSeen = 'galleryIntroSeen';
  static const _keyLastLetterViewedDate = 'lastLetterViewedDate';

  Future<AppProgressState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final timelineCompleted = prefs.getBool(_keyTimelineCompleted) ?? false;
    final galleryViewedIds = prefs.getStringList(_keyGalleryViewedIds) ?? <String>[];
    final redeemedVoucherIds = prefs.getStringList(_keyRedeemedVoucherIds) ?? <String>[];

    return AppProgressState(
      timelineCompleted: timelineCompleted,
      galleryViewedIds: galleryViewedIds.toSet(),
      galleryCompleted: false,
      redeemedVoucherIds: redeemedVoucherIds.toSet(),
    );
  }

  Future<void> save(AppProgressState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTimelineCompleted, state.timelineCompleted);
    await prefs.setStringList(_keyGalleryViewedIds, state.galleryViewedIds.toList());
    await prefs.setStringList(_keyRedeemedVoucherIds, state.redeemedVoucherIds.toList());
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
}
