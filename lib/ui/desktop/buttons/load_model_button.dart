import 'package:flutter/material.dart';
import 'package:maid/classes/providers/huggingface_selection.dart';
import 'package:maid/classes/providers/large_language_models/llama_cpp_model.dart';
import 'package:maid/classes/providers/app_data.dart';
import 'package:provider/provider.dart';

class LoadModelButton extends StatelessWidget {
  const LoadModelButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HuggingfaceSelection>(
      builder: (context, huggingfaceSelection, child) {
        final progress = huggingfaceSelection.progress;

        if (progress == null) {
          return buildButton(context);
        }

        if (progress >= 100) {
          LlamaCppModel.of(context).uri = huggingfaceSelection.filePath!;
          LlamaCppModel.of(context).name = huggingfaceSelection.tagValue!;
          huggingfaceSelection.clearProgress();
          return buildButton(context);
        }

        return buildLoading(context);
      },
    );
  }

  Widget buildLoading(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceDim,
      borderRadius: BorderRadius.circular(10),
      child: buildLoadingBar(context)
    );
  }

  Widget buildLoadingBar(BuildContext context) {
    final progress = HuggingfaceSelection.of(context).progress!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (progress > 0)
        Expanded(
          flex: progress,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
        ),
        if (progress < 100)
        Spacer(flex: 100 - progress),
      ],
    );
  }

  Widget buildButton(BuildContext context) {
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

    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 14,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "< < <",
          style: textStyle,
        ),
        Expanded(
          child: Text(
            modelName.isNotEmpty ? modelName : "Load Model",
            textAlign: TextAlign.center,
            style: textStyle,
          ),
        ),
        const Text(
          "> > >",
          style: textStyle
        ),
      ],
    );
  }
}