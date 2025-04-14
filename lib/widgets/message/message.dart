part of 'package:maid/main.dart';

class MessageWidget extends StatefulWidget {
  final ArtificialIntelligenceController ai;
  final ChatMessage node;

  /// The chain position is used to determine the position of the message in the chain.
  /// Where a position of 0 would indicate the bottom of the chain.
  final int chainPosition;

  ChatMessage get message => node.currentChild!;
  int get siblingsIndex => node.currentChildIndex;
  int get siblingCount => node.children.length;
  bool get onNextEnabled => (siblingsIndex + 1) < siblingCount;
  bool get onPreviousEnabled => siblingsIndex > 0;
  bool get buildChild => node.currentChild?.currentChild != null && chainPosition > 0;

  const MessageWidget({
    required super.key, 
    required this.ai,
    required this.node,
    required this.chainPosition,
  });

  @override
  State<MessageWidget> createState() => MessageWidgetState();
}

class MessageWidgetState extends State<MessageWidget> {
  final GlobalKey childKey = GlobalKey();
  final TextEditingController controller = TextEditingController();
  bool editing = false;

  void onNext() => setState(() => widget.node.nextChild());
  void onPrevious() => setState(() => widget.node.previousChild());
  void onDelete() => setState(() => widget.node.removeChild(widget.node.currentChild!));

  void onEdit() {
    controller.text = widget.message.content;
    setState(() => editing = true);
  }

  void onSubmitEdit() {
    ChatMessage(content: controller.text, role: ChatMessageRole.user, parent: widget.node);

    tryRegenerate(widget.node.currentChild!);

    setState(() => editing = false);
  }

  void onRegenerate() => tryRegenerate(widget.node);

