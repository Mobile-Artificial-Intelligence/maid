import 'package:flutter/material.dart';
import 'package:maid/ui/shared/buttons/clear_sessions_button.dart';
import 'package:maid/ui/shared/buttons/new_session_button.dart';
import 'package:maid/ui/shared/views/sessions_list_view.dart';

class SessionsPanel extends StatelessWidget {
  const SessionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sessions"
        ),
        centerTitle: true,
      ),
      body: buildColumn()
    );
  }

  Widget buildColumn() {
    return const Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8.0,
          runSpacing: 4.0,
          children: [
            ClearSessionsButton(),
            NewSessionButton(),
          ],
        ),
        Expanded(child: SessionsListView())
      ]
    );
  }
}