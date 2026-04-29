import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import 'package:sanity_client/sanity_client.dart';
import '../data/sanity_repository.dart';

@pragma('vm:entry-point')
Future<void> backgroundCallback(Uri? uri) async {
  print('Background callback triggered with URI: $uri');
  
  if (uri?.host == 'toggle_packing') {
    final id = uri?.queryParameters['id'];
    final isPacked = uri?.queryParameters['isPacked'] == 'true';
    
    if (id != null) {
      print('Toggling packing item: $id to ${!isPacked}');
      
      // Create a manual repo instance since we're in a background isolate
      const projectId = 'xnvunvku';
      const dataset = 'production';
      const apiVersion = 'v2024-04-23';
      const token = 'skt21igxVK7FFAL0KgNYiznri0yObkJuTonPzJFISdhYR9c1b7myMpMw51VNnYuXMWTQTvYOg2jhK8jmDPACLOzQOFJBc9OSas6mNDcDrTmZb6kyFDUVCRA2aqxihmG6XGYXEmfqjvSdkqRxD4ChHSWGMMFsx3pLYvOQtsF6ICF2cnIlOgQo';

      final config = SanityConfig(
        projectId: projectId,
        dataset: dataset,
        apiVersion: apiVersion,
        useCdn: false,
        token: token,
        perspective: Perspective.raw,
      );
      
      final client = SanityClient(config);
      final repo = SanityRepository(client);
      
      try {
        // Perform the mutation
        await repo.togglePackingItem(id, !isPacked);
        print('Mutation successful');
        
        // Brief delay to ensure Sanity propagation and avoid race conditions
        await Future.delayed(const Duration(milliseconds: 500));
        
        // After toggle, we need to refresh the widget data
        final packingItems = await repo.fetchSeychellesPacking();
        await HomeWidget.saveWidgetData('packing_items', jsonEncode(packingItems));
        print('Widget data saved locally');
        
        // Trigger widget update
        await HomeWidget.updateWidget(
          name: 'PackingWidgetProvider',
          androidName: 'PackingWidgetProvider',
        );
        print('Widget update requested');
      } catch (e) {
        print('Background toggle failed: $e');
        // We could potentially use a local notification here to alert the user if sync fails
      }
    }
  }
}
