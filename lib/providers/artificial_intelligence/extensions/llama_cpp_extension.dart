part of 'package:maid/main.dart';

extension LlamaCppExtension on ArtificialIntelligence {
  Stream<String> llamaPrompt(List<ChatMessage> messages) async* {
    assert(ecosystem == ArtificialIntelligenceEcosystem.llamaCPP);
    assert(remoteContext == null);
    assert(_llama != null);
    assert(model != null);

    yield* _llama!.prompt(messages);
  }
  
  void loadModel() async {
    context.model = null;
    notify();
    
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: "Load Model File",
      type: FileType.any,
      allowMultiple: false,
      allowCompression: false,
      onFileLoading: (status) {
        fileLoading = status == FilePickerStatus.picking;
        notify();
      } 
    );

    fileLoading = false;
    notify();

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
  }

  void reloadModel() {
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
    saveAndNotify();
  }
}
