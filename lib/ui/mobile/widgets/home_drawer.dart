import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/ui/mobile/pages/character/character_browser_page.dart';
import 'package:maid/ui/mobile/pages/character/character_customization_page.dart';
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
  List<Session> sessions = [];
  Key current = UniqueKey();

  @override
  void initState() {
    super.initState();
    loadSessions();
  }

  Future<void> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final String sessionsJson = prefs.getString("sessions") ?? '[]';
    final List sessionsList = json.decode(sessionsJson);

    setState(() {
      sessions.clear();
      for (final characterMap in sessionsList) {
        sessions.add(Session.fromMap(characterMap));
      }
    });
  }

  @override
  void dispose() {
    saveSessions();
    super.dispose();
  }

  Future<void> saveSessions() async {
    final prefs = await SharedPreferences.getInstance();
    sessions.removeWhere((session) => session.key == current);
    final String sessionsJson = json.encode(sessions.map((session) => session.toMap()).toList());
    await prefs.setString("sessions", sessionsJson);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (context, session, child) {
        current = session.key;

        var contains = false;

        for (var element in sessions) {
          if (element.key == current) {
            contains = true;
            break;
          }
        }

        if (!contains) {
          sessions.insert(0, session.copy());
        }

        SharedPreferences.getInstance().then((prefs) {
          prefs.setString("last_session", json.encode(session.toMap()));
        });

        return Drawer(
          backgroundColor: Theme.of(context).colorScheme.background,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20)
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 40, 10, 10),
              child: Column(children: [
                const CharacterTile(),
                const SizedBox(height: 5.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the drawer
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CharacterCustomizationPage()));
                      },
                      child: const Text(
                        "Customize"
                      ),
                    ),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the drawer
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CharacterBrowserPage()));
                      },
                      child: const Text(
                        "Browse"
                      ),
                    )
                  ]
                ),
                Divider(
                  color: Theme.of(context).colorScheme.primary,
                ),
                FilledButton(
                  onPressed: () {
                    if (!session.chat.tail.finalised) return;
                    setState(() {
                      final newSession = Session();
                      sessions.add(newSession);
                      session.from(newSession);
                    });
                  },
                  child: const Text(
                    "New Chat"
                  ),
                ),
                Divider(
                  color: Theme.of(context).colorScheme.primary,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: sessions.length, 
                    itemBuilder: (context, index) {
                      return SessionTile(
                        session: sessions[index], 
                        onDelete: () {
                          if (!session.chat.tail.finalised) return;
                          setState(() {
                            if (sessions[index].key == session.key) {
                              session.from(sessions.firstOrNull ?? Session());
                            }
                            sessions.removeAt(index);
                          });
                        },
                        onRename: (value) {
                          setState(() {
                            if (sessions[index].key == session.key) {
                              session.name = value;
                            }
                            sessions[index].name = value;
                          });
                        },
                      );
                    }
                  ),
                ),
                Divider(
                  height: 0.0,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 5.0),
                const UserTile()
              ]
            )
          )
        );
      },
    );
  }
}
