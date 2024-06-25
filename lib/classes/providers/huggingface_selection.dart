import 'package:flutter/material.dart';
import 'package:maid/classes/huggingface_model.dart';
import 'package:provider/provider.dart';

class HuggingfaceSelection extends ChangeNotifier {
  HuggingfaceModel? _model;
  String? _tag;

  HuggingfaceModel? get model => _model;

  String? get tag => _tag;

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