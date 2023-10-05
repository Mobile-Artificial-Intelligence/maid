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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 150,
                ),
                child: Wrap(
                  children: [
                    const Text(
                      'seed (-1 for random):',
                    ),
                    TextField(
                      controller: model.paramsLlama
                          .seedController,
                      keyboardType:
                          TextInputType.number,
                      decoration:
                          const InputDecoration(
                        hintText: 'seed',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 150,
                ),
                child: Wrap(
                  children: [
                    const Text(
                      'n_threads:',
                    ),
                    TextField(
                      controller: model.paramsLlama
                          .n_threadsController,
                      keyboardType:
                          TextInputType.number,
                      decoration:
                          const InputDecoration(
                        hintText: 'n_threads',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 150,
                ),
                child: Wrap(
                  children: [
                    const Text(
                      'n_predict:',
                    ),
                    TextField(
                      controller: model.paramsLlama
                          .n_predictController,
                      keyboardType:
                          TextInputType.number,
                      decoration:
                          const InputDecoration(
                        hintText: 'n_predict',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 150,
                ),
                child: Wrap(
                  children: [
                    const Text(
                      'repeat_last_n:',
                    ),
                    TextField(
                      controller: model.paramsLlama
                          .repeat_last_nController,
                      keyboardType:
                          TextInputType.number,
                      decoration:
                          const InputDecoration(
                        hintText: 'repeat_last_n',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 150,
                ),
                child: Wrap(
                  children: [
                    const Text(
                      'n_parts (-1 for auto):',
                    ),
                    TextField(
                      controller: model.paramsLlama
                          .n_partsController,
                      keyboardType:
                          TextInputType.number,
                      decoration:
                          const InputDecoration(
                        hintText: 'n_parts',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 150,
                ),
                child: Wrap(
                  children: [
                    const Text(
                      'n_ctx:',
                    ),
                    TextField(
                      controller: model.paramsLlama
                          .n_ctxController,
                      keyboardType:
                          TextInputType.number,
                      decoration:
                          const InputDecoration(
                        hintText: 'n_ctx',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 150,
                ),
                child: Wrap(
                  children: [
                    const Text(
                      'top_k:',
                    ),
                    TextField(
                      controller: model.paramsLlama
                          .top_kController,
                      keyboardType:
                          TextInputType.number,
                      decoration:
                          const InputDecoration(
                        hintText: 'top_k',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 150,
                ),
                child: Wrap(
                  children: [
                    const Text(
                      'top_p:',
                    ),
                    TextField(
                      controller: model.paramsLlama
                          .top_pController,
                      keyboardType:
                          TextInputType.number,
                      decoration:
                          const InputDecoration(
                        hintText: 'top_p',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 150,
                ),
                child: Wrap(
                  children: [
                    const Text(
                      'temp:',
                    ),
                    TextField(
                      controller: model.paramsLlama
                          .tempController,
                      keyboardType:
                          TextInputType.number,
                      decoration:
                          const InputDecoration(
                        hintText: 'temp',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 150,
                ),
                child: Wrap(
                  children: [
                    const Text(
                      'repeat_penalty:',
                    ),
                    TextField(
                      controller: model.paramsLlama
                          .repeat_penaltyController,
                      keyboardType:
                          TextInputType.number,
                      decoration:
                          const InputDecoration(
                        hintText:
                            'repeat_penalty',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 150,
                ),
                child: Wrap(
                  children: [
                    const Text(
                      'batch_size:',
                    ),
                    TextField(
                      controller: model.paramsLlama
                          .n_batchController,
                      keyboardType:
                          TextInputType.number,
                      decoration:
                          const InputDecoration(
                        hintText: 'batch_size',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 150,
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment:
                      WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'memory_f16:',
                    ),
                    Checkbox(
                        value: model.paramsLlama
                            .memory_f16,
                        onChanged: (value) {
                          setState(() {
                            model.paramsLlama
                                    .memory_f16 =
                                value!;
                          });
                          model.paramsLlama
                              .saveBoolToSharedPrefs(
                                  'memory_f16',
                                  value!);
                        }),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 150,
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment:
                      WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'random_prompt:',
                    ),
                    Checkbox(
                        value: model.paramsLlama
                            .random_prompt,
                        onChanged: (value) {
                          setState(() {
                            model.paramsLlama
                                    .random_prompt =
                                value!;
                          });
                          model.paramsLlama
                              .saveBoolToSharedPrefs(
                                  'random_prompt',
                                  value!);
                        }),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 150,
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment:
                      WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'interactive:',
                    ),
                    Checkbox(
                        value: model.paramsLlama
                            .interactive,
                        onChanged: (value) {
                          setState(() {
                            model.paramsLlama
                                    .interactive =
                                value!;
                          });
                          model.paramsLlama
                              .saveBoolToSharedPrefs(
                                  'interactive',
                                  value!);
                        }),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 150,
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment:
                      WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'interactive_start:',
                    ),
                    Checkbox(
                        value: model.paramsLlama
                            .interactive_start,
                        onChanged: (value) {
                          setState(() {
                            model.paramsLlama
                                    .interactive_start =
                                value!;
                          });
                          model.paramsLlama
                              .saveBoolToSharedPrefs(
                                  'interactive_start',
                                  value!);
                        }),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 150,
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment:
                      WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'instruct (Chat4all and Alpaca):',
                    ),
                    Checkbox(
                        value:
                            model.paramsLlama.instruct,
                        onChanged: (value) {
                          setState(() {
                            model.paramsLlama.instruct =
                                value!;
                          });
                          model.paramsLlama
                              .saveBoolToSharedPrefs(
                                  'instruct',
                                  value!);
                        }),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 150,
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment:
                      WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'ignore_eos:',
                    ),
                    Checkbox(
                        value: model.paramsLlama
                            .ignore_eos,
                        onChanged: (value) {
                          setState(() {
                            model.paramsLlama
                                    .ignore_eos =
                                value!;
                          });
                          model.paramsLlama
                              .saveBoolToSharedPrefs(
                                  'ignore_eos',
                                  value!);
                        }),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 150,
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment:
                      WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'perplexity:',
                    ),
                    Checkbox(
                        value: model.paramsLlama
                            .perplexity,
                        onChanged: (value) {
                          setState(() {
                            model.paramsLlama
                                    .perplexity =
                                value!;
                          });
                          model.paramsLlama
                              .saveBoolToSharedPrefs(
                                  'perplexity',
                                  value!);
                        }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}