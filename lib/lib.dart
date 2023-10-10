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
import 'package:maid/model.dart';

import 'package:maid/llama_bindings.dart';
import 'package:maid/main.dart';

import 'package:shared_preferences/shared_preferences.dart';


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
      case 13:
        return 'tensor  has wrong shape in model';
      case 14:
        return 'unknown ftype %d in model file';
      case 16:
        return 'tensor has wrong size in model file';
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
    required ParamsLlama paramsLlama,
  }) async {
    stopGeneration = false;
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
          paramsLlama: paramsLlama,
        ));
      } else if (message is MessageEndFromIsolate) {
        printLnLog("MessageEndFromIsolate : ${message.message}");
        completer.complete();
      } else if (message is MessageFromIsolate) {
        printLog(message.message);
      } else if (message is MessageNewLineFromIsolate) {
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

    DynamicLibrary llamamaid =
        Platform.isMacOS || Platform.isIOS
          ? DynamicLibrary.process() // macos and ios
          : (DynamicLibrary.open(
              Platform.isWindows // windows
                ? 'llamamaid.dll'
                : 'libllamamaid.so')); // android and linux

    log(
      "llamamaid loaded",
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

    NativeLibrary llamamaidBinded = NativeLibrary(llamamaid);
    var ret = llamamaidBinded.llamamaid_start(filePath.toNativeUtf8().cast<Char>(), prompt.toNativeUtf8().cast<Char>(), stopToken.trim().toNativeUtf8().cast<Char>(), show_output);
      // process the prompt
      llamamaidBinded.llamamaid_continue("".toNativeUtf8().cast<Char>(), show_output);

    // if first line of conversation was provided, pass it now
    if (firstInteraction.isNotEmpty) {
      llamamaidBinded.llamamaid_continue(firstInteraction.toNativeUtf8().cast<Char>(), show_output);
    }

    while (true) {
      // ask for user input
      mainSendPort?.send(MessageCanPrompt());
      String buffer = await interaction.future;
      interaction = Completer();
      // process user input
      llamamaidBinded.llamamaid_continue(buffer.toNativeUtf8().cast<Char>(), show_output);
    }

    llamamaidBinded.llamamaid_exit();
  }

  void cancel() {
    print('cancel. isolateSendPort is null ? ${isolateSendPort == null}');
    stopGeneration = true;
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
  ParamsLlama paramsLlama;

  ParsingDemand({
    required this.rootIsolateToken,
    required this.promptPassed,
    required this.firstInteraction,
    required this.stopToken,
    required this.paramsLlama,
  });
}

class MessageEndFromIsolate {
  final String message;

  MessageEndFromIsolate(this.message);
}

class ParamsLlama {
  bool memory_f16;
  bool random_prompt;
  bool use_color;
  bool interactive;
  bool interactive_start;
  bool instruct;
  bool ignore_eos;
  bool perplexity;
  String seed;
  String n_threads;
  String n_predict;
  String repeat_last_n;
  String n_parts;
  String n_ctx;
  String top_k;
  String top_p;
  String temp;
  String repeat_penalty;
  String n_batch;

  ParamsLlama({
    required this.memory_f16,
    required this.random_prompt,
    required this.use_color,
    required this.interactive,
    required this.interactive_start,
    required this.instruct,
    required this.ignore_eos,
    required this.perplexity,
    required this.seed,
    required this.n_threads,
    required this.n_predict,
    required this.repeat_last_n,
    required this.n_parts,
    required this.n_ctx,
    required this.top_k,
    required this.top_p,
    required this.temp,
    required this.repeat_penalty,
    required this.n_batch,
  });
}

class ModelFilePath {
  static Future<String?> getFilePath() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('path') != null) {
      var path = prefs.getString('path')!;
      return path;
    }
    try {
      await Permission.storage.request();
    } catch (e) {}
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['bin'],
    );
    if (result?.files.single.path != null) {
      prefs.setString('path', result!.files.single.path!);
      return result.files.single.path;
    } else {
      return null;
    }
  }

  static Future<bool> filePathExists() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('path') != null) {
      return true;
    }
    return false;
  }

  static detachModelFile() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('path');
    });
  }
}

enum FileState {
  notFound,
  found,
  opening,
}