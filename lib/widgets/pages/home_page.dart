part of 'package:maid/main.dart';

class HomePage extends StatefulWidget {
  final ArtificialIntelligenceNotifier aiController;
  final MaidContext chatController;
  final AppSettings settings;

  const HomePage({
    super.key, 
    required this.aiController,
    required this.chatController,
    required this.settings,
  });

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.aiController, 
    builder: scaffoldBuilder
  );

  Widget scaffoldBuilder(BuildContext context, Widget? child) => Scaffold(
    appBar: buildAppBar(),
    drawer: buildDrawer(),
    body: buildBody(),
  );

  PreferredSizeWidget buildAppBar() => AppBar(
    title: buildTitle(),
    centerTitle: true,
    actions: const [
      MenuButton()
    ] 
  );

  Widget buildTitle() {
    if (widget.aiController is LlamaCppNotifier) {
      return LoadModelButton(
        llama: widget.aiController as LlamaCppNotifier
      );
    }

    return RemoteModelDropdown(
      aiController: widget.aiController as RemoteArtificialIntelligenceNotifier,
    );
  }

  Widget buildDrawer() => Drawer(
    child: ChatView(
      chatController: widget.chatController,
      disabled: widget.aiController.busy,
    )
  );

  Widget buildBody() => Column(
    children: [
      MessageView(
        maxMessages: 50,
        ai: widget.aiController,
        chatController: widget.chatController,
        settings: widget.settings,
      ),
      PromptField(
        ai: widget.aiController,
        chatController: widget.chatController,
      ),
    ],
  );
}