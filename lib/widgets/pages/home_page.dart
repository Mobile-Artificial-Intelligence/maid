part of 'package:maid/main.dart';

class HomePage extends StatefulWidget {
  final ArtificialIntelligenceController ai;
  final ChatController chatController;
  final AppSettings settings;

  const HomePage({
    super.key, 
    required this.ai,
    required this.chatController,
    required this.settings,
  });

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.ai, 
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
    if (widget.ai is LlamaCppController) {
      return LoadModelButton(
        llama: widget.ai as LlamaCppController
      );
    }

    return RemoteModelDropdown(
      ai: widget.ai as RemoteArtificialIntelligenceController,
    );
  }

  Widget buildDrawer() => Drawer(
    child: ChatView(
      chatController: widget.chatController,
      ai: widget.ai,
    )
  );

  Widget buildBody() => Column(
    children: [
      MessageView(
        maxMessages: 50,
        ai: widget.ai,
        chatController: widget.chatController,
        settings: widget.settings,
      ),
      PromptField(
        ai: widget.ai,
        chatController: widget.chatController,
        settings: widget.settings,
      ),
    ],
  );
}