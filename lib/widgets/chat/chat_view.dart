part of 'package:maid/main.dart';

class ChatView extends StatelessWidget {
  final ArtificialIntelligenceController ai;

  const ChatView({
    super.key,
    required this.ai,
  });

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        buildHeading(context),
        Divider(endIndent: 16, indent: 16, height: 16),
        ListenableBuilder(
          listenable: ChatController.instance,
          builder: buildListView
        )
      ],
    )
  );

  Widget buildHeading(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
    child: buildHeadingRow(context)
  );

  Widget buildHeadingRow(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        AppLocalizations.of(context)!.chatsTitle,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      buildActions(context)
    ]
  );

  Widget buildActions(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        tooltip: AppLocalizations.of(context)!.import,
        onPressed: ChatController.instance.importChat,
        icon: const Icon(Icons.folder_open),
      ),
      IconButton(
        tooltip: AppLocalizations.of(context)!.clearChats,
        onPressed: ChatController.instance.clear,
        icon: const Icon(Icons.delete),
      ),
      IconButton(
        tooltip: AppLocalizations.of(context)!.newChat,
        onPressed: ChatController.instance.newChat,
        icon: const Icon(Icons.add),
      ),
    ]
  );
  
  Widget buildListView(BuildContext context, Widget? child) => Expanded(
    child: ListView.builder(
      itemCount: ChatController.instance.chats.length,
      itemBuilder: (context, index) => ChatTile(
        node: ChatController.instance.chats[index], 
        selected: index == 0,
        ai: ai,
      ),
    )
  );
}