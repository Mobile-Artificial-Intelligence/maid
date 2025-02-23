part of 'package:maid/main.dart';

class ChatView extends StatelessWidget {
  final bool disabled;

  const ChatView({
    super.key,
    required this.disabled,
  });

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        buildHeading(context),
        Divider(endIndent: 16, indent: 16, height: 16),
        Consumer<MaidContext>(builder: buildListView)
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
        onPressed: MaidContext.of(context).newChat,
        icon: const Icon(Icons.add),
      )
    ]
  );
  
  Widget buildListView(BuildContext context, MaidContext ai, Widget? child) => Expanded(
    child: ListView.builder(
      itemCount: ai.chats.length,
      itemBuilder: (context, index) => ChatTile(
        node: ai.chats[index], 
        selected: index == 0,
        disabled: disabled,
      ),
    )
  );
}