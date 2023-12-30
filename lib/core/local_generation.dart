import 'dart:io';
import 'dart:ffi';
import 'dart:async';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:maid/models/isolate_message.dart';
import 'package:maid/models/library_link.dart';
import 'package:maid/static/generation_manager.dart';
import 'package:maid/static/logger.dart';
import 'package:maid/core/bindings.dart';
import 'package:maid/models/generation_options.dart';

class LocalGeneration {
  static SendPort? _sendPort;

  static void _maidOutputBridge(int code, Pointer<Char> buffer) {
    try {
      if (code == return_code.CONTINUE) {
        _sendPort?.send(buffer.cast<Utf8>().toDartString());
      } else if (code == return_code.STOP) {
        _sendPort?.send(code);
      }
    } catch (e) {
      Logger.log(e.toString());
    }
  }

  static void _libraryIsolate(ReceivePort port) async {
    late LibraryLink link;

    Completer completer = Completer();
    port.listen((data) {
      if (data is IsolateMessage) {
        switch (data.code) {
          case IsolateCode.start:
            link = LibraryLink(data.options!);
            break;
          case IsolateCode.stop:
            link.stop();
            break;
          case IsolateCode.prompt:
            link.prompt(data.stream!, data.input!);
            break;
          case IsolateCode.dispose:
            link.dispose();
            break;
        }
      }
    });
    await completer.future;
  }

  static void prompt(String input, GenerationOptions options,
      StreamController<String> stream) async {
    if (_sendPort != null) {
      _sendPort!.send(
          IsolateMessage(IsolateCode.prompt, input: input, stream: stream));
    }

    final receivePort = ReceivePort();
    _sendPort = receivePort.sendPort;
    Isolate.spawn(_libraryIsolate, receivePort);

    _sendPort!.send(IsolateMessage(
      IsolateCode.start,
      options: options,
    ));

    _sendPort!
        .send(IsolateMessage(IsolateCode.prompt, input: input, stream: stream));
  }
}
