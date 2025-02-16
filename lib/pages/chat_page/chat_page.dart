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
    title: const LoadModelButton(),
    actions: const [
      MenuButton()
    ] 
  );

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