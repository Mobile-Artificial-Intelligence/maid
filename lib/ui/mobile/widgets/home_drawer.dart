import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maid/static/logger.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/static/utilities.dart';
import 'package:maid/ui/mobile/pages/about_page.dart';
import 'package:maid/ui/mobile/pages/character_page.dart';
import 'package:maid/ui/mobile/pages/platform_page.dart';
import 'package:maid/ui/mobile/pages/settings_page.dart';
import 'package:maid/ui/mobile/pages/user_page.dart';
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
      Map<String, dynamic> loadedSessions = json.decode(prefs.getString("sessions") ?? "{}");
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
          child: Column(
            children: [
              const SizedBox(height: 20.0),
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
                indent: 10,
                endIndent: 10,
                color: Theme.of(context).colorScheme.primary,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: sessions.length,
                  itemBuilder: _itemBuilder
                ),
              ),
              ListTile(
                leading: Icon(Icons.account_circle,
                    color: Theme.of(context).colorScheme.onPrimary),
                title: Text('User', style: Theme.of(context).textTheme.labelLarge),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const UserPage()));
                },
              ),
              ListTile(
                leading: Icon(Icons.person,
                    color: Theme.of(context).colorScheme.onPrimary),
                title: Text('Character',
                    style: Theme.of(context).textTheme.labelLarge),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CharacterPage()));
                },
              ),
              ListTile(
                leading: Icon(Icons.account_tree_rounded,
                    color: Theme.of(context).colorScheme.onPrimary),
                title: Text(
                  'Model',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PlatformPage()));
                },
              ),
              ListTile(
                leading: Icon(Icons.settings,
                    color: Theme.of(context).colorScheme.onPrimary),
                title:
                    Text('Settings', style: Theme.of(context).textTheme.labelLarge),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsPage()));
                },
              ),
              ListTile(
                leading: Icon(Icons.info,
                    color: Theme.of(context).colorScheme.onPrimary),
                title: Text('About', style: Theme.of(context).textTheme.labelLarge),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const AboutPage()));
                },
              ),
            ]
          )
        );
      },
    );
  }

  Widget? _itemBuilder(BuildContext context, int index) {
    Key sessionKey = sessions.keys.elementAt(index);
    Session sessionData =
        Session.fromMap(sessions[sessionKey]);

    return Consumer<Session>(
      builder: (context, session, child) {
        return ListTile(
          title: Text(
            sessionData.rootMessage,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          onTap: () {
            if (session.isBusy) return;
            session.fromMap(sessions[sessionKey]);
          },
          onLongPress: () {
            if (session.isBusy) return;
            showDialog(
              context: context,
              builder: (context) {
                final TextEditingController controller =
                    TextEditingController(
                        text: sessionData.rootMessage);
                return AlertDialog(
                  title: const Text(
                    "Rename Session",
                    textAlign: TextAlign.center,
                  ),
                  content: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Enter new name",
                    ),
                  ),
                  actions: [
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Cancel",
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge,
                      ),
                    ),
                    FilledButton(
                      onPressed: () {
                        String oldName =
                            session.rootMessage;
                        Logger.log(
                            "Updating session $oldName ====> ${controller.text}");
                        session.setRootMessage(
                            controller.text);
                        sessions.remove(oldName);
                        Navigator.of(context).pop();
                        setState(() {});
                      },
                      child: Text(
                        "Rename",
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
