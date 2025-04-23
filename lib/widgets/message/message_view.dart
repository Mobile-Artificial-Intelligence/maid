part of 'package:maid/main.dart';

class MessageView extends StatefulWidget {
  const MessageView({super.key});

  @override
  State<MessageView> createState() => MessageViewState();
}

class MessageViewState extends State<MessageView> {
  static const int maxMessages = 50;

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
      newRootPosition = rootPosition - (maxMessages ~/ 2);
    } 
    else {
      final root = ChatController.instance.root;
      newRootPosition = math.min(
        root.chain.length - maxMessages, 
        rootPosition + (maxMessages ~/ 2)
      );
    }

    return math.max(0, newRootPosition);
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(onScroll);
    rootPosition = math.max(0, ChatController.instance.root.chain.length - maxMessages);
  }

  void onScroll() {
    if (!controller.position.atEdge) return;

    final lastTopIndex = getClosestToTopIndex();

    final newRootPosition = calculateNewRootPosition();

    final difference = newRootPosition - rootPosition;

    if (difference == 0) return;

    setState(() => rootPosition = newRootPosition);

    final keys = getChainKeys();

    int index = lastTopIndex - difference;

    if (index < 0) index = 0;
    if (index >= keys.length) index = keys.length - 1;

    final key = keys[index];

    final context = key.currentContext;
    if (context == null) return;

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox) return;

    final offset = renderObject.localToGlobal(Offset.zero);

    final topBarHeight = Scaffold.of(context).appBarMaxHeight ?? 0;

    controller.jumpTo(controller.offset + offset.dy - topBarHeight);
  }

  void jumpToExtent(Duration duration) {
    if (controller.hasClients) {
      controller.jumpTo(controller.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      if (rootPosition < ChatController.instance.root.chain.length - maxMessages)
        buildClearButton(),
      Expanded(
        child: buildSettingsListener()
      )
    ],
  );

  Widget buildClearButton() => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: ElevatedButton(
      key: ValueKey('scroll_to_recent_button'),
      onPressed: () => setState(() => rootPosition = ChatController.instance.root.chain.length - maxMessages), 
      child: Text(AppLocalizations.of(context)!.scrollToRecent),
    )
  );

  Widget buildSettingsListener() => ListenableBuilder(
    listenable: AppSettings.instance,
    builder: buildChatListener
  );

  Widget buildChatListener(BuildContext context, Widget? child) => ChatListener(
    builder: buildMessage
  );

  Widget buildMessage(BuildContext context, Widget? child) {
    ChatController.instance.root.content = AppSettings.instance.systemPrompt?.formatPlaceholders(
      AppSettings.instance.userName ?? AppLocalizations.of(context)!.user, 
      AppSettings.instance.assistantName ?? AppLocalizations.of(context)!.assistant
    ) ?? AppLocalizations.of(context)!.newChat;

    if (rootPosition < 0) {
      rootPosition = 0;
    }
    if (rootPosition >= ChatController.instance.root.chain.length) {
      rootPosition = ChatController.instance.root.chain.length - 1;
    }

    final localRoot = ChatController.instance.root.chain[rootPosition];

    if (localRoot.currentChild == null) return const SizedBox.shrink();

    if (AIController.instance.busy) {
      WidgetsBinding.instance.addPostFrameCallback(jumpToExtent);
    }

    return ListView.builder(
      controller: controller,
      itemBuilder: (context, index) => MessageWidget.itemBuilder(rootPosition + index),
      itemCount: math.min(maxMessages, ChatController.instance.root.chain.length - 1),
    );
  }
}