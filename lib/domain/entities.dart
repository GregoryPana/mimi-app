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

class UserGalleryCollection {
  const UserGalleryCollection({
    required this.id,
    required this.name,
    required this.images,
  });

  final String id;
  final String name;
  final List<UserGalleryImage> images;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'images': images.map((i) => i.toJson()).toList(),
  };

  factory UserGalleryCollection.fromJson(Map<String, dynamic> json) {
    return UserGalleryCollection(
      id: json['id'] as String,
      name: json['name'] as String,
      images: (json['images'] as List)
          .map((i) => UserGalleryImage.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}

class UserGalleryImage {
  const UserGalleryImage({
    required this.id,
    required this.filePath,
    required this.caption,
  });

  final String id;
  final String filePath;
  final String caption;

  Map<String, dynamic> toJson() => {
    'id': id,
    'filePath': filePath,
    'caption': caption,
  };

  factory UserGalleryImage.fromJson(Map<String, dynamic> json) {
    return UserGalleryImage(
      id: json['id'] as String,
      filePath: json['filePath'] as String,
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
    this.lastViewedComicId,
    this.lastViewedComicPage = 0,
    this.lastViewedGalleryFolder,
    this.lastViewedSection,
    this.pinnedFeatureIds = const <String>{},
  });

  final bool timelineCompleted;
  final Set<String> galleryViewedIds;
  final bool galleryCompleted;
  final Set<String> redeemedVoucherIds;
  final Set<String> favoriteIds;
  final String? lastViewedComicId;
  final int lastViewedComicPage;
  final String? lastViewedGalleryFolder;
  final String? lastViewedSection;
  final Set<String> pinnedFeatureIds;

  AppProgressState copyWith({
    bool? timelineCompleted,
    Set<String>? galleryViewedIds,
    bool? galleryCompleted,
    Set<String>? redeemedVoucherIds,
    Set<String>? favoriteIds,
    String? lastViewedComicId,
    int? lastViewedComicPage,
    String? lastViewedGalleryFolder,
    String? lastViewedSection,
    Set<String>? pinnedFeatureIds,
  }) {
    return AppProgressState(
      timelineCompleted: timelineCompleted ?? this.timelineCompleted,
      galleryViewedIds: galleryViewedIds ?? this.galleryViewedIds,
      galleryCompleted: galleryCompleted ?? this.galleryCompleted,
      redeemedVoucherIds: redeemedVoucherIds ?? this.redeemedVoucherIds,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      lastViewedComicId: lastViewedComicId ?? this.lastViewedComicId,
      lastViewedComicPage: lastViewedComicPage ?? this.lastViewedComicPage,
      lastViewedGalleryFolder: lastViewedGalleryFolder ?? this.lastViewedGalleryFolder,
      lastViewedSection: lastViewedSection ?? this.lastViewedSection,
      pinnedFeatureIds: pinnedFeatureIds ?? this.pinnedFeatureIds,
    );
  }

  static AppProgressState initial() {
    return AppProgressState(
      timelineCompleted: false,
      galleryViewedIds: <String>{},
      galleryCompleted: false,
      redeemedVoucherIds: <String>{},
      favoriteIds: <String>{},
      pinnedFeatureIds: <String>{},
    );
  }
}

class SharedGalleryImage {
  const SharedGalleryImage({
    required this.id,
    required this.key,
    required this.imageUrl,
    required this.caption,
    required this.uploadedBy,
  });

  final String id;
  /// The Sanity array item `_key` — used for unset mutations.
  final String key;
  final String imageUrl;
  final String caption;
  final String uploadedBy;

  factory SharedGalleryImage.fromJson(Map<String, dynamic> json) {
    final k = json['_key'] as String? ??
        json['localId'] as String? ??
        json['_id'] as String? ??
        '';
    return SharedGalleryImage(
      id: json['localId'] as String? ?? json['_key'] as String? ?? '',
      key: k,
      imageUrl: json['imageUrl'] as String? ?? '',
      caption: json['caption'] as String? ?? '',
      uploadedBy: json['uploadedBy'] as String? ?? '',
    );
  }
}

class SharedGalleryCollection {
  const SharedGalleryCollection({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.images,
  });

  final String id;
  final String name;
  final String createdBy;
  final List<SharedGalleryImage> images;

  factory SharedGalleryCollection.fromJson(Map<String, dynamic> json) {
    return SharedGalleryCollection(
      id: json['_id'] as String,
      name: json['name'] as String? ?? 'Untitled',
      createdBy: json['createdBy'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((i) => SharedGalleryImage.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
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
