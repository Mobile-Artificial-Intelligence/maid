/// run.dart
import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'dart:ffi';
import 'dart:ffi' as ffi;
import 'dart:isolate';
import 'dart:math';
import 'package:ffi/ffi.dart';
import 'package:file_picker/file_picker.dart';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sherpa/ModelFilePath.dart';

import 'package:sherpa/generated_bindings_llamasherpa.dart';
import 'package:sherpa/main.dart';

// import 'package:sherpa/generated_bindings.dart';
// import 'package:sherpa/llama_bindings.dart';

//declaration of functions
typedef ChatLaunch = Int Function(Int, Int);
typedef ChatLaunchDart = int Function(int, int);

typedef Ggml_time_init = Void Function();
typedef Ggml_time_initDart = void Function();
typedef _wrappedPrint_C = Void Function(Pointer<Char> a);

class CreationContextError {
  int code;
  CreationContextError(this.code);

  @override
  String toString() {
    switch (code) {
      case 1:
        return 'failed to open file';
      case 2:
        return 'invalid model file (too old, regenerate your model files!)';
      case 3:
        return 'invalid model file (bad magic)';
      case 4:
        return 'invalid model file  (unsupported format version';
      case 6:
        return 'invalid model file  (bad f16 value )';
      case 7:
        return 'ggml_init() failed';
      case 8:
        return 'unknown tensor in model file';
      case 9:
      case 10:
      case 15:
      case 16:
        return 'tensor has wrong size in model file';
      case 11:
      case 12:
      case 13:
        return 'tensor  has wrong shape in model';
      case 14:
        return 'unknown ftype %d in model file';
      default:
        return 'unknown error';
    }
  }
}

class Vector<T extends NativeType> {
  Pointer<T> pointer;
  int length;

  Vector(this.pointer, this.length);

  void clear() {
    malloc.free(pointer);
    length = 0;
  }
}

extension VectorIntExtension on Vector<Int> {
  void fillWithValue(int value) {
    for (var i = 0; i < length; i++) {
      pointer[i] = value;
    }
  }

  Pointer<Int> begin() {
    return pointer.elementAt(0);
  }

  Pointer<Int> erase(int index) {
    var newPointer = malloc.allocate<Int>(sizeOf<Int>() * (length - 1));
    for (var i = 0; i < index; i++) {
      newPointer[i] = pointer[i];
    }
    for (var i = index + 1; i < length; i++) {
      newPointer[i - 1] = pointer[i];
    }
    // malloc.free(pointer);
    pointer = newPointer;
    length--;
    return pointer;
  }

  void push_back(int value) {
    var newPointer = malloc.allocate<Int>(sizeOf<Int>() * (length + 1));
    for (var i = 0; i < length; i++) {
      newPointer[i] = pointer[i];
    }
    newPointer[length] = value;
    // malloc.free(pointer);
    pointer = newPointer;
    length++;
  }

  void insertVectorAtEnd(Vector<Int> vector) {
    var newPointer =
        malloc.allocate<Int>(sizeOf<Int>() * (length + vector.length));
    for (var i = 0; i < length; i++) {
      newPointer[i] = pointer[i];
    }
    for (var i = 0; i < vector.length; i++) {
      newPointer[length + i] = vector.pointer[i];
    }
    // malloc.free(pointer);
    pointer = newPointer;
    length += vector.length;
  }

  int back() {
    return pointer[length - 1];
  }
}

class Lib {
  Isolate? _isolate;

  static bool stopGeneration = false;

  Lib();

  Pointer<Pointer<Char>> strListToPointer(List<String> strings) {
    List<Pointer<Char>> utf8PointerList =
        strings.map((str) => str.toNativeUtf8().cast<Char>()).toList();

    final Pointer<Pointer<Char>> pointerPointer =
        malloc.allocate(sizeOf<Pointer<Char>>() * strings.length);

    strings.asMap().forEach((index, utf) {
      pointerPointer[index] = utf8PointerList[index];
    });

    return pointerPointer;
  }

//   std::vector<llama_token> llama_tokenize(struct llama_context * ctx, const  gptParams.ref. & text,  gptParams.ref. add_bos) {
//     // initialize to prompt numer of chars, since n_tokens <= n_prompt_chars
//     std::vector<llama_token> res(text.size() + (int)add_bos);
//     int n = llama_tokenize(ctx, text.c_str(), res.data(), res.size(), add_bos);
//     assert(n >= 0);
//     res.resize(n);

//     return res;
// }

  static parserIsolateFunction(
    SendPort mainSendPort,
  ) async {
    ReceivePort isolateReceivePort = ReceivePort();
    SendPort isolateSendPort = isolateReceivePort.sendPort;
    mainSendPort.send(isolateSendPort);
    var completer = Completer<ParsingDemand>();
    try {
      isolateReceivePort.listen((message) async {
        if (message is MessageNewPrompt) {
          interaction.complete(message.prompt);
        }
        if (message is ParsingDemand) {
          // mainSendPort.send(ParsingResult(fileSaved.path));
          completer.complete(message);
        }
        if (message is MessageStopGeneration) {
          log("[isolate] Stopping generation");
          stopGeneration = true;
        }
      });

      var parsingDemand = await completer.future;
      Future.sync(() => Lib().binaryIsolate(
            parsingDemand: parsingDemand,
            stopToken: parsingDemand.stopToken,
            mainSendPort: mainSendPort,
          ) as FutureOr<void>);
    } catch (e) {
      mainSendPort.send("[isolate] ERROR : $e");
    }
  }

  Future<void> newPromp(String prompt) async {
    isolateSendPort?.send(MessageNewPrompt(prompt));
  }

