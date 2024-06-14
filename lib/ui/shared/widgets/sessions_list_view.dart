import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/ui/shared/widgets/tiles/session_tile.dart';
import 'package:provider/provider.dart';

class SessionsListView extends StatelessWidget {
  const SessionsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        return ListView.builder(
          itemCount: appData.sessions.length, 
          itemBuilder: (context, index) {
            return SessionTile(
              session: appData.sessions[index]
            );
          }
        );
      },
    );
  }
}