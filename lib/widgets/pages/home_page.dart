part of 'package:maid/main.dart';

class HomePage extends StatefulWidget {
  final ArtificialIntelligenceNotifier ai;
  final MaidContext chat;
  final AppSettings settings;

  const HomePage({
    super.key, 
    required this.ai,
    required this.chat,
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
    if (widget.ai is LlamaCppNotifier) {
      return LoadModelButton(
        llama: widget.ai as LlamaCppNotifier
      );
    }

    return RemoteModelDropdown();
  }

  Widget buildDrawer() => Drawer(
    child: ChatView(
      disabled: widget.ai.busy,
    )
  );

  Widget buildBody() => Column(
    children: [
      MessageView(
        maxMessages: 50,
        ai: widget.ai,
        chat: widget.chat,
        settings: widget.settings,
      ),
      PromptField(
        ai: widget.ai,
        chat: widget.chat,
      ),
    ],
  );
}