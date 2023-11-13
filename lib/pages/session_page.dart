import 'package:flutter/material.dart';
import 'package:maid/static/memory_manager.dart';

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

                return Dismissible(
                  key: ValueKey(sessions[index]),
                  onDismissed: (direction) {
                    // Remove the item from your list and refresh the UI
                    MemoryManager.removeSession(sessions[index]);
                    if (MemoryManager.getSessions().isEmpty) Navigator.of(context).pop();
                  },
                  background: Container(color: Colors.red),
                  child: ListTile(
                    title: Text(
                      sessions[index],
                      textAlign: TextAlign.center
                    ),
                    onTap: () {
                      MemoryManager.setSession(sessions[index]);
                      Navigator.of(context).pop();
                    },
                    tileColor: Theme.of(context).colorScheme.primary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                  )
                );
              },
            ),
          )
        ]
      ),
    );
  }
}
