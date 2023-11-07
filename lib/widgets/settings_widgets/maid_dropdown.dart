import 'package:flutter/material.dart';
import 'package:maid/utilities/memory_manager.dart';
import 'package:maid/widgets/settings_widgets/maid_text_field.dart';

class MaidDropDown extends StatefulWidget {
  final TextEditingController presetController = TextEditingController();
  final String initialSelection;
  final List<DropdownMenuEntry<String>> dropdownMenuEntries;
  final Future<void> Function(String) update;
  final Future<void> Function(String) set;


  MaidDropDown({super.key, 
    required this.initialSelection, 
    required this.dropdownMenuEntries, 
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

  Future<void> _textFieldDialog(BuildContext context, String title, String labelText, TextEditingController controller) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: MaidTextField(
            labelText: labelText,
            controller: controller,
            multiline: false,
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
                memoryManager.save();
                Navigator.of(context).pop();
              },
              child: Text(
                "Save",
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        await _textFieldDialog(
          context, 
          "Rename Preset", 
          widget.presetController.text, 
          widget.presetController
        );
        setState(() {});
      },
      child: DropdownMenu<String>(
        width: 250.0,
        initialSelection: widget.initialSelection,
        controller: widget.presetController,
        dropdownMenuEntries: widget.dropdownMenuEntries,
        onSelected: (value) => setState(() async {
          if (value == null) {
            await widget.update(widget.presetController.text);
          } else {
            await widget.set(value);
          }
          setState(() {});
        }),
      ),
    );
  }
}

