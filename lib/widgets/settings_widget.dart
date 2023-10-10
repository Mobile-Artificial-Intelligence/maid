import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maid/model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maid/ModelFilePath.dart';
import 'package:maid/lib.dart';
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
      model.prePromptController.text = "";
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
    getRam();

    testFileExisting();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Settings'),
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
          Row(
            children: [
              const Text("RAM: "),
              Expanded(
                child: Text(
                  _ram,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              model.resetAll(setState);
            },
            child: const Text(
              "Reset All",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: Text('PrePrompt'),
            subtitle: TextField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: model.prePromptController,
              decoration: InputDecoration(
                hintText: 'PrePrompt',
              ),
            ),
          ),
          llamaParamSwitch(
            'memory_f16:', model.memory_f16, 'memory_f16'),
          llamaParamSwitch(
            'random_prompt:', model.random_prompt, 'random_prompt'),
          llamaParamSwitch(
            'interactive:', model.interactive, 'interactive'),
          llamaParamSwitch(
            'interactive_start:', model.interactive_start, 'interactive_start'),
          llamaParamSwitch(
            'instruct (Chat4all and Alpaca):', model.instruct, 'instruct'),
          llamaParamSwitch(
            'ignore_eos:', model.ignore_eos, 'ignore_eos'),
          llamaParamSwitch(
            'perplexity:', model.perplexity, 'perplexity'),
          llamaParamTextField(
            'seed (-1 for random):', model.seedController, 'seed'),
          llamaParamTextField(
            'n_threads:', model.n_threadsController, 'n_threads'),
          llamaParamTextField(
            'n_predict:', model.n_predictController, 'n_predict'),
          llamaParamTextField(
            'repeat_last_n:', model.repeat_last_nController, 'repeat_last_n'),
          llamaParamTextField(
            'n_parts (-1 for auto):', model.n_partsController, 'n_parts'),
          llamaParamTextField(
            'n_ctx:', model.n_ctxController, 'n_ctx'),
          llamaParamTextField(
            'top_k:', model.top_kController, 'top_k'),
          llamaParamTextField(
            'top_p:', model.top_pController, 'top_p'),
          llamaParamTextField(
            'temp:', model.tempController, 'temp'),
          llamaParamTextField(
            'repeat_penalty:', model.repeat_penaltyController, 'repeat_penalty'),
          llamaParamTextField(
            'batch_size:', model.n_batchController, 'batch_size'),
        ],
      ),
    );
  }

  Widget llamaParamTextField(String labelText, TextEditingController controller, String hintText) {
    return ListTile(
      title: Text(labelText),
      subtitle: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
        ),
      ),
    );
  }

  Widget llamaParamSwitch(String title, bool initialValue, String key) {
    return SwitchListTile(
      title: Text(title),
      value: initialValue,
      onChanged: (value) {
        setState(() {
          switch (key) {
            case 'memory_f16':
              model.memory_f16 = value;
              break;
            case 'random_prompt':
              model.random_prompt = value;
              break;
            case 'interactive':
              model.interactive = value;
              break;
            case 'interactive_start':
              model.interactive_start = value;
              break;
            case 'instruct':
              model.instruct = value;
              break;
            case 'ignore_eos':
              model.ignore_eos = value;
              break;
            case 'perplexity':
              model.perplexity = value;
              break;
            default:
              break;
          }
          model.saveBoolToSharedPrefs(key, value);
        });
      },
    );
  }
}

