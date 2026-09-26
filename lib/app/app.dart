
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../services/theme_controller.dart';
import 'navigation_page.dart';
import 'theme.dart';

class HorizonteApp extends StatefulWidget {
  final ThemeController themeController;

  const HorizonteApp({super.key, required this.themeController});

  @override
  State<HorizonteApp> createState() => _HorizonteAppState();
}

class _HorizonteAppState extends State<HorizonteApp> {
  ThemeController get _themeController => widget.themeController;

  @override
  void initState() {
    super.initState();
    _themeController.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _themeController.removeListener(_onThemeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Horizonte',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeController.themeMode,
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
      home: NavigationPage(themeController: _themeController),
    );
  }
}
