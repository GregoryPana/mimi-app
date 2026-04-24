import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:sanity_client/sanity_client.dart';

import '../domain/entities.dart';

const _kProjectId = 'xnvunvku';
const _kDataset = 'production';
const _kApiVersion = 'v2024-04-23';
const _kToken =
    'skt21igxVK7FFAL0KgNYiznri0yObkJuTonPzJFISdhYR9c1b7myMpMw51VNnYuXMWTQTvYOg2jhK8jmDPACLOzQOFJBc9OSas6mNDcDrTmZb6kyFDUVCRA2aqxihmG6XGYXEmfqjvSdkqRxD4ChHSWGMMFsx3pLYvOQtsF6ICF2cnIlOgQo';

class SanityRepository {
  SanityRepository(this.client);

  final SanityClient client;

  // ── Read ──────────────────────────────────────────────────────────────────

  Future<List<dynamic>> fetchSharedNotes() async {
    final res = await client.fetch('*[_type == "sharedNote"] | order(date desc)');
    return (res.result as List<dynamic>?) ?? [];
  }

  Future<List<dynamic>> fetchWatchlist() async {
    final res = await client.fetch('*[_type == "watchlistMovie"] | order(_createdAt desc)');
    return (res.result as List<dynamic>?) ?? [];
  }

  Future<List<dynamic>> fetchSharedImages() async {
    final res = await client.fetch(
      '*[_type == "sharedImage"] | order(timestamp desc) '
      '{ _id, caption, uploadedBy, timestamp, "imageUrl": image.asset->url }',
    );
    return (res.result as List<dynamic>?) ?? [];
  }

