import 'package:flutter/material.dart';
import 'package:maid/static/memory_manager.dart';
import 'package:maid/static/message_manager.dart';

class SessionPage extends StatefulWidget {
  const SessionPage({super.key});

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
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
        title: const Text('Sessions'),
      ),
      body: Column(
        children: [
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
                      if (MemoryManager.getSessions().isEmpty) Navigator.of(context).pop();
                    },
                    background: Container(color: Colors.red),
                    child: Container(
                      decoration: BoxDecoration(
                        color: MemoryManager.isCurrentSession(sessions[index]) ? 
                               Theme.of(context).colorScheme.tertiary : 
                               Theme.of(context).colorScheme.primary,
                        borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                      ),
                      child: ListTile(
                        title: Text(
                          sessions[index],
                          textAlign: TextAlign.center
                        ),
                        onTap: () {
                          MemoryManager.setSession(sessions[index]);
                          Navigator.of(context).pop();
                        },
                        onLongPress: () { // Rename session Dialog
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
      ),
    );
  }
}
