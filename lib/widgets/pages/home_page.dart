part of 'package:maid/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: AIController.instance, 
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

  Widget buildTitle() => LlamaCppController.instance != null
    ? LoadModelButton()
    : const RemoteModelDropdown();

  Widget buildDrawer() => Drawer(
    child: ChatView()
  );

  Widget buildBody() => Column(
    children: [
      MessageView(
        maxMessages: 50,
      ),
      PromptField(
      ),
    ],
  );
}