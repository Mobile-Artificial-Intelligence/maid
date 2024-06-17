import 'package:flutter/material.dart';
import 'package:maid/providers/user.dart';
import 'package:maid/static/utilities.dart';
import 'package:maid/ui/shared/widgets/tiles/image_selector_tile.dart';
import 'package:maid/ui/shared/widgets/tiles/text_field_list_tile.dart';

class UserPanel extends StatelessWidget {
  const UserPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: User.of(context).name);

    return Scaffold(
      body: Column(
        children: [
          TextFieldListTile(
            headingText: 'User Name',
            labelText: 'User Name',
            controller: nameController,
            onChanged: (value) {
              User.of(context).name = value;
            },
            multiline: false,
          ),
          const SizedBox(height: 10.0),
          const Text(
            'Profile Picture',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 5.0),
          Expanded(
            child: buildGridView()
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FilledButton(
              onPressed: User.of(context).loadImage,
              child: const Text(
                "Load Custom Image"
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildGridView() {
    return GridView(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 100,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 1
      ),
      children: [
        GridTile(
          child: ImageSelectorTile(
            image: Utilities.fileFromAssetImage("chadUser.png"),
          ),
        ),
        GridTile(
          child: ImageSelectorTile(
            image: Utilities.fileFromAssetImage("thadUser.png"),
          ),
        ),
        GridTile(
          child: ImageSelectorTile(
            image: Utilities.fileFromAssetImage("eugeneUser.png"),
          ),
        ),
        GridTile(
          child: ImageSelectorTile(
            image: User.customImageFuture,
          ),
        ),
      ],
    );
  }
}