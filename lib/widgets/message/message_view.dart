part of 'package:maid/main.dart';

class MessageView extends StatefulWidget {
  final ArtificialIntelligenceNotifier ai;
  final MaidContext chat;
  final AppSettings settings;
  final int maxMessages;

  const MessageView({
    super.key, 
    required this.ai,
    required this.chat,
    required this.settings,
    required this.maxMessages,
  });

  @override
  State<MessageView> createState() => MessageViewState();
}

class MessageViewState extends State<MessageView> {
  final GlobalKey rootKey = GlobalKey();
  final ScrollController controller = ScrollController();
  int rootPosition = 0;

  List<GlobalKey> getChainKeys() {
    final List<GlobalKey> keys = [rootKey];
    MessageWidgetState? current = rootKey.currentState as MessageWidgetState?;

    while (current != null) {
      keys.add(current.childKey);
      current = current.childKey.currentState as MessageWidgetState?;
    }
    
    return keys;
  }

  int getClosestToTopIndex() {
    final topBarHeight = Scaffold.of(context).appBarMaxHeight ?? 0;
    final keys = getChainKeys();
    double minDistance = double.infinity;
    int closestIndex = 0; // Default to 0 if none is found

    for (int i = 0; i < keys.length; i++) {
      final key = keys[i];
      final context = key.currentContext;

      if (context == null) continue;

      final box = context.findRenderObject() as RenderBox;
      final position = box.localToGlobal(Offset.zero);
      final distance = position.dy - topBarHeight;

      // Check if the distance is less than the minimum distance
      if (distance.abs() >= minDistance.abs()) continue;

      minDistance = distance;
      closestIndex = i;
    }

    return closestIndex;
  }

  int calculateNewRootPosition() {
    int newRootPosition = rootPosition;

    if (controller.position.pixels == 0) {
      newRootPosition = rootPosition - (widget.maxMessages ~/ 2);
    } 
    else {
      final root = MaidContext.of(context).root;
      newRootPosition = math.min(
        root.chain.length - widget.maxMessages, 
        rootPosition + (widget.maxMessages ~/ 2)
      );
    }

    return math.max(0, newRootPosition);
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final root = MaidContext.of(context).root;
      rootPosition = math.max(0, root.chain.length - widget.maxMessages);
      controller.jumpTo(controller.position.maxScrollExtent);
    });
  }

  void onScroll() {
    if (!controller.position.atEdge) return;

    final lastTopIndex = getClosestToTopIndex();

    final newRootPosition = calculateNewRootPosition();

    final difference = newRootPosition - rootPosition;

    if (difference == 0) return;

    setState(() => rootPosition = newRootPosition);

    final index = lastTopIndex - difference;

    final keys = getChainKeys();

    final key = keys[index];

    final context = key.currentContext;
    if (context == null) return;

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox) return;

    final offset = renderObject.localToGlobal(Offset.zero);

    final topBarHeight = Scaffold.of(context).appBarMaxHeight ?? 0;

    controller.jumpTo(controller.offset + offset.dy - topBarHeight);
  }

  @override
  Widget build(BuildContext context) => Expanded(
    child: SingleChildScrollView(
      controller: controller,
      child: messageBuilder(),
    )
  );

  Widget messageBuilder() => ListenableBuilder(
    listenable: widget.settings,
    builder: buildMessage
  );

  Widget buildMessage(BuildContext context, Widget? child) {
    final currentRoot = widget.chat.root.chain[rootPosition];
    currentRoot.data.content = widget.settings.systemPrompt?.formatPlaceholders(
      widget.settings.userName ?? 'User', 
      widget.settings.assistantName ?? 'Assistant'
    ) ?? 'New Chat';

    if (currentRoot.currentChild == null) return const SizedBox.shrink();

    return MessageWidget(
      key: rootKey,
      ai: widget.ai,
      chat: widget.chat,
      settings: widget.settings,
      node: currentRoot,
      chainPosition: widget.maxMessages - 1,
    );
  }
}