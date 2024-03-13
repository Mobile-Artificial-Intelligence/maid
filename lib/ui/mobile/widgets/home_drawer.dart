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
  final List<Session> sessions = [];
  Key current = UniqueKey();

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final String sessionsJson = prefs.getString("sessions") ?? '[]';
    final List sessionsList = json.decode(sessionsJson);

    setState(() {
      sessions.clear();
      for (var characterMap in sessionsList) {
        sessions.add(Session.fromMap(characterMap));
      }
    });
  }

  @override
  void dispose() {
    _saveSessions();
    super.dispose();
  }

  Future<void> _saveSessions() async {
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

        if (!sessions.contains(session)) {
          sessions.insert(0, session);
        }

        SharedPreferences.getInstance().then((prefs) {
          prefs.setString("last_session", json.encode(session.toMap()));
        });

        return Drawer(
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
                        child: Text(
                          "Customize",
                          style: Theme.of(context).textTheme.labelLarge,
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
                        child: Text(
                          "Browse",
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      )
                    ]
                  ),
                  Divider(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  FilledButton(
                    onPressed: () {
                      if (session.isBusy) return;
                      setState(() {
                        final newSession = Session();
                        sessions.add(newSession);
                        session.from(newSession);
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
                      itemCount: sessions.length, 
                      itemBuilder: (context, index) {
                        return SessionTile(
                          session: sessions[index], 
                          onDelete: () {
                            if (session.isBusy) return;
                            setState(() {
                              if (sessions[index].key == session.key) {
                                session.from(sessions.firstOrNull ?? Session());
                              }
                              sessions.removeAt(index);
                            });
                          }
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
                ])));
      },
    );
  }
}
