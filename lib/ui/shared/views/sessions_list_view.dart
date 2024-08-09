import 'package:flutter/material.dart';
import 'package:maid/classes/providers/sessions.dart';
import 'package:maid/ui/shared/tiles/session_tile.dart';
import 'package:provider/provider.dart';

class SessionsListView extends StatelessWidget {
  const SessionsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Sessions>(
      builder: buildListView,
    );
  }

  Widget buildListView(BuildContext context, Sessions sessions, Widget? child) {
    sessions.save();

    return ListView.builder(
      itemCount: sessions.list.length, 
      itemBuilder: buildSessionTile
    );
  }

  Widget buildSessionTile(BuildContext context, int index) {
    return SessionTile(
      session: Sessions.of(context).list[index]
    );
  }
}