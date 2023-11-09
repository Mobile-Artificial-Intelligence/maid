import 'package:flutter/material.dart';

class MaidDropDown extends StatefulWidget {
  final TextEditingController presetController;
  final List<String> Function() getMenuStrings;
  final void Function(String) update;
  final void Function(String) set;


  const MaidDropDown({super.key, 
    required this.presetController, 
    required this.getMenuStrings, 
    required this.update,
    required this.set,
  });

  @override
  State<MaidDropDown> createState() => _MaidDropDownState();
}

class _MaidDropDownState extends State<MaidDropDown> {
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
        onSubmitted: (value) => setState(() {
          if (widget.getMenuStrings().contains(value)) {
            print("Setting preset to $value");
            widget.set(value);
          } else if (value.isNotEmpty) {
            widget.update(widget.presetController.text);
          }
          setState(() {});
        }),
      ),
    );
  }
}

