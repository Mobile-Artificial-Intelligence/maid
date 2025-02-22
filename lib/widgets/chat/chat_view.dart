part of 'package:maid/main.dart';

class ChatView extends StatelessWidget {
  const ChatView({
    super.key,
  });

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        buildHeading(context),
        Divider(endIndent: 16, indent: 16, height: 16),
        Consumer<ArtificialIntelligenceProvider>(builder: buildListView)
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
        'Chats',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      IconButton(
        onPressed: ArtificialIntelligenceProvider.of(context).newChat,
        icon: const Icon(Icons.add),
      )
    ]
  );
  
  Widget buildListView(BuildContext context, ArtificialIntelligenceProvider ai, Widget? child) => Expanded(
    child: ListView.builder(
      itemCount: ai.chats.length,
      itemBuilder: (context, index) => ChatTile(
        node: ai.chats[index], 
        selected: index == 0
      ),
    )
  );
}