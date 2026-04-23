import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/entities.dart';

class ContentRepository {
  Future<ContentData> loadAll() async {
    final timelineJson = await rootBundle.loadString('assets/data/timeline.json');
    final galleryJson = await rootBundle.loadString('assets/data/gallery.json');
    final lettersJson = await rootBundle.loadString('assets/data/valentines_letters.json');
    final vouchersJson = await rootBundle.loadString('assets/data/vouchers.json');
    final comicsJson = await rootBundle.loadString('assets/data/comics.json');

    final timeline = (jsonDecode(timelineJson) as List<dynamic>)
        .map((item) => TimelineItem.fromJson(item as Map<String, dynamic>))
        .toList();
    final gallery = (jsonDecode(galleryJson) as List<dynamic>)
        .map((item) => GalleryItem.fromJson(item as Map<String, dynamic>))
        .toList();
    final letters = (jsonDecode(lettersJson) as List<dynamic>)
        .map((item) => ValentineLetter.fromJson(item as Map<String, dynamic>))
        .toList();
    final vouchers = (jsonDecode(vouchersJson) as List<dynamic>)
        .map((item) => Voucher.fromJson(item as Map<String, dynamic>))
        .toList();
    final comics = (jsonDecode(comicsJson) as List<dynamic>)
        .map((item) => ComicItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return ContentData(
      timeline: timeline,
      gallery: gallery,
      letters: letters,
      vouchers: vouchers,
      comics: comics,
    );
  }
}
