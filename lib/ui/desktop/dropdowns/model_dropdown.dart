import 'package:flutter/material.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:maid/enumerators/large_language_model_type.dart';
import 'package:maid/classes/providers/app_data.dart';
import 'package:provider/provider.dart';

class ModelDropdown extends StatefulWidget {
  const ModelDropdown({super.key});

  @override
  State<StatefulWidget> createState() => _ModelDropdownState();
}

class _ModelDropdownState extends State<ModelDropdown> {
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
      child: Consumer<AppData>(
        builder: buildDropdown
      )
    );
  }

  Widget buildDropdown(BuildContext context, AppData appData, Widget? child) {
    final session = appData.currentSession;
        
    if (canUseCache(context)) {
      return buildRow(context);
    } 
    else {
      lastModelType = session.model.type;
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
    return Consumer<AppData>(
      builder: (context, appData, child) {
        final text = appData.currentSession.model.name.isNotEmpty ? 
          appData.currentSession.model.name : 'Select Model';

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
      child: Consumer<AppData>(
        builder: (context, appData, child) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
            title: Text(modelName),
            onTap: () {
              appData.currentSession.model.name = modelName;
            },
            tileColor: appData.currentSession.model.name == modelName ? Theme.of(context).colorScheme.secondary : null,
          );
        }
      )
    );
  }
}