part of 'package:maid/main.dart';

class PromptField extends StatefulWidget {
  const PromptField({
    super.key, 
  });

  @override
  State<PromptField> createState() => PromptFieldState();
}

class PromptFieldState extends State<PromptField> {
  final TextEditingController controller = TextEditingController();
  StreamSubscription? streamSubscription;
  bool isNotEmpty = false;
  bool isAltPressed = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      // For sharing or opening text coming from outside the app while the app is in the memory
      streamSubscription = ReceiveSharingIntent.instance.getMediaStream().listen(handleShare, onError: (err) => log(err.toString()));

      // For sharing or opening text coming from outside the app while the app is closed
      ReceiveSharingIntent.instance.getInitialMedia().then(handleShare);
    }
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  void handleShare(List<SharedMediaFile> value) {
    if (value.isEmpty) return;

    final first = value.first;

    if (first.type == SharedMediaType.text) {
      setState(() {
        controller.text = first.path;
        isNotEmpty = first.path.isNotEmpty;
      });
    }
    else if (first.type == SharedMediaType.image) {
      showDialog(
        context: context,
        builder: (context) => SharingDialog(file: first),
      );
    }
    else if (first.type == SharedMediaType.file) {
      handleFile(first.path);
    }
  }

  void handleFile(String path) {
    if (RegExp(r'\.gguf$', caseSensitive: false).hasMatch(path)) {
      MaidContext.of(context).llamaCppNotifier!.loadModelFile(path);
    } 
  }

  /// This is the onPressed function that will be used to submit the message.
  /// It will call the onPrompt function with the text from the controller.
  /// It will also clear the controller after the message is submitted.
  void onSubmit() async {
    final prompt = controller.text;
    controller.clear();
    setState(() => isNotEmpty = controller.text.isNotEmpty);
    try {
      await MaidContext.of(context).prompt(prompt);
    }
    catch (exception) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => ErrorDialog(exception: exception),
      );
    }
  }

  void onChanged(String value) => setState(() => isNotEmpty = value.isNotEmpty);

  void onClear() {
    controller.clear();
    setState(() => isNotEmpty = false);
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: buildColumn()
    )
  );

  Widget buildColumn() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (isNotEmpty) buildClearButton(),
      buildKeyboardListener(),
    ],
  );

  Widget buildClearButton() => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: ElevatedButton(
      onPressed: onClear, 
      child: const Text('Clear Prompt')
    )
  );

  Widget buildKeyboardListener() => Flexible(
    child: KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent:(value) {
        if (value.logicalKey == LogicalKeyboardKey.altLeft || value.logicalKey == LogicalKeyboardKey.altRight) {
          setState(() => isAltPressed = value is KeyDownEvent);
        }
      },
      child: buildPromptField(),
    )
  );

  /// This is the prompt field that will be used to type a message.
  Widget buildPromptField() => TextField(
    keyboardType: TextInputType.multiline,
    textInputAction: PlatformExtension.isDesktop && !isAltPressed ? TextInputAction.done : TextInputAction.newline,
    minLines: 1,
    maxLines: 9,
    enableInteractiveSelection: true,
    controller: controller,
    decoration: buildInputDecoration(),
    onChanged: onChanged,
    onSubmitted: (_) => onSubmit(),
  );

  /// This is the input decoration for the prompt field. 
  /// It will have a hint text and a submit button at the end of the field.
  InputDecoration buildInputDecoration() => InputDecoration(
    hintText: 'Type a message...',
    suffixIcon: suffixButtonBuilder()
  );

  /// This is the submit button that will be used to submit the message.
  Widget suffixButtonBuilder() => Selector<MaidContext, bool>(
    selector: (context, ai) => ai.busy,
    builder: (context, busy, child) => busy ? 
      buildStopButton() : 
      buildSubmitButton(),
  );

  Widget buildSubmitButton() => Selector<MaidContext, bool>(
    selector: (context, ai) => ai.canPrompt,
    builder: (context, canPrompt, child) => IconButton(
      icon: const Icon(Icons.send),
      onPressed: isNotEmpty && canPrompt ? onSubmit : null,
      disabledColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
    ),
  );

  /// This is the stop button that will be used to stop the message.
  Widget buildStopButton() => IconButton(
    icon: Icon(
      Icons.stop_circle_sharp,
      color: Theme.of(context).colorScheme.onError,
    ),
    iconSize: 30,
    onPressed: MaidContext.of(context).stop,
  );
}