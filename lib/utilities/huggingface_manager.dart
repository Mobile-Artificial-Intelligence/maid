part of 'package:maid/main.dart';

class HuggingfaceManager {
  static final Map<String, StreamController<double>> downloadProgress = {};
  static final Map<String, bool> downloadCompleted = {};

  static Future<String> getFilePath(String fileName) async {
    final cache = await getApplicationCacheDirectory();
    return '${cache.path}/$fileName';
  }

  static Stream<double> download(String repo, String branch, String fileName, LlamaCppController llama) async* {
    final filePath = await getFilePath(fileName);

    downloadProgress[fileName] = StreamController<double>.broadcast();
    downloadCompleted[fileName] = false;

    final future = Dio().download(
      "https://huggingface.co/$repo/resolve/$branch/$fileName?download=true",
      filePath,
      onReceiveProgress: (received, total) {
        if (total == -1) return;
        final progress = received / total;
        downloadProgress[fileName]!.add(progress);

        if (progress == 1.0) {
          downloadProgress[fileName]!.close();
        }
      },
    );

    yield* downloadProgress[fileName]!.stream;

    await future;

    assert(File(filePath).existsSync(), "File not downloaded");

    downloadProgress[fileName]!.close();
    downloadProgress.remove(fileName);

    downloadCompleted[fileName] = true;

    llama.addModelFile(filePath);
  }
}