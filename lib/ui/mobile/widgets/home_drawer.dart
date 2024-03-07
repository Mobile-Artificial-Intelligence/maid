import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/static/utilities.dart';
import 'package:maid/ui/mobile/widgets/tiles/character_tile.dart';
import 'package:maid/ui/mobile/widgets/tiles/session_tile.dart';
import 'package:maid/ui/mobile/widgets/tiles/user_tile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  final Map<Key, dynamic> sessions = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> loadedSessions =
          json.decode(prefs.getString("sessions") ?? "{}");
      Map<Key, dynamic> keyedSessions = loadedSessions.map((key, value) {
        final valueKey = Utilities.stringToKey(key);
        return MapEntry(valueKey, value);
      });
      sessions.addAll(keyedSessions);
      setState(() {});
    });
  }

  @override
  void dispose() {
    SharedPreferences.getInstance().then((prefs) {
      Map<String, dynamic> encodableSessions = sessions.map((key, value) {
        final stringKey = Utilities.keyToString(key);
        return MapEntry(stringKey, value);
      });
      prefs.setString("sessions", json.encode(encodableSessions));
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (context, session, child) {
        sessions[session.key] = session.toMap();

        SharedPreferences.getInstance().then((prefs) {
          prefs.setString("last_session", json.encode(session.toMap()));
        });

        return Drawer(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
                child: Column(children: [
                  const CharacterTile(),
                  Divider(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  FilledButton(
                    onPressed: () {
                      if (session.isBusy) return;
                      final newSession = Session();
                      setState(() {
                        sessions[newSession.key] = newSession.toMap();
                      });
                    },
                    child: Text(
                      "New Chat",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  Divider(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: sessions.length, itemBuilder: _itemBuilder),
                  ),
                  //ListTile(
                  //  leading: Icon(Icons.account_circle,
                  //      color: Theme.of(context).colorScheme.onPrimary),
                  //  title: Text('User', style: Theme.of(context).textTheme.labelLarge),
                  //  onTap: () {
                  //    Navigator.pop(context); // Close the drawer
                  //    Navigator.push(context,
                  //        MaterialPageRoute(builder: (context) => const UserPage()));
                  //  },
                  //),
                  //ListTile(
                  //  leading: Icon(Icons.person,
                  //      color: Theme.of(context).colorScheme.onPrimary),
                  //  title: Text('Character',
                  //      style: Theme.of(context).textTheme.labelLarge),
                  //  onTap: () {
                  //    Navigator.pop(context); // Close the drawer
                  //    Navigator.push(
                  //        context,
                  //        MaterialPageRoute(
                  //            builder: (context) => const CharacterPage()));
                  //  },
                  //),
                  //ListTile(
                  //  leading: Icon(Icons.settings,
                  //      color: Theme.of(context).colorScheme.onPrimary),
                  //  title:
                  //      Text('Settings', style: Theme.of(context).textTheme.labelLarge),
                  //  onTap: () {
                  //    Navigator.pop(context); // Close the drawer
                  //    Navigator.push(
                  //        context,
                  //        MaterialPageRoute(
                  //            builder: (context) => const SettingsPage()));
                  //  },
                  //),
                  //ListTile(
                  //  leading: Icon(Icons.info,
                  //      color: Theme.of(context).colorScheme.onPrimary),
                  //  title: Text('About', style: Theme.of(context).textTheme.labelLarge),
                  //  onTap: () {
                  //    Navigator.pop(context); // Close the drawer
                  //    Navigator.push(context,
                  //        MaterialPageRoute(builder: (context) => const AboutPage()));
                  //  },
                  //),
                  Divider(
                    height: 0.0,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const UserTile()
                ])));
      },
    );
  }

  Widget? _itemBuilder(BuildContext context, int index) {
    Key sessionKey = sessions.keys.elementAt(index);
    Session sessionData = Session.fromMap(sessions[sessionKey]);

    return SessionTile(session: sessionData, onDelete: deleteSession);
  }

  void deleteSession(Key key) {
    final session = context.read<Session>();

    if (session.isBusy) return;
    sessions.remove(key);
    if (key == session.key) {
      session.fromMap(sessions.values.firstOrNull ?? {"message": "New Chat"});
    }
  }
}
