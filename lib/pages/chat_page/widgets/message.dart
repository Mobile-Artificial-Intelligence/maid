part of 'package:maid/main.dart';

class MessageWidget extends StatefulWidget {
  final GeneralTreeNode<ChatMessage> node;

  /// The chain position is used to determine the position of the message in the chain.
  /// Where a position of 0 would indicate the bottom of the chain.
  final int chainPosition;

  ChatMessage get message => node.currentChild!.data;
  int get siblingsIndex => node.currentChildIndex!;
  int get siblingCount => node.children.length;
  bool get onNextEnabled => (siblingsIndex + 1) < siblingCount;
  bool get onPreviousEnabled => siblingsIndex > 0;
  bool get buildChild => node.currentChild!.currentChild != null && chainPosition > 0;

  const MessageWidget({
    required super.key, 
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
  void onDelete() => setState(() => widget.node.removeChildNode(widget.node.currentChild!));

  void onEdit() {
    controller.text = widget.message.content;
    setState(() => editing = true);
  }

  void onSubmitEdit() {
    widget.node.addChild(UserChatMessage(controller.text));
    widget.node.addChild(AssistantChatMessage(''));

    ArtificialIntelligence.of(context).regenerate(widget.node.currentChild!);

    setState(() => editing = false);
  }

  void onRegenerate() {
    widget.node.addChild(AssistantChatMessage(''));
    
    ArtificialIntelligence.of(context).regenerate(widget.node);
  }

  /// The build method will build the padding and the appropriate column based on the editing state.
  @override
  Widget build(BuildContext context) => Column(
    children: [
      // Build the current node
      buildCurrentMessage(),

      /// Builds the child node/s if it exists.
      if (widget.buildChild) MessageWidget(
        key: childKey,
        node: widget.node.currentChild!,
        chainPosition: widget.chainPosition - 1,
      ),
    ],
  );

  // The buildCurrentMessage method will build the padding and the appropriate column based on the editing state.
  Widget buildCurrentMessage() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    child: editing && !ArtificialIntelligence.of(context).busy ? 
      buildMessageEditingColumn() : 
      buildMessageColumn(),
  );

  // The buildMessageColumn method will build the message column when the message is not being edited.
  Widget buildMessageColumn() {
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
        children.add(CodeBox(code: part));
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
          hintText: "Edit Message",
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
  Widget buildRole() => Consumer<AppSettings>(
    builder: widget.message is UserChatMessage ? userRoleRowBuilder : assistantRoleRowBuilder,
  );

  /// Builds the role of the message when the message is a user message.
  Widget userRoleRowBuilder(BuildContext context, AppSettings settings, Widget? child) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      settings.userImage == null ? Icon(
        Icons.person, 
        color: Theme.of(context).colorScheme.onSurface
      ) : CircleAvatar(
        radius: 14,
        backgroundImage: FileImage(settings.userImage!),
      ),
      const SizedBox(width: 10.0),
      Text(
        settings.userName ?? 'User',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      )
    ],
  );

  /// Builds the role of the message when the message is an assistant message.
  Widget assistantRoleRowBuilder(BuildContext context, AppSettings settings, Widget? child) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      settings.assistantImage == null ? Icon(
        Icons.assistant, 
        color: Theme.of(context).colorScheme.onSurface
      ) : CircleAvatar(
        radius: 14,
        backgroundImage: FileImage(settings.assistantImage!),
      ),
      const SizedBox(width: 10.0),
      Text(
        settings.assistantName ?? 'Assistant',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      )
    ],
  );

  /// Builds the actions for the user to interact with the message.
  Widget buildActions() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      roleSpecificButtonBuilder(),
      branchSwitcherBuilder(),
      deleteButtonBuilder(),
    ],
  );

  /// The editing actions will allow the user to save or cancel the edit.
  Widget buildEditingActions() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      IconButton(
        icon: const Icon(Icons.done),
        onPressed: onSubmitEdit,
      ),
      IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => setState(() => editing = false),
      ),
    ],
  );

  Widget branchSwitcherBuilder() => Selector<ArtificialIntelligence, bool>(
    selector: (context, ai) => ai.busy,
    builder: buildBranchSwitcher,
  );

  /// The branch switcher will allow the user to switch between branches.
  Widget buildBranchSwitcher(BuildContext context, bool busy, Widget? child) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      IconButton(
        icon: const Icon(Icons.arrow_left),
        onPressed: !busy && widget.onPreviousEnabled ? onPrevious : null,
      ),
      Text('${widget.siblingsIndex + 1} / ${widget.siblingCount}'),
      IconButton(
        icon: const Icon(Icons.arrow_right),
        onPressed: !busy && widget.onNextEnabled ? onNext : null,
      ),
    ],
  );

  Widget roleSpecificButtonBuilder() => Selector<ArtificialIntelligence, bool>(
    selector: (context, ai) => ai.llamaLoaded,
    builder: buildRoleSpecificButton,
  );

  /// This is the role specific button that will be used to interact with the message.
  /// 
  /// If the message is a user message, it will show an edit button.
  /// If the message is an assistant message, it will show a regenerate button.
  Widget buildRoleSpecificButton(BuildContext context, bool llamaLoaded, Widget? child) {
    if (widget.message is UserChatMessage) {
      return IconButton(
        icon: const Icon(Icons.edit),
        onPressed: llamaLoaded ? onEdit : null,
      );
    } 
    else {
      return IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: llamaLoaded ? onRegenerate : null,
      );
    }
  }

  /// This is the delete button that will be used to delete the message.
  Widget deleteButtonBuilder() => Selector<ArtificialIntelligence, bool>(
    selector: (context, ai) => ai.busy,
    builder: buildDeleteButton,
  );

  Widget buildDeleteButton(BuildContext context, bool busy, Widget? child) => IconButton(
    icon: const Icon(Icons.delete),
    onPressed: !busy ? onDelete : null,
  );
}
