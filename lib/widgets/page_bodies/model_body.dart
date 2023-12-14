import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maid/static/generation_manager.dart';
import 'package:maid/static/logger.dart';
import 'package:maid/providers/model.dart';
import 'package:maid/widgets/api_parameters/local_parameters.dart';
import 'package:maid/widgets/api_parameters/ollama_parameters.dart';
import 'package:maid/widgets/api_parameters/openai_parameters.dart';
import 'package:maid/widgets/dialogs.dart';
import 'package:maid/widgets/settings_widgets/api_dropdown.dart';
import 'package:maid/widgets/settings_widgets/double_button_row.dart';
import 'package:maid/widgets/settings_widgets/maid_text_field.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModelBody extends StatefulWidget {
  const ModelBody({super.key});

  @override
  State<ModelBody> createState() => _ModelBodyState();
}

class _ModelBodyState extends State<ModelBody> {
  static Map<String, dynamic> _models = {};
  late Model cachedModel;
  late TextEditingController _presetController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      _models = json.decode(prefs.getString("models") ?? "{}");
      setState(() {});
    });

    final model = context.read<Model>();
    _presetController = TextEditingController(text: model.preset);
  }

  @override
  void dispose() {
    SharedPreferences.getInstance().then((prefs) {
      _models[cachedModel.preset] = cachedModel.toMap();
      Logger.log("Model Saved: ${cachedModel.parameters["path"]}");

      prefs.setString("models", json.encode(_models));
      prefs.setString("last_model", json.encode(cachedModel.toMap()));
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Model>(
      builder: (context, model, child) {
        cachedModel = model;
        
        return Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10.0),
                  Text(
                    model.preset,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20.0),
                  FilledButton(
                    onPressed: () {
                      switcherDialog(
                        context,
                        () {
                          return _models.keys.toList();
                        },
                        (String modelName) {
                          
                          model.fromMap(_models[modelName] ?? {});
                          Logger.log("Model Set: ${model.preset}");
                          
                        },
                        (String modelName) {
                          _models.remove(modelName);
                          String? key = _models.keys.lastOrNull;

                          if (key == null) {
                            model.resetAll();
                          } else {
                            model.fromMap(_models[key]!);
                          }
                          
                        },
                        (String modelName) {
                          return model.preset == modelName;
                        },
                        () => setState(() {}), 
                        () async {
                          final prefs = await SharedPreferences.getInstance();
                          _models[model.preset] = model.toMap();
                          Logger.log("Model Saved: ${model.preset}");
                          
                          prefs.setString("models", json.encode(_models));
                          prefs.setString("last_model", model.preset);

                          GenerationManager.cleanup();

                          model.resetAll();
                          model.setPreset("New Preset");
                        }
                      );
                    },
                    child: Text(
                      "Switch Preset",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  MaidTextField(
                    headingText: "Preset Name",
                    labelText: "Preset",
                    controller: _presetController,
                    onChanged: (value) {
                      if (_models.keys.contains(value)) {
                        model.fromMap(_models[value] ?? {});
                        Logger.log("Model Set: ${model.preset}");
                      } else if (value.isNotEmpty) {
                        String oldName = model.preset;
                        Logger.log("Updating model $oldName ====> $value");
                        model.setPreset(value);
                        _models.remove(oldName);
                      }
                    },
                  ),
                  const SizedBox(height: 20.0),
                  Divider(
                    height: 20,
                    indent: 10,
                    endIndent: 10,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  DoubleButtonRow(
                    leftText: "Load Parameters",
                    leftOnPressed: () async {
                      await storageOperationDialog(
                          context, model.importModelParameters);
                      setState(() {
                        _presetController.text = model.preset;
                      });
                    },
                    rightText: "Save Parameters",
                    rightOnPressed: () async {
                      await storageOperationDialog(
                          context, model.exportModelParameters);
                    },
                  ),
                  const SizedBox(height: 15.0),
                  FilledButton(
                    onPressed: () {
                      model.resetAll();
                      setState(() {
                        _presetController.text = model.preset;
                      });
                    },
                    child: Text(
                      "Reset All",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  Divider(
                    height: 20,
                    indent: 10,
                    endIndent: 10,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const ApiDropdown(),
                  if (model.apiType == ApiType.local)
                    const LocalParameters()
                  else if (model.apiType == ApiType.ollama)
                    const OllamaParameters()
                  else if (model.apiType == ApiType.openAI)
                    const OpenAiParameters(),
                ],
              ),
            ),
            if (GenerationManager.busy)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        );
      }
    );
  }
  
}