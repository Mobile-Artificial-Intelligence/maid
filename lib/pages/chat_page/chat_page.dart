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
    actions: const [
      MenuButton()
    ] 
  );

  Widget buildTitle() => Selector<ArtificialIntelligence, LlmEcosystem>(
    selector: (context, ai) => ai.ecosystem,
    builder: titleBuilder
  );

  Widget titleBuilder(BuildContext context, LlmEcosystem ecosystem, Widget? child) {
    if (ecosystem == LlmEcosystem.llama) {
      return const LoadModelButton();
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