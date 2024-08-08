import 'package:flutter/material.dart';
import 'package:maid/classes/providers/app_data.dart';
import 'package:maid/ui/mobile/dialogs/user_name_dialog.dart';
import 'package:maid/ui/mobile/dialogs/user_image_dialog.dart';
import 'package:maid/ui/shared/utilities/future_avatar.dart';
import 'package:provider/provider.dart';

class UserTile extends StatefulWidget {
  const UserTile({super.key});

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: listTileBuilder,
    );
  }

  Widget listTileBuilder(BuildContext context, AppData appData, Widget? child) {
    return ListTile(
      title: Text(
        appData.user.name,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 20,
        ),
      ),
      leading: FutureAvatar(
        key: appData.user.key,
        image: appData.user.profile,
        radius: 20,
      ),
      trailing: PopupMenuButton(
        tooltip: 'User Menu',
        itemBuilder: (BuildContext context) => [
          PopupMenuItem(
            child: const Text("Rename"),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => const UserNameDialog(),
              );
            },
          ),
          PopupMenuItem(
            child: const Text("Change Picture"),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => const UserImageDialog(),
              );
            },
          ),
        ]
      ),
    );
  }
}
