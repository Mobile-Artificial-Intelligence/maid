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
  static ReceivePort? _receivePort;

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
    _receivePort = port;

    LibraryLink link;
  }

  static void prompt(String input, GenerationOptions options,
      void Function(String) callback) async {
    if (_sendPort != null) {
      _sendPort!.send(IsolateMessage(
        IsolateCode.prompt,
        input: input,
        callback: callback,
      ));
    }

    final receivePort = ReceivePort();
    _sendPort = receivePort.sendPort;
    Isolate.spawn(_libraryIsolate, receivePort);

    _sendPort!.send(IsolateMessage(
      IsolateCode.start,
      options: options,
    ));

    _sendPort!.send(IsolateMessage(
      IsolateCode.prompt,
      input: input,
      callback: callback,
    ));
  }
}
