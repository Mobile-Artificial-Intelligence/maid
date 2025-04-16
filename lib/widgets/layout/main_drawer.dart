part of 'package:maid/main.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) => Drawer(
    child: SafeArea(
      child: buildColumn(context)
    ),
  );

  Widget buildColumn(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.max,
    children: [
      buildHeading(context),
      Divider(endIndent: 16, indent: 16, height: 16),
      ListenableBuilder(
        listenable: ChatController.instance,
        builder: buildListView
      ),
      Divider(endIndent: 16, indent: 16, height: 16),
      buildFooter(context),
    ],
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
        selected: index == 0
      ),
    )
  );

  Widget buildFooter(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    child: buildFooterRow(context)
  );

  Widget buildFooterRow(BuildContext context) {
    final currentSession = Supabase.instance.client.auth.currentSession;

    if (currentSession == null) {
      return buildLoggedOutRow(context);
    }

    return buildLoggedInRow(context);   
  }

  Widget buildLoggedOutRow(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      TextButton(onPressed: () => Navigator.of(context).pushNamed('/login'), child: Text('Login')),
      TextButton(onPressed: () => Navigator.of(context).pushNamed('/register'), child: Text('Register')),
    ],
  );

  Widget buildLoggedInRow(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        Supabase.instance.client.auth.currentSession?.user.email ?? 'User Email',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      IconButton(
        tooltip: 'Logout', // TODO: Localize
        onPressed: () => Supabase.instance.client.auth.signOut(),
        icon: const Icon(Icons.logout),
      ),
    ],
  );
}