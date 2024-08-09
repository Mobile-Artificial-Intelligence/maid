import 'package:flutter/material.dart';
import 'package:maid/classes/providers/artificial_intelligence.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:maid/enumerators/large_language_model_type.dart';
import 'package:provider/provider.dart';

class RemoteModelDropdown extends StatefulWidget {
  const RemoteModelDropdown({super.key});

  @override
  State<StatefulWidget> createState() => _RemoteModelDropdownState();
}

class _RemoteModelDropdownState extends State<RemoteModelDropdown> {
  static LargeLanguageModelType lastModelType = LargeLanguageModelType.none;
  static DateTime lastCheck = DateTime.now();
  static List<String> options = [];
  bool open = false;

  bool canUseCache(BuildContext context) {
    if (options.isEmpty && LargeLanguageModel.of(context).type != LargeLanguageModelType.llamacpp) return false;

    if (LargeLanguageModel.of(context).type != lastModelType) return false;

    if (DateTime.now().difference(lastCheck).inMinutes > 1) return false;

    return true;
  }
  
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center, 
      child: Consumer<ArtificialIntelligence>(
        builder: buildDropdown
      )
    );
  }

  Widget buildDropdown(BuildContext context, ArtificialIntelligence ai, Widget? child) { 
    if (canUseCache(context)) {
      return buildRow(context);
    } 
    else {
      lastModelType = ai.llm.type;
      lastCheck = DateTime.now();
      return buildFuture();
    }
  }

  Widget buildFuture() {
    return FutureBuilder(
      future: LargeLanguageModel.of(context).options,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          options = snapshot.data as List<String>;
          return buildRow(context);
        } else {
          return buildLoading();
        }
      }
    );
  }

  Widget buildRow(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildText(),
        PopupMenuButton(
          tooltip: 'Select Large Language Model API',
          icon: Icon(
            open ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            color: Theme.of(context).colorScheme.onSurface,
            size: 24,
          ),
          offset: const Offset(0, 40),
          itemBuilder: itemBuilder,
          onOpened: () => setState(() => open = true),
          onCanceled: () => setState(() => open = false),
          onSelected: (_) => setState(() => open = false)
        )
      ]
    );
  }

  Widget buildText() {
    return Consumer<ArtificialIntelligence>(
      builder: (context, ai, child) {
        final text = ai.llm.name.isNotEmpty ? ai.llm.name : 'Select Model';

        return Text(
          text,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold
          )
        );
      }
    );
  }

  Widget buildLoading() {
    return const SizedBox(
      width: 24,
      height: 24,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 3.0
        ),
      ),
    );
  }

  List<PopupMenuEntry<dynamic>> itemBuilder(BuildContext context) {
    List<PopupMenuEntry<dynamic>> modelOptions = options.map(
      (String modelName) => buildPopupMenuEntry(context, modelName)
    ).toList();

    return modelOptions;
  }

  PopupMenuEntry<dynamic> buildPopupMenuEntry(BuildContext context, String modelName) {
    return PopupMenuItem(
      padding: EdgeInsets.zero,
      child: Consumer<ArtificialIntelligence>(
        builder: (context, ai, child) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
            title: Text(modelName),
            onTap: () {
              ai.llm.name = modelName;
            },
            tileColor: ai.llm.name == modelName ? Theme.of(context).colorScheme.secondary : null,
          );
        }
      )
    );
  }
}