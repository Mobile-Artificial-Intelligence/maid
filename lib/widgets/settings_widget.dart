import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maid/model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maid/ModelFilePath.dart';
import 'package:maid/lib.dart';
import 'package:maid/llama_params.dart';
import 'package:system_info_plus/system_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key, required this.model});

  final Model model;

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  Model get model => widget.model;

  String _ram = "\nCalculating...";
  Color color = Colors.black;

  void getRam() async {
    try {
      if (Platform.isWindows == false) {
        int? deviceMemory = await SystemInfoPlus.physicalMemory;
        int deviceMemoryGB = (deviceMemory ?? 0) ~/ 1024 + 1;

        setState(() {
          _ram = "${deviceMemoryGB}GB";
          if (deviceMemoryGB <= 6) {
            _ram += " (WARNING ! May not be enough)";
          } else {
            _ram += " (Should be enough)";
          }
          color = deviceMemoryGB > 6
              ? Colors.green
              : deviceMemoryGB > 4
                  ? Colors.orange
                  : Colors.red;
        });
      } else {
        setState(() {
          _ram = " Can't get RAM on Windows";
          color = Colors.red;
        });
      }
    } catch (e) {
      setState(() {
        _ram = " Can't get RAM";
        color = Colors.red;
      });
    }
  }

  void deletePreprompt() {
    setState(() {
      model.prePrompt = "";
    });
  }

  void testFileExisting() async {
    if (Platform.isIOS) {
      (await SharedPreferences.getInstance()).remove('path');
    }
    var found = await ModelFilePath.filePathExists();
    if (found) {
      setState(() {
        model.fileState = FileState.found;
      });
    } else {
      setState(() {
        model.fileState = FileState.notFound;
      });
    }
  }

  @override
  initState() {
    super.initState();
    model.initDefaultPrompts();
    getRam();

    testFileExisting();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Once you start a conversation, you cannot change the params.",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              model.paramsLlama.resetAll(setState);
            },
            child: const Text(
              "Reset All",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Wrap(
          children: [
            const Text("RAM :"),
            Text(
              _ram,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                model.openFile();
              },
              child: const Text(
                "Load Model",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            LlamaParamTextField(
              labelText: 'seed (-1 for random):',
              controller: model.paramsLlama.seedController,
              hintText: 'seed',
            ),
            LlamaParamTextField(
              labelText: 'n_threads:',
              controller: model.paramsLlama.n_threadsController,
              hintText: 'n_threads',
            ),
            LlamaParamTextField(
              labelText: 'n_predict:',
              controller: model.paramsLlama.n_predictController,
              hintText: 'n_predict',
            ),
            LlamaParamTextField(
              labelText: 'repeat_last_n:',
              controller: model.paramsLlama.repeat_last_nController,
              hintText: 'repeat_last_n',
            ),
            LlamaParamTextField(
              labelText: 'n_parts (-1 for auto):',
              controller: model.paramsLlama.n_partsController,
              hintText: 'n_parts',
            ),
            LlamaParamTextField(
              labelText: 'n_ctx:',
              controller: model.paramsLlama.n_ctxController,
              hintText: 'n_ctx',
            ),
            LlamaParamTextField(
              labelText: 'top_k:',
              controller: model.paramsLlama.top_kController,
              hintText: 'top_k',
            ),
            LlamaParamTextField(
              labelText: 'top_p:',
              controller: model.paramsLlama.top_pController,
              hintText: 'top_p',
            ),
            LlamaParamTextField(
              labelText: 'temp:',
              controller: model.paramsLlama.tempController,
              hintText: 'temp',
            ),
            LlamaParamTextField(
              labelText: 'repeat_penalty:',
              controller: model.paramsLlama.repeat_penaltyController,
              hintText: 'repeat_penalty',
            ),
            LlamaParamTextField(
              labelText: 'batch_size:',
              controller: model.paramsLlama.n_batchController,
              hintText: 'batch_size',
            ),
            LlamaParamCheckbox(
              labelText: 'memory_f16:',
              initialValue: model.paramsLlama.memory_f16,
              onChanged: (value) {
                model.paramsLlama.memory_f16 = value;
                model.paramsLlama.saveBoolToSharedPrefs('memory_f16', value);
              },
            ),
            LlamaParamCheckbox(
              labelText: 'random_prompt:',
              initialValue: model.paramsLlama.random_prompt,
              onChanged: (value) {
                model.paramsLlama.random_prompt = value;
                model.paramsLlama.saveBoolToSharedPrefs('random_prompt', value);
              },
            ),
            LlamaParamCheckbox(
              labelText: 'interactive:',
              initialValue: model.paramsLlama.interactive,
              onChanged: (value) {
                model.paramsLlama.interactive = value;
                model.paramsLlama.saveBoolToSharedPrefs('interactive', value);
              },
            ),
            LlamaParamCheckbox(
              labelText: 'interactive_start:',
              initialValue: model.paramsLlama.interactive_start,
              onChanged: (value) {
                model.paramsLlama.interactive_start = value;
                model.paramsLlama.saveBoolToSharedPrefs('interactive_start', value);
              },
            ),
            LlamaParamCheckbox(
              labelText: 'instruct (Chat4all and Alpaca):',
              initialValue: model.paramsLlama.instruct,
              onChanged: (value) {
                model.paramsLlama.instruct = value;
                model.paramsLlama.saveBoolToSharedPrefs('instruct', value);
              },
            ),
            LlamaParamCheckbox(
              labelText: 'ignore_eos:',
              initialValue: model.paramsLlama.ignore_eos,
              onChanged: (value) {
                model.paramsLlama.ignore_eos = value;
                model.paramsLlama.saveBoolToSharedPrefs('ignore_eos', value);
              },
            ),
            LlamaParamCheckbox(
              labelText: 'perplexity:',
              initialValue: model.paramsLlama.perplexity,
              onChanged: (value) {
                model.paramsLlama.perplexity = value;
                model.paramsLlama.saveBoolToSharedPrefs('perplexity', value);
              },
            ),
          ],
        ),
      ],
    );
  }
}