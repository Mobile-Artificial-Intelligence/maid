import 'package:flutter/material.dart';

class ToggleableTextFieldListTile extends StatefulWidget {
  final String headingText;
  final String labelText;
  final String? initialValue;
  final TextEditingController? controller;
  final bool multiline;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;
  final void Function(bool)? onSwitchChanged; // Callback for switch change
  final bool initialSwitchState; // Expose the initial state of the switch

  const ToggleableTextFieldListTile({super.key,
    required this.headingText,
    required this.labelText,
    this.initialValue,
    this.controller,
    this.multiline = false,
    this.onSubmitted,
    this.onChanged,
    this.onSwitchChanged,
    this.initialSwitchState = true, // Default to true if not provided
  });

  @override
  _ToggleableTextFieldListTileState createState() => _ToggleableTextFieldListTileState();
}

class _ToggleableTextFieldListTileState extends State<ToggleableTextFieldListTile> {
  late TextEditingController _controller;
  late bool _isTextFieldEnabled; // Changed to late initialization

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _isTextFieldEnabled = widget.initialSwitchState; // Initialize with the provided initial state
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: Text(widget.headingText),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              keyboardType: widget.multiline ? TextInputType.multiline : TextInputType.text,
              maxLines: widget.multiline ? null : 1,
              cursorColor: Theme.of(context).colorScheme.secondary,
              controller: _controller,
              decoration: InputDecoration(
                labelText: widget.labelText,
              ),
              onSubmitted: widget.onSubmitted,
              onChanged: widget.onChanged,
              enabled: _isTextFieldEnabled, // Use _isTextFieldEnabled to enable/disable the TextField
            ),
          ),
          const SizedBox(width: 10.0),
          Switch(
            value: _isTextFieldEnabled,
            onChanged: (value) {
              setState(() {
                _isTextFieldEnabled = value;
              });
              if (widget.onSwitchChanged != null) {
                widget.onSwitchChanged!(value);
              }
            },
          ),
        ],
      ),
    );
  }
}
