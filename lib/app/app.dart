import 'package:flutter/material.dart';

import 'navigation_page.dart';
import 'theme.dart';

class HorizonteApp extends StatelessWidget {
  const HorizonteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Horizonte',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const NavigationPage(),
    );
  }
}