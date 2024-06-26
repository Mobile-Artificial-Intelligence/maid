import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maid/classes/providers/huggingface_selection.dart';
import 'package:maid/classes/static/logger.dart';
import 'package:dio/dio.dart';

class HuggingfaceDownloadButton extends StatelessWidget {
  const HuggingfaceDownloadButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () => download(HuggingfaceSelection.of(context)),
      child: const Text(
        "Download"
      ),
    );
  }

  void download(HuggingfaceSelection huggingfaceSelection) async {
    if (huggingfaceSelection.model == null || huggingfaceSelection.tag == null) {
      Logger.log("Model or tag not selected");
      return;
    }

    final filePath = await huggingfaceSelection.filePath;

    if (File(filePath).existsSync()) {
      Logger.log("File already exists: $filePath");
      return;
    }

    final model = huggingfaceSelection.model!;
    final repo = model.repo;
    final branch = model.branch;
    final tagKey = huggingfaceSelection.tag!;
    final tag = model.tags[tagKey]!;
    
    try {
      await Dio().download(
        "https://huggingface.co/$repo/resolve/$branch/$tag?download=true",
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print("Progress: ${(received / total * 100).toStringAsFixed(0)}%");
          }
        },
      );
      Logger.log("File downloaded to: $filePath");
    } catch (e) {
      Logger.log("Download failed: $e");
    }
  }
}