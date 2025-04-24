part of 'package:maid/main.dart';

class PromptField extends StatefulWidget {
  const PromptField({super.key});

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
    if (defaultTargetPlatform == TargetPlatform.android) {
      // For sharing or opening text coming from outside the app while the app is in the memory
      streamSubscription = ReceiveSharingIntent.instance.getMediaStream().listen(handleShare, onError: (err) => log(err.toString()));

      // For sharing or opening text coming from outside the app while the app is closed
      ReceiveSharingIntent.instance.getInitialMedia().then(handleShare);
    }
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    streamSubscription = null;
    controller.dispose();
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
      LlamaCppController.instance!.loadModelFile(path);
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
      final userMessage = ChatMessage(
        parent: ChatController.instance.root.tail.id,
        content: prompt,
        role: ChatMessageRole.user,
      );

      ChatController.instance.root.tail.addChild(userMessage);

      assert(ChatController.instance.root.tail == userMessage);
      assert(ChatController.instance.mapping.containsKey(userMessage.id));
      assert(ChatController.instance.mapping.containsValue(userMessage));

      Stream<String> stream = AIController.instance.prompt();

      final assistantMessage = ChatMessage(
        parent: userMessage.id,
        content: '', 
        role: ChatMessageRole.assistant
      );

      userMessage.addChild(assistantMessage);

      assert(ChatController.instance.root.tail == assistantMessage);
      assert(ChatController.instance.mapping.containsKey(assistantMessage.id));
      assert(ChatController.instance.mapping.containsValue(assistantMessage));

      await assistantMessage.listenToStream(stream);

      await ChatController.instance.save();
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
      key: ValueKey('clear_prompt_button'),
      onPressed: onClear, 
      child: Text(AppLocalizations.of(context)!.clearPrompt),
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
    key: ValueKey('prompt_field'),
    keyboardType: TextInputType.multiline,
    textInputAction: TargetPlatformExtension.isDesktop && !isAltPressed ? TextInputAction.done : TextInputAction.newline,
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
    hintText: AppLocalizations.of(context)!.typeMessage,
    suffixIcon: suffixButtonBuilder()
  );

  /// This is the submit button that will be used to submit the message.
  Widget suffixButtonBuilder() => AIListener(
    builder: (context, child) => AIController.instance.busy ? 
      buildStopButton() : 
      buildPromptButton(),
  );

  Widget buildPromptButton() => IconButton(
    key: ValueKey('submit_prompt_button'),
    tooltip: AppLocalizations.of(context)!.submitPrompt,
    icon: const Icon(Icons.send),
    onPressed: isNotEmpty && AIController.instance.canPrompt ? onSubmit : null,
    disabledColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
  );

  /// This is the stop button that will be used to stop the message.
  Widget buildStopButton() => IconButton(
    key: ValueKey('stop_prompt_button'),
    tooltip: AppLocalizations.of(context)!.stopPrompt,
    icon: Icon(
      Icons.stop_circle_sharp,
      color: Theme.of(context).colorScheme.onError,
    ),
    iconSize: 30,
    onPressed: AIController.instance.stop,
  );
}