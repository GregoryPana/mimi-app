class TimelineItem {
  const TimelineItem({
    required this.id,
    required this.title,
    required this.text,
    this.date,
    this.imageAsset,
  });

  final String id;
  final String title;
  final String text;
  final String? date;
  final String? imageAsset;

  factory TimelineItem.fromJson(Map<String, dynamic> json) {
    return TimelineItem(
      id: json['id'] as String,
      title: json['title'] as String,
      text: json['text'] as String,
      date: json['date'] as String?,
      imageAsset: json['imageAsset'] as String?,
    );
  }
}

class GalleryItem {
  const GalleryItem({
    required this.id,
    required this.imageAsset,
    required this.caption,
  });

  final String id;
  final String imageAsset;
  final String caption;

  factory GalleryItem.fromJson(Map<String, dynamic> json) {
    return GalleryItem(
      id: json['id'] as String,
      imageAsset: json['imageAsset'] as String,
      caption: json['caption'] as String,
    );
  }
}

class ValentineLetter {
  const ValentineLetter({
    required this.dayIndex,
    required this.text,
  });

  final int dayIndex;
  final String text;

  factory ValentineLetter.fromJson(Map<String, dynamic> json) {
    return ValentineLetter(
      dayIndex: json['dayIndex'] as int,
      text: json['text'] as String,
    );
  }
}

class Voucher {
  const Voucher({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String description;

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }
}

class ComicItem {
  const ComicItem({
    required this.id,
    required this.title,
    required this.fileAsset,
  });

  final String id;
  final String title;
  final String fileAsset;

  factory ComicItem.fromJson(Map<String, dynamic> json) {
    return ComicItem(
      id: json['id'] as String,
      title: json['title'] as String,
      fileAsset: json['fileAsset'] as String,
    );
  }
}

class AppProgressState {
  const AppProgressState({
    required this.timelineCompleted,
    required this.galleryViewedIds,
    required this.galleryCompleted,
    required this.redeemedVoucherIds,
    this.favoriteIds = const <String>{},
  });

  final bool timelineCompleted;
  final Set<String> galleryViewedIds;
  final bool galleryCompleted;
  final Set<String> redeemedVoucherIds;
  final Set<String> favoriteIds;

  AppProgressState copyWith({
    bool? timelineCompleted,
    Set<String>? galleryViewedIds,
    bool? galleryCompleted,
    Set<String>? redeemedVoucherIds,
    Set<String>? favoriteIds,
  }) {
    return AppProgressState(
      timelineCompleted: timelineCompleted ?? this.timelineCompleted,
      galleryViewedIds: galleryViewedIds ?? this.galleryViewedIds,
      galleryCompleted: galleryCompleted ?? this.galleryCompleted,
      redeemedVoucherIds: redeemedVoucherIds ?? this.redeemedVoucherIds,
      favoriteIds: favoriteIds ?? this.favoriteIds,
    );
  }

  static AppProgressState initial() {
    return AppProgressState(
      timelineCompleted: false,
      galleryViewedIds: <String>{},
      galleryCompleted: false,
      redeemedVoucherIds: <String>{},
      favoriteIds: <String>{},
    );
  }
}

class ContentData {
  const ContentData({
    required this.timeline,
    required this.gallery,
    required this.letters,
    required this.vouchers,
    required this.comics,
  });

  final List<TimelineItem> timeline;
  final List<GalleryItem> gallery;
  final List<ValentineLetter> letters;
  final List<Voucher> vouchers;
  final List<ComicItem> comics;
}
