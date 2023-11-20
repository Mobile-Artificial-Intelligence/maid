import 'package:flutter/material.dart';
import 'package:maid/static/memory_manager.dart';
import 'package:maid/static/message_manager.dart';
import 'package:maid/static/theme.dart';

class SessionsBody extends StatefulWidget {
  const SessionsBody({super.key});

  @override
  State<SessionsBody> createState() => _SessionsBodyState();
}

class _SessionsBodyState extends State<SessionsBody> {
  late String _currentSession;
  
  @override
  void initState() {
    super.initState();
    setState(() {
      _currentSession = MessageManager.root.message.isNotEmpty ? 
                        MessageManager.root.message : 
                        "Session";
    });
  }

  @override
  void dispose() {
    MemoryManager.setSession(_currentSession);
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20.0),
        FilledButton(
          onPressed: () {
            if (MessageManager.busy) return;
            final index = MemoryManager.getSessions().length;
            MemoryManager.setSession("Session $index");
            setState(() {});
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
            itemCount: MemoryManager.getSessions().length,
            itemBuilder: (context, index) {
              List<String> sessions = MemoryManager.getSessions();

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Dismissible(
                  key: ValueKey(sessions[index]),
                  onDismissed: (direction) {
                    if (MessageManager.busy) return;
                    MemoryManager.removeSession(sessions[index]);
                    if (MemoryManager.getSessions().isEmpty) {
                      setState(() {
                        _currentSession = MessageManager.root.message;
                      });
                    }
                  },
                  background: Container(color: Colors.red),
                  child: Container(
                    decoration: BoxDecoration(
                      color: sessions[index] == _currentSession ? 
                             Theme.of(context).colorScheme.tertiary : 
                             Theme.of(context).colorScheme.primary,
                      borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                    ),
                    child: ListTile(
                      title: Text(
                        sessions[index],
                        textAlign: TextAlign.center,
                        style: MaidTheme.sessionTextStyle,
                      ),
                      onTap: () {
                        if (MessageManager.busy) return;
                        setState(() {
                          _currentSession = sessions[index];
                        });
                      },
                      onLongPress: () { // Rename session Dialog
                        if (MessageManager.busy) return;
                        showDialog(
                          context: context,
                          builder: (context) {
                            final TextEditingController controller = TextEditingController(text: sessions[index]);
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
                                    MemoryManager.updateSession(controller.text);
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
              );
            },
          ),
        )
      ]
    );
  }
}
