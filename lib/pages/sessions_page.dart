import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maid/static/logger.dart';
import 'package:maid/providers/session.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  late Map<String, dynamic> _sessions;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final loadedSessions = json.decode(prefs.getString("sessions") ?? "{}");
      _sessions.addAll(loadedSessions);
      setState(() {});
    });

    final session = context.read<Session>();
    String key = session.rootMessage;
    if (key.isEmpty) key = "Session";
    _sessions = {key: session.toMap()};
  }

  @override
  void dispose() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("sessions", json.encode(_sessions));
    });

    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
          ),
        ),
        title: const Text("Sessions"),
      ),
      body: Consumer<Session>(
        builder: (context, session, child) {
          String key = session.rootMessage;
          if (key.isEmpty) key = "Session";

          _sessions[key] = session.toMap();

          SharedPreferences.getInstance().then((prefs) {
            prefs.setString("last_session", json.encode(session.toMap()));
          });

          return Column(
            children: [
              const SizedBox(height: 20.0),
              FilledButton(
                onPressed: () {
                  if (session.isBusy) return;
                  final newSession = Session();
                  setState(() {
                    _sessions[newSession.rootMessage] = newSession.toMap();
                  });
                }, 
                child: Text(
                  "New Session",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              const SizedBox(height: 20.0),
              Divider(
                indent: 10,
                endIndent: 10,
                color: Theme.of(context).colorScheme.primary,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _sessions.length,
                  itemBuilder: (context, index) {
                    String sessionKey = _sessions.keys.elementAt(index);
                    Session sessionData = Session.fromMap(_sessions[sessionKey]);

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRect(
                        child: Dismissible(
                          key: sessionData.key,
                          dismissThresholds: const {
                            DismissDirection.endToStart: 0.25,
                            DismissDirection.startToEnd: 0.25,
                          },
                          onDismissed: (direction) {
                            if (session.isBusy) return;
                            _sessions.remove(sessionKey);
                            if (sessionKey == session.rootMessage) {
                              session.fromMap(_sessions.values.firstOrNull ?? 
                                {"message": "Session ${UniqueKey().toString()}"});
                            }
                          },
                          background: Container(
                            color: Colors.red,
                            child: const Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Icon(Icons.delete, color: Colors.white)
                              )
                            )
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: sessionKey == session.rootMessage ? 
                                     Theme.of(context).colorScheme.tertiary : 
                                     Theme.of(context).colorScheme.primary,
                              borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                            ),
                            child: ListTile(
                              title: Text(
                                sessionData.rootMessage,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              onTap: () {
                                if (session.isBusy) return;
                                session.fromMap(_sessions[sessionKey]);
                              },
                              onLongPress: () {
                                if (session.isBusy) return;
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    final TextEditingController controller = TextEditingController(text: sessionData.rootMessage);
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
                                            style: Theme.of(context).textTheme.labelLarge,
                                          ),
                                        ),
                                        FilledButton(
                                          onPressed: () {
                                            String oldName = session.rootMessage;
                                            Logger.log("Updating session $oldName ====> ${controller.text}");
                                            session.setRootMessage(controller.text);
                                            _sessions.remove(oldName);
                                            Navigator.of(context).pop();
                                            setState(() {});
                                          },
                                          child: Text(
                                            "Rename",
                                            style: Theme.of(context).textTheme.labelLarge,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            ]
          );
        },
      )
    );
  }
}
