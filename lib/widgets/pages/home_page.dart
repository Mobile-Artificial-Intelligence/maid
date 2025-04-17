part of 'package:maid/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: buildAppBar(),
    drawer: MainDrawer(),
    body: buildBody(),
  );

  PreferredSizeWidget buildAppBar() => AppBar(
    title: buildListener(),
    centerTitle: true,
    actions: const [
      MenuButton()
    ] 
  );

  Widget buildListener() => ListenableBuilder(
    listenable: AIController.notifier, 
    builder: buildTitle
  );

  Widget buildTitle(BuildContext content, Widget? child) => LlamaCppController.instance != null
    ? LoadModelButton()
    : const RemoteModelDropdown();

  Widget buildBody() => Column(
    children: [
      MessageView(),
      PromptField(),
    ],
  );
}