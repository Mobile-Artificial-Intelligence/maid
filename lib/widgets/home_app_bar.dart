import 'package:flutter/material.dart';
import 'package:maid/static/generation_manager.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  HomeAppBarState createState() => HomeAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(50);
}

class HomeAppBarState extends State<HomeAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FilledButton(
            onPressed: () {
              setState(() {
                GenerationManager.remote = false;
              });
            },
            style: ButtonStyle(
              fixedSize: MaterialStateProperty.all(const Size(100, 25)),
              backgroundColor: MaterialStateProperty.all(
                !GenerationManager.remote ? 
                Theme.of(context).colorScheme.tertiary :
                Theme.of(context).colorScheme.primary
              ),
            ),
            child: Text(
              "Local",
              style: Theme.of(context).textTheme.labelLarge,
            )
          ),
          const SizedBox(width: 10.0),
          FilledButton(
            onPressed: () {
              setState(() {
                GenerationManager.remote = true;
              });
            },
            style: ButtonStyle(
              fixedSize: MaterialStateProperty.all(const Size(100, 25)),
              backgroundColor: MaterialStateProperty.all(
                GenerationManager.remote ? 
                Theme.of(context).colorScheme.tertiary :
                Theme.of(context).colorScheme.primary
              ),
            ),
            child: Text(
              "Remote",
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ],
      )
    );
  }
}