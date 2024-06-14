import 'package:flutter/material.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/providers/user.dart';
import 'package:maid/static/utilities.dart';
import 'package:maid/ui/shared/widgets/future_avatar.dart';
import 'package:provider/provider.dart';

class CharacterDrawerTile extends StatelessWidget {
  const CharacterDrawerTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<User, Character>(
      builder: (context, user, character, child) {
        final title = Utilities.formatPlaceholders(
          character.description, 
          user.name, 
          character.name
        );

        return Column(children: [
          Text("Character - ${character.name}"),
          const SizedBox(height: 10.0),
          ListTile(
            leading: FutureAvatar(
              key: character.key,
              image: character.profile,
              radius: 25,
            ),
            minLeadingWidth: 60,
            title: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12.0)
            )
          )
        ]);
      },
    );
  }
}
