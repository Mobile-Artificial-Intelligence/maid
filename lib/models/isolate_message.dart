import 'dart:async';

import 'package:maid/models/generation_options.dart';

enum IsolateCode { start, stop, prompt, dispose }

class IsolateMessage {
  final IsolateCode code;
  final String? input;
  final GenerationOptions? options;
  final void Function(String)? callback;

  IsolateMessage(this.code, {this.input, this.options, this.callback});
}
