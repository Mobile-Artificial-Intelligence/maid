import 'package:flutter/material.dart';
import 'package:maid/classes/providers/app_preferences.dart';
import 'package:maid/classes/providers/desktop_navigator.dart';
import 'package:maid/classes/static/themes.dart';
import 'package:maid/ui/desktop/pages/home_page.dart';
import 'package:maid/ui/shared/pages/about_page.dart';
import 'package:provider/provider.dart';

class DesktopApp extends StatelessWidget {
  const DesktopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppPreferences>(
      builder: (context, appPreferences, child) {
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
      },
    );
  }
}