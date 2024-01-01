import 'dart:async';
import 'dart:isolate';

import 'package:maid/models/isolate_message.dart';
import 'package:maid/models/library_link.dart';
import 'package:maid/models/generation_options.dart';
import 'package:maid/static/logger.dart';

class LocalGeneration {
  static Completer? _mainCompleter;
  static SendPort? _sendPort;

  static void _libraryIsolate(SendPort initialSendPort) async {
    _sendPort = initialSendPort;
    final receivePort = ReceivePort();
    _sendPort!.send(receivePort.sendPort);

    late LibraryLink link;
    Completer completer = Completer();
    receivePort.listen((data) {
      if (data is IsolateMessage) {
        switch (data.code) {
          case IsolateCode.start:
            link = LibraryLink(data.options!);
            break;
          case IsolateCode.stop:
            Logger.log('Stopping');
            link.stop();
            break;
          case IsolateCode.prompt:
            link.prompt(_sendPort!, data.input!);
            break;
          case IsolateCode.dispose:
            link.dispose();
            completer.complete();
            break;
        }
      }
    });
    await completer.future;
  }

  static Future<void> prompt(String input, GenerationOptions options,
      void Function(String?) callback) async {
    if (_mainCompleter != null) {
      await _mainCompleter!.future;
    }

    if (_sendPort != null) {
      _sendPort!.send(
        IsolateMessage(IsolateCode.prompt, input: input));
    }
    
    final receivePort = ReceivePort();
    await Isolate.spawn(_libraryIsolate, receivePort.sendPort);

    Completer completer = Completer();
    receivePort.listen((message) {
      if (_sendPort == null) {
        if (message is SendPort) {
          _sendPort = message;

          _sendPort!.send(IsolateMessage(
            IsolateCode.start,
            options: options,
          ));

          _sendPort!.send(
            IsolateMessage(IsolateCode.prompt, input: input)
          );
        }
      } else if (message is String) {
        callback.call(message);
      } else if (message is IsolateCode) {
        if (message == IsolateCode.dispose) {
          _sendPort = null;
          completer.complete();
          if (_mainCompleter != null) {
            _mainCompleter!.complete();
            _mainCompleter = null;
          }
        } else if (message == IsolateCode.stop) {
          callback.call(null);
          if (_mainCompleter != null) {
            _mainCompleter!.complete();
            _mainCompleter = null;
          }
        }
      }
    });

    await completer.future;
  }

  static void stop() {
    if (_sendPort != null) {
      _sendPort!.send(IsolateMessage(IsolateCode.stop));
      _mainCompleter = Completer();
    }
  }

  static void dispose() {
    if (_sendPort != null) {
      _sendPort!.send(IsolateMessage(IsolateCode.dispose));
      _mainCompleter = Completer();
    }
  }
}
