import 'package:flutter/material.dart';
import 'package:maid/ui/shared/widgets/buttons/new_session_button.dart';
import 'package:maid/ui/shared/widgets/sessions_list_view.dart';

class SessionsPanel extends StatelessWidget {
  const SessionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const NewSessionButton(),
        centerTitle: true,
      ),
      body: const SessionsListView(),
    );
  }
}