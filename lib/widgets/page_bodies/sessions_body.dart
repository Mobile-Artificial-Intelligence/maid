import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maid/static/generation_manager.dart';
import 'package:maid/static/logger.dart';
import 'package:maid/providers/session.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionsBody extends StatefulWidget {
  const SessionsBody({super.key});

  @override
  State<SessionsBody> createState() => _SessionsBodyState();
}

class _SessionsBodyState extends State<SessionsBody> {
  static Map<String, dynamic> _sessions = {};
  late Session cachedSession;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      _sessions = json.decode(prefs.getString("sessions") ?? "{}");
      setState(() {});
    });
  }

  @override
  void dispose() {
    SharedPreferences.getInstance().then((prefs) {
      String key = cachedSession.rootMessage;
      if (key.isEmpty) key = "Session";

      _sessions[key] = cachedSession.toMap();
      Logger.log("Session Saved: $key");

      prefs.setString("sessions", json.encode(_sessions));
    });
    GenerationManager.cleanup();

    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (context, session, child) {
        cachedSession = session;
        
        return Column(
          children: [
            const SizedBox(height: 20.0),
            FilledButton(
              onPressed: () {
                if (GenerationManager.busy) return;
                session.newSession();
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
                  Session sessionData = Session();
                  String sessionKey = _sessions.keys.elementAt(index);
                  sessionData.fromMap(_sessions[sessionKey]);

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
                          if (GenerationManager.busy) return;
                          _sessions.remove(sessionKey);
                          if (sessionKey == session.rootMessage) {
                            session.fromMap(_sessions.values.firstOrNull ?? {});
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
                              if (GenerationManager.busy) return;
                              session.fromMap(_sessions[sessionKey]);
                              setState(() {});
                            },
                            onLongPress: () {
                              if (GenerationManager.busy) return;
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
    );
  }
}
