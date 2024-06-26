import 'package:flutter/material.dart';
import 'package:maid/classes/providers/huggingface_selection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class HuggingfaceDownloadButton extends StatelessWidget {
  const HuggingfaceDownloadButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () => download(context),
      child: const Text(
        "Download"
      ),
    );
  }

  void download(BuildContext context) async {
    final huggingfaceSelection = HuggingfaceSelection.of(context);

    if (huggingfaceSelection.model == null || huggingfaceSelection.tag == null) {
      return;
    }

    final model = huggingfaceSelection.model!;
    final repo = model.repo;
    final branch = model.branch;
    final tagKey = huggingfaceSelection.tag!;
    final tag = model.tags[tagKey]!;
    final family = model.family;
    
    try {
      var dir = await getApplicationDocumentsDirectory();

      String filePath = "${dir.path}/$family/$tag";

      await Dio().download(
        "https://huggingface.co/$repo/resolve/$branch/$tag?download=true",
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print("Progress: ${(received / total * 100).toStringAsFixed(0)}%");
          }
        },
      );
      print("File downloaded to: $filePath");
    } catch (e) {
      print("Download failed: $e");
    }
  }
}