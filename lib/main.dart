import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_widget/home_widget.dart';

import 'app/notification_service.dart';
import 'app/widget_interactivity.dart';
import 'ui/screens/seychelles_screen.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  
  // Register home_widget callback
  await HomeWidget.registerInteractivityCallback(backgroundCallback);
  
  GoogleFonts.config.allowRuntimeFetching = true;
  runApp(const ProviderScope(child: MimiApp()));
}

class MimiApp extends StatefulWidget {
  const MimiApp({super.key});

  @override
  State<MimiApp> createState() => _MimiAppState();
}

class _MimiAppState extends State<MimiApp> {
  @override
  void initState() {
    super.initState();
    _setupHomeWidgetInteractivity();
  }

  void _setupHomeWidgetInteractivity() {
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_handleWidgetClick);
    HomeWidget.widgetClicked.listen(_handleWidgetClick);
  }

  void _handleWidgetClick(Uri? uri) {
    if (uri == null) return;

    if (uri.host == 'toggle_packing' || uri.host == 'itinerary') {
      final initialTab = uri.host == 'toggle_packing' ? 1 : 2;
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => SeychellesScreen(initialTab: initialTab),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Our Love Story',
      theme: buildAppTheme(),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
