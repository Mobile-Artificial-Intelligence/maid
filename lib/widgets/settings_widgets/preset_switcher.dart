import 'package:flutter/material.dart';

class PresetSwitcher extends StatefulWidget {
  final TextEditingController presetController;
  final List<String> Function() getMenuStrings;
  final void Function(String) update;
  final void Function(String) set;
  final void Function() refresh;


  const PresetSwitcher({super.key, 
    required this.presetController, 
    required this.getMenuStrings, 
    required this.update,
    required this.set,
    required this.refresh,
  });

  @override
  State<PresetSwitcher> createState() => _PresetSwitcherState();
}

class _PresetSwitcherState extends State<PresetSwitcher> {
  Future<void> _switcherDialog(BuildContext context) async {    
      // Create a variable to determine if the dialog is visible
    bool isDialogVisible = true;

    // Define a function to close the dialog if it's visible
    void closeDialog() {
      if (isDialogVisible) {
        Navigator.of(context).pop();
        isDialogVisible = false; // Set the flag to false after closing the dialog
      }
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Switch Preset",
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            height: 200,
            width: 200,
            child: ListView.builder(
              itemCount: widget.getMenuStrings().length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(widget.getMenuStrings()[index]),
                  onTap: () => setState(() {
                    widget.presetController.text = widget.getMenuStrings()[index];
                    widget.set(widget.getMenuStrings()[index]);
                    closeDialog();
                    setState(() {});
                    widget.refresh();
                  }),
                );
              },
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () {
                closeDialog();
              },
              child: Text(
                "Cancel",
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ],
          actionsAlignment: MainAxisAlignment.center,
        );
      },
    ).then((_) {
      // When the dialog is dismissed, set the flag to false
      isDialogVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: GestureDetector(
        onLongPress: () async {
          await _switcherDialog(
            context
          );
          setState(() {});
        },
        child: TextField(
          cursorColor: Theme.of(context).colorScheme.secondary,
          controller: widget.presetController,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            labelText: "Preset",
          ),
          onSubmitted: (value) => setState(() {
            if (widget.getMenuStrings().contains(value)) {
              widget.set(value);
            } else if (value.isNotEmpty) {
              widget.update(widget.presetController.text);
            }
            setState(() {});
            widget.refresh();
          }),
        ),
      )
    );
  }
}

