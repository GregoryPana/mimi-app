import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities.dart';

class UserGalleryRepository {
  UserGalleryRepository(this._prefs);
  final SharedPreferences _prefs;

  static const _key = 'user_gallery_collections';

  Future<List<UserGalleryCollection>> loadCollections() async {
    final jsonString = _prefs.getString(_key);
    if (jsonString == null) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((j) => UserGalleryCollection.fromJson(j)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCollections(List<UserGalleryCollection> collections) async {
    final jsonString = jsonEncode(collections.map((c) => c.toJson()).toList());
    await _prefs.setString(_key, jsonString);
  }
}
