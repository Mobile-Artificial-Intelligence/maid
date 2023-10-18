/// run.dart
import 'dart:async';
import 'dart:io';

import 'dart:ffi';
import 'dart:ffi' as ffi;
import 'dart:isolate';
import 'package:ffi/ffi.dart';

import 'package:flutter/services.dart';
import 'package:maid/model.dart';

import 'package:maid/butler.dart';

// Unimplemented
class Lib {
  static SendPort? sendPort;
  late NativeLibrary _nativeLibrary;

  // Make the default constructor private
  Lib._();

  // Private reference to the global instance
  static final Lib _instance = Lib._();

  // Public accessor to the global instance
  static Lib get instance {
    _instance._initialize();
    return _instance;
  }

  // Flag to check if the instance has been initialized
  bool _isInitialized = false;

  // Initialization logic
  void _initialize() {
    if (!_isInitialized) {
      _loadNativeLibrary();
      _isInitialized = true;
    }
  }

  void _loadNativeLibrary() {
    DynamicLibrary butlerDynamic =
        Platform.isMacOS || Platform.isIOS
            ? DynamicLibrary.process() // macos and ios
            : (DynamicLibrary.open(
                Platform.isWindows // windows
                    ? 'butler.dll'
                    : 'libbutler.so')); // android and linux

    _nativeLibrary = NativeLibrary(butlerDynamic);
  }

  static void _maidOutputBridge(Pointer<Char> output) {
    try {
      sendPort?.send(output.cast<Utf8>().toDartString());
    } catch (e) {
      print(e.toString());
    }
  }

  static butlerContinueIsolate(Map<String, dynamic> args) async {
    sendPort = args['port'] as SendPort?;
    String input = args['input'];
    ffi.Pointer<ffi.Char> text = input.trim().toNativeUtf8().cast<Char>();
    Lib.instance._nativeLibrary.butler_continue(text, Pointer.fromFunction(_maidOutputBridge));
  }


  void butlerStart(void Function(String) maidOutput) async {
    final params = calloc<butler_params>();
    params.ref.model_path = model.modelPath.toNativeUtf8().cast<Char>();
    params.ref.prompt = model.prePrompt.toNativeUtf8().cast<Char>();
    params.ref.antiprompt = model.reversePromptController.text.trim().toNativeUtf8().cast<Char>();

    _nativeLibrary.butler_start(params);

    ReceivePort receivePort = ReceivePort();
    sendPort = receivePort.sendPort;
    butlerContinue();
  
    Completer completer = Completer();
    receivePort.listen((data) {
      if (data is String) {
        maidOutput(data);
      } else if (data is SendPort) {
        completer.complete();
      }
    });
    await completer.future;
  }

  void butlerContinue() {
    String input = model.promptController.text;
    Isolate.spawn(butlerContinueIsolate, {
      'input': input,
      'port': sendPort
    });
  }

  void butlerStop() {
    _nativeLibrary.butler_stop();
  }

  void butlerExit() {
    _nativeLibrary.butler_exit();
    sendPort?.send(sendPort);
  }
}

enum FileState {
  notFound,
  found,
  opening,
}