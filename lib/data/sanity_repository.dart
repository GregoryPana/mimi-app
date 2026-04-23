import 'package:sanity_client/sanity_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SanityRepository {
  final SanityClient client;

  SanityRepository(this.client);

  // Queries
  Future<List<dynamic>> fetchSharedNotes() async {
    return await client.fetch('*[_type == "sharedNote"] | order(date desc)');
  }

  Future<List<dynamic>> fetchWatchlist() async {
    return await client.fetch('*[_type == "watchlistMovie"] | order(_createdAt desc)');
  }

  Future<List<dynamic>> fetchSharedImages() async {
    return await client.fetch('*[_type == "sharedImage"] | order(timestamp desc)');
  }

  // Real-time listener (example)
  Stream<dynamic> listenToType(String type) {
    // Note: sanity_client might have different ways to handle listeners
    // but typically it's an HTTP stream or a websocket.
    // For now, we'll implement a polling or use a dedicated listener if the package supports it.
    return Stream.empty(); 
  }
}

final sanityConfigProvider = Provider<SanityConfig>((ref) {
  return SanityConfig(
    projectId: 'your_project_id', // USER: Replace with your Sanity Project ID
    dataset: 'production',
    apiVersion: '2024-04-23',
    useCdn: false, // Set to false for real-time updates
    token: 'your_token', // USER: Replace with a token with WRITE access
  );
});

final sanityClientProvider = Provider<SanityClient>((ref) {
  return SanityClient(ref.watch(sanityConfigProvider));
});

final sanityRepositoryProvider = Provider<SanityRepository>((ref) {
  return SanityRepository(ref.watch(sanityClientProvider));
});

final sharedNotesProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(sanityRepositoryProvider).fetchSharedNotes();
});

final watchlistProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(sanityRepositoryProvider).fetchWatchlist();
});

final sharedImagesProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(sanityRepositoryProvider).fetchSharedImages();
});
