import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:maid/classes/huggingface_model.dart';
import 'package:maid/classes/static/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class HuggingfaceSelection extends ChangeNotifier {
  HuggingfaceModel? _model;
  String? _tag;
  String? _filePath;
  int? _progress;

  HuggingfaceModel? get model => _model;

  String? get tag => _tag;

  String? get tagValue {
    if (_model == null || _tag == null) {
      return null;
    }

    return _model!.tags[_tag!];
  }

  String? get filePath => _filePath;

  int? get progress => _progress;

  Future<String> get filePathFuture async {
    if (_model == null || _tag == null) {
      Logger.log("Model or tag not selected");
      return "";
    }

    final model = _model!;
    final family = model.family;
    final series = model.series;

    final dir = await getApplicationDocumentsDirectory();
    final path = "${dir.path}/$family/$series/$_tag.gguf";

    return path;
  }

  Future<bool> get alreadyExists async {
    return File(await filePathFuture).exists();
  }

  void download() async {
    if (_model == null || _tag == null) {
      Logger.log("Model or tag not selected");
      return;
    }

    final filePath = await filePathFuture;

    if (File(filePath).existsSync()) {
      Logger.log("File already exists: $filePath");
      _filePath = filePath;
      notifyListeners();
      return;
    }

    final model = _model!;
    final repo = model.repo;
    final branch = model.branch;
    final tag = model.tags[_tag!]!;

    try {
      _filePath = filePath;
      _progress = 0;
      notifyListeners();

      await Dio().download(
        "https://huggingface.co/$repo/resolve/$branch/$tag?download=true",
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            _progress = ((received / total) * 100).ceil();
            notifyListeners();
          }
        },
      );

      Logger.log("Huggingface file downloaded to: $filePath");
      return;
    } catch (e) {
      Logger.log("Download failed: $e");
      return;
    }
  }

  set model(HuggingfaceModel? model) {
    _filePath = null;
    _progress = null;
    _model = model;
    notifyListeners();
  }

  set tag(String? tag) {
    _filePath = null;
    _progress = null;
    _tag = tag;
    notifyListeners();
  }

  void clearProgress() {
    _progress = null;
  }

  static HuggingfaceSelection of(BuildContext context) => context.read<HuggingfaceSelection>();
}