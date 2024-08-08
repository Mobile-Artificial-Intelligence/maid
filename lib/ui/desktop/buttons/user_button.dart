import 'package:flutter/material.dart';
import 'package:maid/classes/providers/app_data.dart';
import 'package:maid/classes/providers/desktop_navigator.dart';
import 'package:maid/ui/shared/utilities/future_avatar.dart';
import 'package:provider/provider.dart';

class UserButton extends StatelessWidget {
  const UserButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: userBuilder,
    );
  }

  Widget userBuilder(BuildContext context, AppData appData, Widget? child) {
    return FutureAvatar(
      key: appData.user.key, 
      image: appData.user.profile, 
      radius: 16, 
      onPressed: () {
        DesktopNavigator.of(context).navigateSettingsPanel("/user-settings");
      }
    );
  }
}