import 'package:flutter/material.dart';
import 'package:maid/ui/shared/chat_widgets/chat_body.dart';
import 'package:maid/ui/mobile/widgets/appbars/home_app_bar.dart';
import 'package:maid/ui/mobile/widgets/home_drawer.dart';

class MobileHomePage extends StatelessWidget {
  const MobileHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: HomeAppBar(),
      drawer: HomeDrawer(),
      body: ChatBody(),
    );
  }
}
