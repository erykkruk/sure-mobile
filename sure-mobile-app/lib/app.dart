import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/config_tools/app_router.dart';
import 'core/presentation/theme/app_colors.dart';
import 'generated/app_localizations.dart';

/// Main application widget
class SureApp extends StatefulWidget {
  const SureApp({super.key});

  @override
  State<SureApp> createState() => _SureAppState();
}

class _SureAppState extends State<SureApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    // Update colors when system theme changes
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    AppColors.init(brightness);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Initialize colors with current brightness
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    AppColors.init(brightness);

    return MaterialApp.router(
      title: 'Sure Mobile App',
      debugShowCheckedModeBanner: false,

      // Routing
      routerConfig: AppRouter.router,

      // Localization
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,

      // Theme
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.instance.primary,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.instance.primary,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
    );
  }
}
