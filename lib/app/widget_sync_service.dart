import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import '../core/constants/app_config.dart';
import '../data/sanity_repository.dart';

class WidgetSyncService {
  static Future<void> syncAll(WidgetRef ref) async {
    // 1. Us Together
    final startDate = AppConfig.relationshipStart;
    final days = DateTime.now().difference(startDate).inDays;
    await HomeWidget.saveWidgetData('us_days', days.toString());
    await HomeWidget.updateWidget(
      name: 'UsWidgetProvider',
      androidName: 'UsWidgetProvider',
    );

    // 2. Paradise Countdown
    final now = DateTime.now();
    final countdown = AppConfig.seychellesFlight.difference(now).inDays;
    await HomeWidget.saveWidgetData(
      'countdown_days',
      countdown.isNegative ? '0' : countdown.toString(),
    );
    await HomeWidget.updateWidget(
      name: 'CountdownWidgetProvider',
      androidName: 'CountdownWidgetProvider',
    );

    // 3. Packing List
    final packingData = ref.read(seychellesPackingProvider);
    packingData.whenData((items) async {
      await HomeWidget.saveWidgetData('packing_items', jsonEncode(items));
      await HomeWidget.updateWidget(
        name: 'PackingWidgetProvider',
        androidName: 'PackingWidgetProvider',
      );
    });

    // 4. Itinerary
    final itineraryData = ref.read(seychellesItineraryProvider);
    itineraryData.whenData((items) async {
      await HomeWidget.saveWidgetData('itinerary_items', jsonEncode(items));
      await HomeWidget.updateWidget(
        name: 'ItineraryWidgetProvider',
        androidName: 'ItineraryWidgetProvider',
      );
    });

    // 5. Memory Lane
    final imagesData = ref.read(sharedImagesProvider);
    imagesData.whenData((images) async {
      if (images.isNotEmpty) {
        // Rotate memory (pick one or use a counter)
        final index = (DateTime.now().hour) % images.length;
        final memory = images[index];
        await HomeWidget.saveWidgetData(
          'memory_caption',
          memory['caption'] ?? 'Memory Lane',
        );
        // home_widget can also handle network images if we download them to local file
        // For now, let's just save the caption.
        // Real image syncing requires downloading the file to local storage.

        await HomeWidget.updateWidget(
          name: 'MemoryWidgetProvider',
          androidName: 'MemoryWidgetProvider',
        );
      }
    });
  }
}
