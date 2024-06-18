import 'package:flutter/material.dart';

class SwitchContainer extends StatefulWidget {
  final String title;
  final bool initialValue;
  final void Function(bool) onChanged;

  const SwitchContainer({super.key, required this.title, required this.onChanged, this.initialValue = false});

  @override
  State<SwitchContainer> createState() => _SwitchContainerState();
}

class _SwitchContainerState extends State<SwitchContainer> {
  bool active = false;

  @override
  void initState() {
    super.initState();
    active = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.3,
      ),
      child: Column(
        children: [
          Text(widget.title),
          const SizedBox(height: 5.0),
          Switch(
            value: active,
            onChanged: (value) => setState(() {
              active = value;
              widget.onChanged(value);
            }),
          )
        ],
      ),
    );
  }
} 