  void tryRegenerate(ChatMessage node) async {
    try {
      if (widget.ai is LlamaCppController) {
        (widget.ai as LlamaCppController).reloadModel(true);
      }

      Stream<String> stream = widget.ai.prompt();

      ChatMessage.withStream(stream: stream, role: ChatMessageRole.assistant, parent: node);
    }
    catch (exception) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => ErrorDialog(exception: exception),
      );
    }
  }

  void onHorizontalDragEnd(DragEndDetails details) {
    if (widget.ai.busy) return;

    const threshold = 80;
    
    if (details.primaryVelocity! > threshold) {
      if (widget.onPreviousEnabled) onPrevious();
    } 
    else if (details.primaryVelocity! < -threshold) {
      if (widget.onNextEnabled) onNext();
    }
  }

  /// The build method will build the padding and the appropriate column based on the editing state.
  @override
  Widget build(BuildContext context) => Column(
    children: [
      // Build the current node
      if (widget.node.currentChild != null) buildCurrentMessage(),

      /// Builds the child node/s if it exists.
      if (widget.buildChild) MessageWidget(
        key: childKey,
        ai: widget.ai,
        node: widget.node.currentChild!,
        chainPosition: widget.chainPosition - 1,
      ),
    ],
  );

  // The buildCurrentMessage method will build the padding and the appropriate column based on the editing state.
  Widget buildCurrentMessage() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    child: editing && !widget.ai.busy ? 
      buildMessageEditingColumn() : 
      GestureDetector(
        onHorizontalDragEnd: onHorizontalDragEnd,
        child: buildChatListener()
      ),
  );

  Widget buildChatListener() => ListenableBuilder(
    listenable: widget.message, 
    builder: buildMessageColumn
  );

  // The buildMessageColumn method will build the message column when the message is not being edited.
  Widget buildMessageColumn(BuildContext context, Widget? child) {
    List<Widget> children = [
      buildTopRow(),
    ];

    List<String> parts = widget.message.content.split('```');

    for (int i = 0; i < parts.length; i++) {
      String part = parts[i].trim();
      if (part.isEmpty) continue;

      if (i % 2 == 0) {
        children.add(SelectableText(part));
      } else {
        children.add(CodeBox(code: part, label: AppLocalizations.of(context)!.code));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  // The buildMessageEditingColumn method will build the message column when the message is being edited.
  Widget buildMessageEditingColumn() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildEditingTopRow(),
      TextField(
        controller: controller,
        autofocus: true,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.editMessage,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        maxLines: null,
        keyboardType: TextInputType.multiline,
      )
    ],
  );

  /// Builds the top row of the message.
  Widget buildTopRow() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      buildRole(),
      buildActions(),
    ],
  );

  /// Builds the top row of the message when the message is being edited.
  Widget buildEditingTopRow() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      buildRole(),
      buildEditingActions(),
    ],
  );

  /// Builds the role of the message.
  Widget buildRole() => ListenableBuilder(
    listenable: AppSettings.instance,
    builder: widget.message.role == ChatMessageRole.user ? buildUserRow : buildAssistantRow,
  );

  /// Builds the role of the message when the message is a user message.
  Widget buildUserRow(BuildContext context, Widget? child) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      AppSettings.instance.userImage == null ? Icon(
        Icons.person, 
        color: Theme.of(context).colorScheme.onSurface
      ) : CircleAvatar(
        radius: 14,
        backgroundImage: MemoryImage(AppSettings.instance.userImage!),
      ),
      const SizedBox(width: 10.0),
      Text(
        AppSettings.instance.userName ?? AppLocalizations.of(context)!.user,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      )
    ],
  );

  /// Builds the role of the message when the message is an assistant message.
  Widget buildAssistantRow(BuildContext context, Widget? child) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      AppSettings.instance.assistantImage == null ? Icon(
        Icons.assistant, 
        color: Theme.of(context).colorScheme.onSurface
      ) : CircleAvatar(
        radius: 14,
        backgroundImage: MemoryImage(AppSettings.instance.assistantImage!),
      ),
      const SizedBox(width: 10.0),
      Text(
        AppSettings.instance.assistantName ?? AppLocalizations.of(context)!.assistant,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      )
    ],
  );

  /// Builds the actions for the user to interact with the message.
  Widget buildActions() => ListenableBuilder(
    listenable: widget.ai,
    builder: buildActionsRow,
  );
  
  Widget buildActionsRow(BuildContext context, Widget? child) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      buildRoleSpecificButton(),
      buildBranchSwitcher(),
      buildDeleteButton(),
    ],
  );

  /// The editing actions will allow the user to save or cancel the edit.
  Widget buildEditingActions() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      IconButton(
        tooltip: AppLocalizations.of(context)!.done,
        icon: const Icon(Icons.done),
        onPressed: onSubmitEdit,
      ),
      IconButton(
        tooltip: AppLocalizations.of(context)!.cancel,
        icon: const Icon(Icons.close),
        onPressed: () => setState(() => editing = false),
      ),
    ],
  );

  /// The branch switcher will allow the user to switch between branches.
  Widget buildBranchSwitcher() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      IconButton(
        tooltip: AppLocalizations.of(context)!.previous,
        icon: const Icon(Icons.arrow_left),
        onPressed: !widget.ai.busy && widget.onPreviousEnabled ? onPrevious : null,
      ),
      Text('${widget.siblingsIndex + 1} / ${widget.siblingCount}'),
      IconButton(
        tooltip: AppLocalizations.of(context)!.next,
        icon: const Icon(Icons.arrow_right),
        onPressed: !widget.ai.busy && widget.onNextEnabled ? onNext : null,
      ),
    ],
  );

  /// This is the role specific button that will be used to interact with the message.
  /// 
  /// If the message is a user message, it will show an edit button.
  /// If the message is an assistant message, it will show a regenerate button.
  Widget buildRoleSpecificButton() {
    if (widget.message.role == ChatMessageRole.user) {
      return IconButton(
        tooltip: AppLocalizations.of(context)!.edit,
        icon: const Icon(Icons.edit),
        onPressed: widget.ai.canPrompt ? onEdit : null,
      );
    } 
    else {
      return IconButton(
        tooltip: AppLocalizations.of(context)!.regenerate,
        icon: const Icon(Icons.refresh),
        onPressed: widget.ai.canPrompt ? onRegenerate : null,
      );
    }
  }

  /// The delete button will allow the user to delete the message.
  Widget buildDeleteButton() => IconButton(
    tooltip: AppLocalizations.of(context)!.delete,
    icon: const Icon(Icons.delete),
    onPressed: !widget.ai.busy ? onDelete : null,
  );
}
