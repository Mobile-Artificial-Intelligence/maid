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

import 'package:sherpa/generated_bindings_llama.dart';
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

  static Future<DynamicLibrary> loadDllAndroid(
      String fileName, ByteData byteData) async {
    final buffer = byteData.buffer;

    Directory tempDir = await getApplicationDocumentsDirectory();
    String tempPath = tempDir.path;

    File file = await File('$tempPath/${fileName}').writeAsBytes(
        buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    print('size of file ${file.lengthSync()}');
    return DynamicLibrary.open(file.path);
  }

  static Future<DynamicLibrary> loadDllWindows(
      String fileName, ByteData byteData) async {
    final buffer = byteData.buffer;
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = await File(
            '$tempPath/${DateTime.now().millisecondsSinceEpoch}$fileName')
        .writeAsBytes(
            buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    print('size of file ${file.lengthSync()}');
    return DynamicLibrary.open(file.path);
  }

  static Future<DynamicLibrary> loadDllDart(String fileName) async {
    print('loadDllDart $fileName');
    return DynamicLibrary.open(fileName);
  }

//   std::vector<llama_token> llama_tokenize(struct llama_context * ctx, const  gptParams.ref. & text,  gptParams.ref. add_bos) {
//     // initialize to prompt numer of chars, since n_tokens <= n_prompt_chars
//     std::vector<llama_token> res(text.size() + (int)add_bos);
//     int n = llama_tokenize(ctx, text.c_str(), res.data(), res.size(), add_bos);
//     assert(n >= 0);
//     res.resize(n);

//     return res;
// }
  static Vector<llama_token> tokenize(NativeLibrary llamaBinded,
      Pointer<llama_context> ctx, String text, bool add_bos) {
    var resLength = text.length + (add_bos ? 1 : 0);
    var res = malloc.allocate<llama_token>(sizeOf<llama_token>() * resLength);
    var vector = Vector(res, resLength);
    var n = llamaBinded.llama_tokenize(
        ctx, text.toNativeUtf8().cast<Char>(), res, resLength, add_bos);
    assert(n >= 0);
    vector.length = n;

    return vector;
  }

  static parserIsolateFunction(
    SendPort mainSendPort,
  ) async {
    ReceivePort isolateReceivePort = ReceivePort();
    SendPort isolateSendPort = isolateReceivePort.sendPort;
    mainSendPort.send(isolateSendPort);

    try {
      isolateReceivePort.listen((message) async {
        if (message is MessageNewPrompt) {
          interaction.complete(message.prompt);
        }
        if (message is ParsingDemand) {
          // mainSendPort.send(ParsingResult(fileSaved.path));
          binaryIsolate(
            parsingDemand: message,
            stopToken: message.stopToken,
            mainSendPort: mainSendPort,
          );
        }
        if (message is MessageStopGeneration) {
          log("[isolate] Stopping generation");
          stopGeneration = true;
        }
      });
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
    required void Function() done,
    required String stopToken, required ParamsLlamaValuesOnly paramsLlamaValuesOnly,
  }) async {
    ByteData libAndroid = await rootBundle.load('assets/libs/libllama.so');
    ByteData? libWindows;
    try {
      libWindows = await rootBundle.load('assets/libs/llama.dll');
    } catch (e) {}
    ByteData? libLinux;
    try {
      libLinux = await rootBundle.load('assets/libs/libllama_linux.so');
    } catch (e) {}
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
          libLinux: libLinux,
          libAndroid: libAndroid,
          libWindows: libWindows,
          rootIsolateToken: token,
          promptPassed: promptPassed,
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

  static binaryIsolate({
    required ParsingDemand parsingDemand,
    required SendPort mainSendPort,
    required String stopToken,
  }) async {
    interaction.complete();
    String ttlString = "";
    var stopTokenTrimed = stopToken.trim().replaceAll(' ', '');
    int stopTokenLength = stopTokenTrimed.length;
    mainPort = mainSendPort;
    if (parsingDemand.rootIsolateToken == null) return;
    BackgroundIsolateBinaryMessenger.ensureInitialized(
        parsingDemand.rootIsolateToken!);

    DynamicLibrary llama = Platform.isAndroid
        ? await loadDllAndroid("libllama.so", parsingDemand.libAndroid)
        : (Platform.isIOS
            ? DynamicLibrary.executable()
            : (Platform.isWindows
                ? await loadDllWindows("llama.dll", parsingDemand.libWindows!)
                : (Platform.isMacOS
                    ? DynamicLibrary.executable()
                    : (Platform.isLinux
                        ? await loadDllWindows(
                            "libllama_linux.so", parsingDemand.libLinux!)
                        : DynamicLibrary.executable()))));
    var prompt = parsingDemand.promptPassed;

    log(
      "llama loaded",
    );

    // DynamicLibrary main = await loadDll("libmain.so");

    // NativeLibrary ggmlAutobinded = NativeLibrary(ggml);
    NativeLibrary llamaBinded = NativeLibrary(llama);
    // NativeLibrary mainBinded = NativeLibrary(main);

    // print("1${llama.providesSymbol('add')}");
    // print("2${llama.providesSymbol('llama_free')}");
    // print("3${llama.providesSymbol('llama_hparams')}");
    // print("4${llama.providesSymbol('llama_model_load')}");

    // print("5${ggml.providesSymbol('ggml_time_init')}");
    // final chat = llama.lookupFunction<ChatLaunch, ChatLaunchDart>('add');

    // dev.log('calling native function');
    // final result = chat(2, 15);
    // dev.log('result is $result'); // 42

    // print("trying lookup ggml_time_init");
    // ggmlAutobinded.ggml_time_init();

    // print("ggml_time_init done");

    // print("initialize found : ${main.providesSymbol('initialize')}");

    var gptParams = malloc.allocate<gpt_params>(sizeOf<gpt_params>());
    gptParams.ref.seed = int.parse(parsingDemand.paramsLlamaValuesOnly.seed);
    gptParams.ref.n_threads = int.parse(
        parsingDemand.paramsLlamaValuesOnly.n_threads); // number of threads
    gptParams.ref.n_predict = int.parse(
        parsingDemand.paramsLlamaValuesOnly.n_predict); // number of predictions
    gptParams.ref.repeat_last_n = int.parse(
        parsingDemand.paramsLlamaValuesOnly.repeat_last_n); // repeat last n tokens
    gptParams.ref.n_parts = int.parse(
        parsingDemand.paramsLlamaValuesOnly.n_parts); // number of parts
    gptParams.ref.n_ctx = int.parse(
        parsingDemand.paramsLlamaValuesOnly.n_ctx); // number of tokens in context
    gptParams.ref.top_k = int.parse(
        parsingDemand.paramsLlamaValuesOnly.top_k); // top k sampling
    gptParams.ref.top_p = double.parse(
        parsingDemand.paramsLlamaValuesOnly.top_p); // top p sampling
    gptParams.ref.temp = double.parse(
        parsingDemand.paramsLlamaValuesOnly.temp); // temperature
    gptParams.ref.repeat_penalty = double.parse(
        parsingDemand.paramsLlamaValuesOnly.repeat_penalty); // repeat penalty
    gptParams.ref.n_batch = int.parse(
        parsingDemand.paramsLlamaValuesOnly.n_batch); // number of batches
    gptParams.ref.memory_f16 = parsingDemand.paramsLlamaValuesOnly.memory_f16;
    gptParams.ref.random_prompt = parsingDemand.paramsLlamaValuesOnly.random_prompt;
    gptParams.ref.use_color = parsingDemand.paramsLlamaValuesOnly.use_color;
    gptParams.ref.interactive = parsingDemand.paramsLlamaValuesOnly.interactive;
    gptParams.ref.interactive_start = parsingDemand.paramsLlamaValuesOnly.interactive_start;
    gptParams.ref.instruct = parsingDemand.paramsLlamaValuesOnly.instruct;
    gptParams.ref.ignore_eos = parsingDemand.paramsLlamaValuesOnly.ignore_eos;
    gptParams.ref.perplexity = parsingDemand.paramsLlamaValuesOnly.perplexity;
    var params = gptParams.ref;
    log("main found : ${llama.providesSymbol('llama_context_default_params')}");

    log("trying main");

    var ret = llamaBinded.llama_context_default_params();
    log("trying main DONE $ret");

    var filePath = await ModelFilePath.getFilePath();
    print("filePath : $filePath");
    if (filePath == null) {
      log("no filePath");
      return;
    }

    var ctx = llamaBinded.llama_init_from_file(
        filePath.toNativeUtf8().cast<Char>(), ret);
    if (ctx == nullptr || ctx.cast<Int64>().value != 0) {
      log("context error : ${CreationContextError(ctx.cast<Int64>().value).toString()}");
      llamaBinded.llama_free(ctx);
      return;
    }

    log("context created");

    log(' test info  : ${(llamaBinded.llama_print_system_info()).cast<Utf8>().toDartString()}');
    var nbInt = 1;
    var pointerInt = malloc.allocate<Int>(nbInt);
    pointerInt[0] = 1;
    log(' ret eval  : ${llamaBinded.llama_eval(ctx, pointerInt, nbInt, 0, nbInt)}');

    var embd_inp = tokenize(llamaBinded, ctx, ' $prompt', true);
    if (embd_inp.length < 0) {
      log("error embd_inp");
      return;
    }
    log('embd_inp ${embd_inp.length}');

    var n_ctx = llamaBinded.llama_n_ctx(ctx);
    log('n_ctx ${n_ctx}');

    gptParams.ref.n_predict =
        min(gptParams.ref.n_predict, n_ctx - embd_inp.length);

    var inp_pfx = tokenize(llamaBinded, ctx, "\n\n### Instruction:\n\n", true);
    var inp_sfx = tokenize(llamaBinded, ctx, "\n\n### Response:\n\n", false);
    var llama_token_newline = tokenize(llamaBinded, ctx, "\n", false);

    var embd = Vector<Int>(nullptr, 0);

    int last_n_size = gptParams.ref.repeat_last_n;
    var last_n_tokens = Vector(
        malloc.allocate<llama_token>(sizeOf<llama_token>() * last_n_size),
        last_n_size);
    last_n_tokens.fillWithValue(0);

    int input_consumed = 0;
    bool input_noecho = false;

    int remaining_tokens = gptParams.ref.n_predict;
    int n_past = 0;
    log('before while loop');
    while ((remaining_tokens > 0 || gptParams.ref.interactive)) {
      log('remaining tokens : $remaining_tokens');
      log('stopGeneration : $stopGeneration');
      if (embd.length > 0) {
        if (llamaBinded.llama_eval(ctx, embd.pointer, embd.length, n_past,
                gptParams.ref.n_threads) >
            0) {
          log("error llama_eval");
          return;
        }
      }
      n_past += embd.length;
      embd.clear();
      if (stopGeneration) {
        log('stop Generation initiated by user');
        interaction = Completer();
        stopGeneration = false;
      }
      if (embd_inp.length <= input_consumed) {
        // out of user input, sample next token
        var top_k = gptParams.ref.top_k;
        var top_p = gptParams.ref.top_p;
        var temp = gptParams.ref.temp;
        var repeat_penalty = gptParams.ref.repeat_penalty;

        int id = 0;
        var logits = llamaBinded.llama_get_logits(ctx);

        if (params.ignore_eos) {
          // set the logit of the eos token to zero to avoid sampling it
          // logits[logits.size() - n_vocab + EOS_TOKEN_ID] = 0;
          // TODO: this does not work of params.logits_all == true
          assert(params.perplexity == false);
          logits[llamaBinded.llama_token_eos()] = 0;
        }

        id = llamaBinded.llama_sample_top_p_top_k(ctx, last_n_tokens.pointer,
            last_n_tokens.length, top_k, top_p, temp, repeat_penalty);

        last_n_tokens.erase(0);
        last_n_tokens.push_back(id);

        // if (id == llamaBinded.llama_token_eos() && params.interactive) {
        //   id = llama_token_newline.begin().value;
        //   if (stopTokenTrimed.isNotEmpty) {
        //     // tokenize and inject first reverse prompt
        //     var first_antiprompt =
        //         tokenize(llamaBinded, ctx, stopTokenTrimed, false);
        //     embd_inp.insertVectorAtEnd(first_antiprompt);
        //   }
        // }

        // add it to the context
        embd.push_back(id);

        // echo this to console
        input_noecho = false;

        // decrement remaining sampling budget
        --remaining_tokens;
      } else {
        // some user input remains from prompt or interaction, forward it to processing
        while (embd_inp.length > input_consumed) {
          embd.push_back(embd_inp.pointer[input_consumed]);
          last_n_tokens.erase(0);
          last_n_tokens.push_back(embd_inp.pointer[input_consumed]);
          ++input_consumed;
          if (embd.length >= params.n_batch) {
            break;
          }
        }
      }
      log('input_noecho = $input_noecho   embd.length = ${embd.length}');
      if (!input_noecho) {
        for (int i = 0; i < embd.length; ++i) {
          int id = embd.pointer[i];
          var str = llamaBinded
              .llama_token_to_str(ctx, id)
              .cast<Utf8>()
              .toDartString();
          logInline(str);
          ttlString += str;
          if (ttlString.length >= stopTokenLength &&
              ttlString.length > prompt.length &&
              stopTokenLength > 0) {
            var lastPartTtlString = ttlString
                .trim()
                .substring(ttlString.trim().length - stopTokenLength - 1)
                .toLowerCase()
                .replaceAll(' ', '');
            log('lastPartTtlString = $lastPartTtlString , stopTokenTrimed = $stopTokenTrimed');
            if (lastPartTtlString == stopTokenTrimed.toLowerCase()) {
              log('is_interacting = true');
              interaction = Completer();
              break;
            }
          }
        }
      }

      if (params.interactive && embd_inp.length <= input_consumed) {
        log('params.interactive && embd_inp.length <= input_consumed && interaction.isCompleted == ${interaction.isCompleted}');
        // malloc.free(pointer);
        // malloc.free(pointer);

        log('${ttlString.length} ${prompt.length} ${stopTokenLength}');

        if (interaction.isCompleted == false) {
          // potentially set color to indicate we are taking user input

          // if (params.instruct) {
          //   input_consumed = embd_inp.length;
          //   embd_inp.insertVectorAtEnd(inp_pfx);
          // }

          // logInline(stopTokenTrimed);
          mainSendPort.send(MessageCanPrompt());
          String buffer = await interaction.future;
          stopGeneration = false;
          // logInline(stopTokenTrimed + '\n');

          logInline(buffer);
          ttlString += buffer;
          // done taking input, reset color

          var line_inp = tokenize(llamaBinded, ctx, buffer, false);
          embd_inp.insertVectorAtEnd(line_inp);

          if (params.instruct) {
            embd_inp.insertVectorAtEnd(inp_sfx);
          }

          remaining_tokens -= line_inp.length;
          log(remaining_tokens.toString());

          input_noecho = true; // do not echo this again
        }
      }

      // In interactive mode, respect the maximum number of tokens and drop back to user input when reached.
      if (params.interactive && remaining_tokens <= 0) {
        remaining_tokens = params.n_predict;
        interaction = Completer();
      }
    }
    log('');
    //unload everything from memory
    //llamaBinded.llama_free works for ctx only
    llamaBinded.llama_free(ctx);

    //

    //other free
    malloc.free(embd_inp.pointer);
    malloc.free(embd.pointer);
    malloc.free(last_n_tokens.pointer);
    malloc.free(ctx);
    mainSendPort.send(MessageEndFromIsolate('ENDED !'));
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

class MessageNewPrompt {
  final String prompt;

  MessageNewPrompt(this.prompt);
}

class ParsingDemand {
  ByteData libAndroid;
  ByteData? libWindows;
  ByteData? libLinux;
  RootIsolateToken? rootIsolateToken;
  String promptPassed;
  String stopToken;
  ParamsLlamaValuesOnly paramsLlamaValuesOnly;

  ParsingDemand({
    required this.libWindows,
    required this.libAndroid,
    required this.rootIsolateToken,
    required this.promptPassed,
    required this.libLinux,
    required this.stopToken,
    required this.paramsLlamaValuesOnly,
  });
}

class MessageEndFromIsolate {
  final String message;

  MessageEndFromIsolate(this.message);
}
