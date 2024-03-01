import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/providers/user.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late TextEditingController _nameController;

  @override
  Widget build(BuildContext context) {
    final user = context.read<User>();
    _nameController = TextEditingController(text: user.name);

    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
            ),
          ),
          title: const Text("Character"),
        ),
        body: Consumer<User>(
          builder: (context, user, child) {
            SharedPreferences.getInstance().then((prefs) {
              prefs.setString("last_user", json.encode(user.toMap()));
            });

            return Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10.0),
                      CircleAvatar(
                        backgroundImage:
                            const AssetImage("assets/chadUser.png"),
                        foregroundImage: Image.file(user.profile).image,
                        radius: 75,
                      ),
                      const SizedBox(height: 20.0),
                      Text(
                        user.name,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 20.0),
                      Divider(
                        indent: 10,
                        endIndent: 10,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      ListTile(
                        title: Row(
                          children: [
                            const Expanded(
                              child: Text("User Name"),
                            ),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                cursorColor:
                                    Theme.of(context).colorScheme.secondary,
                                decoration: const InputDecoration(
                                  labelText: "Name",
                                ),
                                controller: _nameController,
                                onChanged: (value) {
                                  user.name = value;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (context.watch<Session>().isBusy)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.4),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
              ],
            );
          },
        ));
  }
}
