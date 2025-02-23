part of 'package:maid/main.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
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

  Widget buildTitle() => Selector<MaidContext, ArtificialIntelligenceNotifier>(
    selector: (context, ai) => ai.aiNotifier,
    builder: titleBuilder
  );

  Widget titleBuilder(BuildContext context, ArtificialIntelligenceNotifier aiNotifier, Widget? child) {
    if (aiNotifier is LlamaCppNotifier) {
      return LoadModelButton(
        llama: aiNotifier
      );
    }

    return RemoteModelDropdown();
  }

  Widget buildDrawer() => const Drawer(
    child: ChatView()
  );

  Widget buildBody() => const Column(
    children: [
      MessageView(
        maxMessages: 50
      ),
      PromptField(),
    ],
  );
}