  ReceivePort mainReceivePort = ReceivePort();

  SendPort? mainSendPort;
  SendPort? isolateSendPort;

  Future<void> executeBinary({
    required void Function(String log) printLnLog,
    required void Function(String log) printLog,
    required String promptPassed,
    required String firstInteraction,
    required void Function() done,
    required void Function() canStop,
    required String stopToken,
    required ParamsLlamaValuesOnly paramsLlamaValuesOnly,
  }) async {
    RootIsolateToken? token = ServicesBinding.rootIsolateToken;
    mainSendPort = mainReceivePort.sendPort;
    _isolate = await runZonedGuarded<Future>(
        () => Isolate.spawn(parserIsolateFunction, mainSendPort!),
        (error, stack) {});

    Completer completer = Completer();

    mainReceivePort.listen((message) {
      if (message is SendPort) {
        isolateSendPort = message;
        isolateSendPort?.send(ParsingDemand(
          rootIsolateToken: token,
          promptPassed: promptPassed,
          firstInteraction: firstInteraction,
          stopToken: stopToken,
          paramsLlamaValuesOnly: paramsLlamaValuesOnly,
        ));
      } else if (message is MessageEndFromIsolate) {
        printLnLog("MessageEndFromIsolate : ${message.message}");
        completer.complete();
      } else if (message is MessageFromIsolate) {
        print("MessageFromIsolate : ${message.message}");
        // printLnLog(message.message);
        printLog(message.message);
      } else if (message is MessageNewLineFromIsolate) {
        print("MessageNewLineFromIsolate : ${message.message}");
        printLnLog(message.message);
      } else if (message is MessageCanPrompt) {
        done();
      } else if (message is MessageCanStop) {
        canStop();
      } else {
        print(message);
      }
    });
    await completer.future;
    done();
    cancel();
  }

  static SendPort? mainPort;

  static log(String message) {
    print(message);
    var time = DateTime.now().toString().substring(11, 19);
    mainPort?.send(
      MessageNewLineFromIsolate(
        "[isolate $time] $message",
      ),
    );
  }

  static logInline(String message) {
    print(message);
    mainPort?.send(
      MessageFromIsolate(
        message,
      ),
    );
  }

  static Completer interaction = Completer();

  static void showOutput(Pointer<Char> output) {
    logInline(output.cast<Utf8>().toDartString());
  }

  binaryIsolate({
    required ParsingDemand parsingDemand,
    required SendPort mainSendPort,
    required String stopToken,
  }) async {
    interaction.complete();
    mainPort = mainSendPort;
    if (parsingDemand.rootIsolateToken == null) return;
    BackgroundIsolateBinaryMessenger.ensureInitialized(
        parsingDemand.rootIsolateToken!);

    DynamicLibrary llamasherpa =
        Platform.isMacOS || Platform.isIOS
          ? DynamicLibrary.process() // macos and ios
          : (DynamicLibrary.open(
              Platform.isWindows // windows
                ? 'llamasherpa.dll'
                : 'libllamasherpa.so')); // android and linux

    log(
      "llamasherpa loaded",
    );

    var filePath = await ModelFilePath.getFilePath();
    print("filePath : $filePath");
    if (filePath == null) {
      log("no filePath");
      return;
    }

    var prompt = parsingDemand.promptPassed;
    var firstInteraction = parsingDemand.firstInteraction;
    interaction = Completer();

    Pointer<show_output_cb> show_output = Pointer.fromFunction(showOutput);

    NativeLibrary llamasherpaBinded = NativeLibrary(llamasherpa);
    var ret = llamasherpaBinded.llamasherpa_start(filePath.toNativeUtf8().cast<Char>(), prompt.toNativeUtf8().cast<Char>(), stopToken.trim().toNativeUtf8().cast<Char>(), show_output);
      // process the prompt
      llamasherpaBinded.llamasherpa_continue("".toNativeUtf8().cast<Char>(), show_output);

    // if first line of conversation was provided, pass it now
    if (firstInteraction.isNotEmpty) {
      llamasherpaBinded.llamasherpa_continue(firstInteraction.toNativeUtf8().cast<Char>(), show_output);
    }

    while (true) {
      // ask for user input
      mainSendPort?.send(MessageCanPrompt());
      String buffer = await interaction.future;
      interaction = Completer();
      // process user input
      llamasherpaBinded.llamasherpa_continue(buffer.toNativeUtf8().cast<Char>(), show_output);
    }

    llamasherpaBinded.llamasherpa_exit();
  }

  void main() {}

  void cancel() {
    print('cancel. isolateSendPort is null ? ${isolateSendPort == null}');
    isolateSendPort?.send(MessageStopGeneration());
  }
}

class MessageStopGeneration {
  MessageStopGeneration();
}

class MessageFromIsolate {
  final String message;

  MessageFromIsolate(this.message);
}

class MessageNewLineFromIsolate {
  final String message;

  MessageNewLineFromIsolate(this.message);
}

class MessageCanPrompt {
  MessageCanPrompt();
}

class MessageCanStop {
  MessageCanStop();
}

class MessageNewPrompt {
  final String prompt;

  MessageNewPrompt(this.prompt);
}

class ParsingDemand {
  RootIsolateToken? rootIsolateToken;
  String promptPassed;
  String firstInteraction;
  String stopToken;
  ParamsLlamaValuesOnly paramsLlamaValuesOnly;

  ParsingDemand({
    required this.rootIsolateToken,
    required this.promptPassed,
    required this.firstInteraction,
    required this.stopToken,
    required this.paramsLlamaValuesOnly,
  });
}

class MessageEndFromIsolate {
  final String message;

  MessageEndFromIsolate(this.message);
}
