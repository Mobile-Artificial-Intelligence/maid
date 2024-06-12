import 'package:flutter/material.dart';
import 'package:maid/providers/app_preferences.dart';
import 'package:maid/providers/user.dart';
import 'package:maid/ui/desktop/app.dart';
import 'package:maid/ui/mobile/app.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/providers/character.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppPreferences appPreferences = await AppPreferences.last;
  User user = await User.last;
  Character character = await Character.last;
  Session session = await Session.last;

  runApp(
    MaidApp(user: user, character: character, session: session, appPreferences: appPreferences)
  );
}

class MaidApp extends StatelessWidget {
  final AppPreferences appPreferences;
  final User user;
  final Character character;
  final Session session;

  const MaidApp({super.key, required this.user, required this.character, required this.session, required this.appPreferences});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => appPreferences),
        ChangeNotifierProvider(create: (context) => user),
        ChangeNotifierProvider(create: (context) => character),
        ChangeNotifierProvider(create: (context) => session),
      ],
      child: Consumer<AppPreferences>(
        builder: (context, appPreferences, child) {
          if (appPreferences.useDesktopLayout) {
            return const DesktopApp();
          } 
          else {
            return const MobileApp();
          }
        },
      ),
    );
  }
}
