import 'package:flutter/material.dart';
import 'package:maid/classes/providers/app_preferences.dart';
import 'package:maid/classes/providers/desktop_navigator.dart';
import 'package:maid/classes/static/themes.dart';
import 'package:maid/ui/desktop/pages/home_page.dart';
import 'package:maid/ui/shared/pages/about_page.dart';
import 'package:provider/provider.dart';

/// The [DesktopApp] class represents the main application widget for the desktop platforms.
/// It is a stateless widget that builds the user interface based on the consumed [AppPreferences].
class DesktopApp extends StatelessWidget {
  const DesktopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppPreferences>(
      builder: appBuilder
    );
  }

  /// Builds the root widget for the Maid desktop app.
  /// 
  /// This function takes in the [context], [appPreferences], and [child] parameters
  /// and returns a [MaterialApp] widget that serves as the root of the app.
  /// The [MaterialApp] widget is configured with various properties such as the app title,
  /// theme, initial route, and route mappings.
  /// The [home] property is set to [DesktopHomePage], which serves as the default landing page.
  Widget appBuilder(BuildContext context, AppPreferences appPreferences, Widget? child) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Maid',
      theme: Themes.lightTheme(),
      darkTheme: Themes.darkTheme(),
      themeMode: appPreferences.themeMode,
      initialRoute: '/',
      routes: {
        '/about': (context) => const AboutPage(),
      },
      home: ChangeNotifierProvider(
        create: (context) => DesktopNavigator(),
        child: const DesktopHomePage()
      )
    );
  }
}