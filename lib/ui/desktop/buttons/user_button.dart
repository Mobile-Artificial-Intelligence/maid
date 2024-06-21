import 'package:flutter/material.dart';
import 'package:maid/classes/providers/desktop_navigator.dart';
import 'package:maid/classes/providers/user.dart';
import 'package:maid/ui/shared/utilities/future_avatar.dart';
import 'package:provider/provider.dart';

class UserButton extends StatelessWidget {
  const UserButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<User>(
      builder: (context, user, child) {
        return FutureAvatar(
          key: user.key, 
          image: user.profile, 
          radius: 16, 
          onPressed: () {
            DesktopNavigator.of(context).navigateSettingsPanel("/user-settings");
          }
        );
      },
    );
  }
}