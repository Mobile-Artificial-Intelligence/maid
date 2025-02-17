part of 'package:maid/main.dart';

extension LlamaCppExtension on ArtificialIntelligence {
  Stream<String> llamaPrompt(List<ChatMessage> messages) async* {
    assert(_llama != null);
    assert(_model[LlmEcosystem.llamaCPP] != null);

    yield* _llama!.prompt(messages);
  }
  
  void loadModel() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: "Load Model File",
      type: FileType.any,
      allowMultiple: false,
      allowCompression: false
    );

    if (result == null ||
        result.files.isEmpty ||
        result.files.single.path == null) {
      throw Exception('No file selected');
    }

    setModel(LlmEcosystem.llamaCPP, result.files.single.path!);

    final exists = await File(_model[LlmEcosystem.llamaCPP]!).exists();
    if (!exists) {
      throw Exception('File does not exist');
    }

    reloadModel();
  }

  void reloadModel() {
    if (_model[LlmEcosystem.llamaCPP] == null) return;

    _llama = LlamaIsolated(
      modelParams: ModelParams(
        path: _model[LlmEcosystem.llamaCPP]!,
        vocabOnly: overrides['vocab_only'],
        useMmap: overrides['use_mmap'],
        useMlock: overrides['use_mlock'],
        checkTensors: overrides['check_tensors']
      ),
      contextParams: ContextParams.fromMap(overrides),
      samplingParams: SamplingParams.fromMap({...overrides, 'greedy': true, 'seed': math.Random().nextInt(1000000)})
    );
    save();
    notify();
  }
}
