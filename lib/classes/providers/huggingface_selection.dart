import 'package:flutter/material.dart';
import 'package:maid/classes/huggingface_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class HuggingfaceSelection extends ChangeNotifier {
  HuggingfaceModel? _model;
  String? _tag;

  HuggingfaceModel? get model => _model;

  String? get tag => _tag;

  Future<String> get filePath async {
    if (_model == null || _tag == null) {
      return Future.error("Model or tag not selected");
    }

    final family = _model!.family;
    final series = _model!.series;

    try {
      var dir = await getApplicationDocumentsDirectory();

      return "${dir.path}/$family/$series/$_tag.gguf";
    } catch (e) {
      return Future.error("Download failed: $e");
    }
  }

  set model(HuggingfaceModel? model) {
    _model = model;
    notifyListeners();
  }

  set tag(String? tag) {
    _tag = tag;
    notifyListeners();
  }

  static HuggingfaceSelection of(BuildContext context) => context.read<HuggingfaceSelection>();
}