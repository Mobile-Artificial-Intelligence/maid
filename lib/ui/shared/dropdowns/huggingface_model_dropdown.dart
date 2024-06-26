import 'package:flutter/material.dart';
import 'package:maid/classes/huggingface_model.dart';
import 'package:maid/classes/providers/huggingface_selection.dart';
import 'package:provider/provider.dart';

class HuggingfaceModelDropdown extends StatefulWidget {
  const HuggingfaceModelDropdown({super.key});

  @override
  State<HuggingfaceModelDropdown> createState() => _HuggingfaceModelDropdownState();
}

class _HuggingfaceModelDropdownState extends State<HuggingfaceModelDropdown> {
  List<HuggingfaceModel> options = [];
  bool modelOpen = false;
  bool tagOpen = false;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return buildFuture();
    } 
      
    return buildRow(context);
  }

  Widget buildFuture() {
    return FutureBuilder<List<HuggingfaceModel>>(
      future: HuggingfaceModel.getAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          options = snapshot.data!;
          return buildRow(context);
        } 
        else {
          return buildLoading();
        }
      }
    );
  }

  Widget buildRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildModelRow(context),
        buildTagRow(context)
      ]
    );
  }

  Widget buildModelRow(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildModelText(),
        PopupMenuButton(
          tooltip: 'Select HuggingFace Model',
          icon: Icon(
            modelOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            color: Theme.of(context).colorScheme.onSurface,
            size: 24,
          ),
          offset: const Offset(0, 40),
          itemBuilder: modelItemBuilder,
          onOpened: () => setState(() => modelOpen = true),
          onCanceled: () => setState(() => modelOpen = false),
          onSelected: (value) => selectModel(value)
        )
      ]
    );
  }

  Widget buildModelText() {
    return Consumer<HuggingfaceSelection>(
      builder: (context, huggingfaceSelection, child) {
        String text;
        
        if (huggingfaceSelection.model != null) {
          text = huggingfaceSelection.model!.name;
        } else {
          text = 'Select Model';
        }

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

  void selectModel(HuggingfaceModel model) {
    HuggingfaceSelection.of(context).model = model;
    HuggingfaceSelection.of(context).tag = model.tags.keys.first;

    setState(() {
      modelOpen = false;
    });
  }

  Widget buildTagRow(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildTagText(),
        PopupMenuButton(
          tooltip: 'Select HuggingFace Model Tag',
          icon: Icon(
            tagOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            color: Theme.of(context).colorScheme.onSurface,
            size: 24,
          ),
          offset: const Offset(0, 40),
          itemBuilder: tagItemBuilder,
          onOpened: () => setState(() => tagOpen = true),
          onCanceled: () => setState(() => tagOpen = false),
          onSelected: (value) => selectTag(value)
        )
      ]
    );
  }

  Widget buildTagText() {
    return Consumer<HuggingfaceSelection>(
      builder: (context, huggingfaceSelection, child) {
        String text;
        
        if (huggingfaceSelection.tag != null) {
          text = huggingfaceSelection.tag!;
        } else {
          text = 'Select Tag';
        }

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

  void selectTag(String tag) {
    HuggingfaceSelection.of(context).tag = tag;

    setState(() {
      tagOpen = false;
    });
  }

  List<PopupMenuEntry<HuggingfaceModel>> modelItemBuilder(BuildContext context) {
    return options.map((HuggingfaceModel model) {
      return PopupMenuItem<HuggingfaceModel>(
        value: model,
        child: Text(model.name),
        onTap: () => selectModel(model),
      );
    }).toList();
  }

  List<PopupMenuEntry<String>> tagItemBuilder(BuildContext context) {
    return HuggingfaceSelection.of(context).model?.tags.keys.toList().map((String tag) {
      return PopupMenuItem<String>(
        value: tag,
        child: Text(tag),
        onTap: () => selectTag(tag),
      );
    }).toList() ?? [];
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
}