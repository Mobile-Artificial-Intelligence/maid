import 'dart:io';
import 'dart:ffi';
import 'dart:async';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
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

  static _libraryIsolate(SendPort port) async {
    _sendPort = port;
  }
}
