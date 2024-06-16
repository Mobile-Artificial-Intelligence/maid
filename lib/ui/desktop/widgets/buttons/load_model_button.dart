import 'package:flutter/material.dart';
import 'package:maid/classes/llama_cpp_model.dart';
import 'package:maid/providers/app_data.dart';
import 'package:provider/provider.dart';

class LoadModelButton extends StatelessWidget {
  const LoadModelButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.tertiary,
      borderRadius: BorderRadius.circular(10),
      child: buildInkWell(context)
    );
  }

  Widget buildInkWell(BuildContext context) {
    return InkWell(
      onTap: () {
        LlamaCppModel.of(context).loadModel();
      },
      borderRadius: BorderRadius.circular(10),
      child: buildPadding()
    );
  }

  Widget buildPadding() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: buildConsumer()
    );
  }

  Widget buildConsumer() {
    return Consumer<AppData>(
      builder: rowBuilder
    );
  }

  Widget rowBuilder(BuildContext context, AppData appData, Widget? child) {
    final modelName = appData.currentSession.model.name;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("< < <"),
        Expanded(
          child: Text(
            modelName.isNotEmpty ? modelName : "Load Model",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
            ),
          ),
        ),
        const Text("> > >"),
      ],
    );
  }
}