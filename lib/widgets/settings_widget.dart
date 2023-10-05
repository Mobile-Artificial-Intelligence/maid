import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maid/ModelFilePath.dart';
import 'package:maid/lib.dart';
import 'package:maid/llama_params.dart';
import 'package:system_info_plus/system_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key, required this.paramsLlama});

  final ParamsLlama paramsLlama;

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  ParamsLlama get paramsLlama => widget.paramsLlama;

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
              paramsLlama.resetAll(setState);
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
            //ParamsLlama(),
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
                      controller: paramsLlama
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
                      controller: paramsLlama
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
                      controller: paramsLlama
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
                      controller: paramsLlama
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
                      controller: paramsLlama
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
                      controller: paramsLlama
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
                      controller: paramsLlama
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
                      controller: paramsLlama
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
                      controller: paramsLlama
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
                      controller: paramsLlama
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
                      controller: paramsLlama
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
                        value: paramsLlama
                            .memory_f16,
                        onChanged: (value) {
                          setState(() {
                            paramsLlama
                                    .memory_f16 =
                                value!;
                          });
                          paramsLlama
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
                        value: paramsLlama
                            .random_prompt,
                        onChanged: (value) {
                          setState(() {
                            paramsLlama
                                    .random_prompt =
                                value!;
                          });
                          paramsLlama
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
                        value: paramsLlama
                            .interactive,
                        onChanged: (value) {
                          setState(() {
                            paramsLlama
                                    .interactive =
                                value!;
                          });
                          paramsLlama
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
                        value: paramsLlama
                            .interactive_start,
                        onChanged: (value) {
                          setState(() {
                            paramsLlama
                                    .interactive_start =
                                value!;
                          });
                          paramsLlama
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
                            paramsLlama.instruct,
                        onChanged: (value) {
                          setState(() {
                            paramsLlama.instruct =
                                value!;
                          });
                          paramsLlama
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
                        value: paramsLlama
                            .ignore_eos,
                        onChanged: (value) {
                          setState(() {
                            paramsLlama
                                    .ignore_eos =
                                value!;
                          });
                          paramsLlama
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
                        value: paramsLlama
                            .perplexity,
                        onChanged: (value) {
                          setState(() {
                            paramsLlama
                                    .perplexity =
                                value!;
                          });
                          paramsLlama
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