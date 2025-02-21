part of 'package:maid/main.dart';

extension LlamaCppExtension on ArtificialIntelligence {
  Stream<String> llamaPrompt(List<ChatMessage> messages) async* {
    assert(ecosystem == ArtificialIntelligenceEcosystem.llamaCPP);
    assert(remoteContext == null);
    assert(model != null);

    if (_llama == null) {
      reloadModel();
      assert(_llama != null);
    }

    yield* _llama!.prompt(messages);
  }
  
  void loadModel() async {
    model = null;
    
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: "Load Model File",
      type: FileType.any,
      allowMultiple: false,
      allowCompression: false,
      onFileLoading: (status) {
        fileLoading = status == FilePickerStatus.picking;
      } 
    );

    fileLoading = false;

    if (result == null ||
        result.files.isEmpty ||
        result.files.single.path == null) {
      throw Exception('No file selected');
    }

    assert(ecosystem == ArtificialIntelligenceEcosystem.llamaCPP);
    assert(remoteContext == null);
    context.model = result.files.single.path!;

    final exists = await File(context.model!).exists();
    if (!exists) {
      throw Exception('File does not exist');
    }

    reloadModel();
    saveAndNotify();
  }

  void loadModelFile(String path) async {
    assert (RegExp(r'\.gguf$', caseSensitive: false).hasMatch(path));
    
    if (ecosystem != ArtificialIntelligenceEcosystem.llamaCPP) {
      final oldEco = ecosystem;
      ecosystem = ArtificialIntelligenceEcosystem.llamaCPP;
      await switchContext(oldEco);
    }

    assert(ecosystem == ArtificialIntelligenceEcosystem.llamaCPP);
    assert(remoteContext == null);

    model = path;
    reloadModel();
  }

  void reloadModel() async {
    if (model == null) return;
    assert(ecosystem == ArtificialIntelligenceEcosystem.llamaCPP);
    assert(remoteContext == null);

    _llama = LlamaIsolated(
      modelParams: ModelParams(
        path: model!,
        vocabOnly: overrides['vocab_only'],
        useMmap: overrides['use_mmap'],
        useMlock: overrides['use_mlock'],
        checkTensors: overrides['check_tensors']
      ),
      contextParams: ContextParams.fromMap(overrides),
      samplingParams: SamplingParams.fromMap({...overrides, 'greedy': true, 'seed': math.Random().nextInt(1000000)})
    );
  }
}
