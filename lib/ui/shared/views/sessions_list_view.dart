import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/ui/shared/tiles/session_tile.dart';
import 'package:provider/provider.dart';

class SessionsListView extends StatelessWidget {
  const SessionsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: buildListView,
    );
  }

  Widget buildListView(BuildContext context, AppData appData, Widget? child) {
    appData.save();

    return ListView.builder(
      itemCount: appData.sessions.length, 
      itemBuilder: buildSessionTile
    );
  }

  Widget buildSessionTile(BuildContext context, int index) {
    return SessionTile(
      session: AppData.of(context).sessions[index]
    );
  }
}