  Future<List<dynamic>> fetchSharedCollections() async {
    final res = await client.fetch(
      '*[_type == "userGalleryCollection"] | order(_createdAt desc) '
      '{ _id, name, createdBy, '
      '"images": images[] { localId, caption, uploadedBy, uploadedAt, "imageUrl": image.asset->url } }',
    );
    return (res.result as List<dynamic>?) ?? [];
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  Future<void> createNote({
    required String title,
    required String content,
    required String author,
  }) async {
    await _mutate([
      {
        'create': {
          '_type': 'sharedNote',
          'title': title,
          'content': content,
          'author': author,
          'date': DateTime.now().toUtc().toIso8601String(),
        },
      }
    ]);
  }

  Future<void> addMovie({
    required String title,
    required String addedBy,
  }) async {
    await _mutate([
      {
        'create': {
          '_type': 'watchlistMovie',
          'title': title,
          'isWatched': false,
          'rating': 0,
          'addedBy': addedBy,
        },
      }
    ]);
  }

  Future<void> setWatched(String documentId, bool isWatched) async {
    await _mutate([
      {
        'patch': {
          'id': documentId,
          'set': {'isWatched': isWatched},
        },
      }
    ]);
  }

  Future<void> deleteDocument(String documentId) async {
    await _mutate([
      {
        'delete': {'id': documentId},
      }
    ]);
  }

  /// Uploads raw image bytes to Sanity Assets API.
  /// Returns the asset `_id` (e.g. `image-abc123-800x600-jpg`).
  Future<String> uploadImageAsset(File imageFile) async {
    final ext = imageFile.path.split('.').last.toLowerCase();
    final bytes = await imageFile.readAsBytes();
    final uri = Uri.parse(
      'https://$_kProjectId.api.sanity.io/v$_kApiVersion/assets/images/$_kDataset',
    );
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $_kToken',
        'Content-Type': _mimeType(ext),
      },
      body: bytes,
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Image upload failed: ${response.statusCode} ${response.body}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['document'] as Map<String, dynamic>)['_id'] as String;
  }

  Future<String> createSharedCollection({
    required String name,
    required String createdBy,
  }) async {
    final result = await _mutate([
      {
        'create': {
          '_type': 'userGalleryCollection',
          'name': name,
          'createdBy': createdBy,
          'images': [],
        },
      }
    ]);
    final results = (result as Map<String, dynamic>)['results'] as List<dynamic>;
    return (results.first as Map<String, dynamic>)['id'] as String;
  }

  Future<void> addImageToSharedCollection({
    required String collectionId,
    required String assetId,
    required String caption,
    required String uploadedBy,
  }) async {
    final key = DateTime.now().millisecondsSinceEpoch.toString();
    await _mutate([
      {
        'patch': {
          'id': collectionId,
          'insert': {
            'after': 'images[-1]',
            'items': [
              {
                '_key': key,
                'localId': key,
                'caption': caption,
                'uploadedBy': uploadedBy,
                'uploadedAt': DateTime.now().toUtc().toIso8601String(),
                'image': {
                  '_type': 'image',
                  'asset': {'_type': 'reference', '_ref': assetId},
                },
              }
            ],
          },
        },
      }
    ]);
  }

  /// Removes a single image from a collection's `images[]` array by its `_key`.
  Future<void> removeImageFromSharedCollection({
    required String collectionId,
    required String imageKey,
  }) async {
    await _mutate([
      {
        'patch': {
          'id': collectionId,
          'unset': ['images[_key == "$imageKey"]'],
        },
      }
    ]);
  }

  Future<void> createSharedImage({
    required String assetId,
    required String caption,
    required String uploadedBy,
  }) async {
    await _mutate([
      {
        'create': {
          '_type': 'sharedImage',
          'caption': caption,
          'uploadedBy': uploadedBy,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
          'image': {
            '_type': 'image',
            'asset': {'_type': 'reference', '_ref': assetId},
          },
        },
      }
    ]);
  }

  // ── Seychelles ──────────────────────────────────────────────────────────

  Future<List<dynamic>> fetchSeychellesPacking() async {
    final res = await client.fetch('*[_type == "seychellesPacking"] | order(_createdAt asc)');
    return (res.result as List<dynamic>?) ?? [];
  }

  Future<List<dynamic>> fetchSeychellesItinerary() async {
    final res = await client.fetch('*[_type == "seychellesItinerary"] | order(_createdAt asc)');
    return (res.result as List<dynamic>?) ?? [];
  }

  Future<void> addPackingItem({
    required String category,
    required String item,
    required String addedBy,
  }) async {
    await _mutate([
      {
        'create': {
          '_type': 'seychellesPacking',
          'category': category,
          'item': item,
          'isPacked': false,
          'addedBy': addedBy,
        },
      }
    ]);
  }

  Future<void> addItineraryItem({
    required String day,
    required String title,
    required String description,
    required String addedBy,
  }) async {
    await _mutate([
      {
        'create': {
          '_type': 'seychellesItinerary',
          'day': day,
          'title': title,
          'description': description,
          'addedBy': addedBy,
        },
      }
    ]);
  }

  Future<void> togglePackingItem(String id, bool isPacked) async {
    await _mutate([
      {
        'patch': {
          'id': id,
          'set': {'isPacked': isPacked},
        },
      }
    ]);
  }

  Future<void> deleteSeychellesPackingItem(String id) async {
    await deleteDocument(id);
  }

  Future<void> deleteSeychellesItineraryItem(String id) async {
    await deleteDocument(id);
  }

  // ── URL helpers ───────────────────────────────────────────────────────────

  /// Converts a Sanity image asset `_ref` to a CDN URL.
  /// e.g. `image-Tb9Ew-2000x3000-jpg` → `https://cdn.sanity.io/images/…/Tb9Ew-2000x3000.jpg`
  static String buildImageUrl(String? assetRef, {int? width}) {
    if (assetRef == null || assetRef.isEmpty) return '';
    final withoutPrefix = assetRef.replaceFirst('image-', '');
    final lastDash = withoutPrefix.lastIndexOf('-');
    if (lastDash == -1) return '';
    final ext = withoutPrefix.substring(lastDash + 1);
    final base = withoutPrefix.substring(0, lastDash);
    var url = 'https://cdn.sanity.io/images/$_kProjectId/$_kDataset/$base.$ext';
    if (width != null) url += '?w=$width';
    return url;
  }

  // ── Private ───────────────────────────────────────────────────────────────

  Future<dynamic> _mutate(List<Map<String, dynamic>> mutations) async {
    final uri = Uri.parse(
      'https://$_kProjectId.api.sanity.io/$_kApiVersion/data/mutate/$_kDataset',
    );
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $_kToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'mutations': mutations}),
    );
    if (response.statusCode != 200) {
      throw Exception('Sanity mutation failed (${response.statusCode}): ${response.body}');
    }
    return jsonDecode(response.body);
  }

  static String _mimeType(String ext) {
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      default:
        return 'image/jpeg';
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final sanityConfigProvider = Provider<SanityConfig>((ref) {
  return SanityConfig(
    projectId: _kProjectId,
    dataset: _kDataset,
    apiVersion: _kApiVersion,
    useCdn: false,
    perspective: Perspective.raw,
    token: _kToken,
  );
});

final sanityClientProvider = Provider<SanityClient>((ref) {
  return SanityClient(ref.watch(sanityConfigProvider));
});

final sanityRepositoryProvider = Provider<SanityRepository>((ref) {
  return SanityRepository(ref.watch(sanityClientProvider));
});

final sharedNotesProvider = StreamProvider.autoDispose<List<dynamic>>((ref) async* {
  final repo = ref.watch(sanityRepositoryProvider);
  while (true) {
    yield await repo.fetchSharedNotes();
    await Future.delayed(const Duration(seconds: 10));
  }
});

final watchlistProvider = StreamProvider.autoDispose<List<dynamic>>((ref) async* {
  final repo = ref.watch(sanityRepositoryProvider);
  while (true) {
    yield await repo.fetchWatchlist();
    await Future.delayed(const Duration(seconds: 10));
  }
});

final sharedImagesProvider = StreamProvider.autoDispose<List<dynamic>>((ref) async* {
  final repo = ref.watch(sanityRepositoryProvider);
  while (true) {
    yield await repo.fetchSharedImages();
    await Future.delayed(const Duration(seconds: 10));
  }
});

final sharedCollectionsProvider =
    StreamProvider.autoDispose<List<SharedGalleryCollection>>((ref) async* {
  final repo = ref.watch(sanityRepositoryProvider);
  while (true) {
    final raw = await repo.fetchSharedCollections();
    yield raw
        .map((e) => SharedGalleryCollection.fromJson(e as Map<String, dynamic>))
        .toList();
    await Future.delayed(const Duration(seconds: 10));
  }
});

final seychellesPackingProvider = StreamProvider.autoDispose<List<dynamic>>((ref) async* {
  final repo = ref.watch(sanityRepositoryProvider);
  while (true) {
    yield await repo.fetchSeychellesPacking();
    await Future.delayed(const Duration(seconds: 10));
  }
});

final seychellesItineraryProvider = StreamProvider.autoDispose<List<dynamic>>((ref) async* {
  final repo = ref.watch(sanityRepositoryProvider);
  while (true) {
    yield await repo.fetchSeychellesItinerary();
    await Future.delayed(const Duration(seconds: 10));
  }
});
