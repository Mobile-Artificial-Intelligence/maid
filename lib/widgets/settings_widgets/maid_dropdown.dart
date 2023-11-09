import 'package:flutter/material.dart';

class MaidDropDown extends StatefulWidget {
  final TextEditingController presetController = TextEditingController();
  final String initialSelection;
  final List<String> Function() getMenuStrings;
  final Future<void> Function(String) update;
  final Future<void> Function(String) set;


  MaidDropDown({super.key, 
    required this.initialSelection, 
    required this.getMenuStrings, 
    required this.update,
    required this.set,
  });

  @override
  State<MaidDropDown> createState() => _MaidDropDownState();
}

class _MaidDropDownState extends State<MaidDropDown> {
  @override
  void initState() {
    super.initState();
    widget.presetController.text = widget.initialSelection;
  }

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
                  onTap: () async {
                    widget.presetController.text = widget.getMenuStrings()[index];
                    await widget.set(widget.getMenuStrings()[index]);
                    closeDialog();
                  },
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
    return GestureDetector(
      onLongPress: () async {
        await _switcherDialog(
          context
        );
        setState(() {});
      },
      child: TextField(
        cursorColor: Theme.of(context).colorScheme.secondary,
        controller: widget.presetController,
        decoration: const InputDecoration(
          labelText: "Preset",
        ),
        onSubmitted: (value) async {
          if (widget.getMenuStrings().contains(value)) {
            print("Setting preset to $value");
            await widget.set(value);
          } else {
            await widget.update(widget.presetController.text);
          }
        },
      ),
    );
  }
}

