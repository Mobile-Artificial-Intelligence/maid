import 'package:flutter/material.dart';
import 'package:maid/providers/user.dart';
import 'package:provider/provider.dart';

class UserTile extends StatelessWidget {
  const UserTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<User>(
      builder: (context, user, child) {
        return ListTile(
          title: Text(user.name),
          leading: CircleAvatar(
            backgroundImage: const AssetImage("assets/chadUser.png"),
            foregroundImage: Image.file(user.profile).image,
            radius: 20,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Unimplemented
            },
          ),
        );
      },
    );
  }
}
