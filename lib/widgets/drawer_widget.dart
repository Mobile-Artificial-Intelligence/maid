import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:system_info_plus/system_info_plus.dart';
import 'package:maid/pages/settings_page.dart';

class MaidDrawer extends StatelessWidget {
  const MaidDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20)),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(
            height: 50,
          ),
          const SystemInfo(),
          Divider(
            indent: 10,
            endIndent: 10,
            color: Theme.of(context).colorScheme.primary,
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
            },
          ),
        ],
      ),
    );
  }
}

class SystemInfo extends StatefulWidget {
  const SystemInfo({super.key});

  @override
  _SystemInfoState createState() => _SystemInfoState();
}

class _SystemInfoState extends State<SystemInfo> {
  int _ram = -1;
  Color _color = Colors.red;

  @override
  void initState() {
    super.initState();
    initSysInfo();
  }

  Future<void> initSysInfo() async {
    int ram;

    if (!mounted || (!Platform.isAndroid && !Platform.isIOS)) return;
    try {
      ram = await SystemInfoPlus.physicalMemory ?? -1;
    } catch (e) {
      ram = -1;
    }

    setState(() {
      _ram = ram ~/ 1024;
      _color = Color.lerp(Colors.red, Colors.green, ram.clamp(0, 8192) / 8192) ?? Colors.red;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _ram == -1 ? 'RAM: Unknown' : 'RAM: $_ram GB',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: _color,
        fontSize: 15,
      ),
    );
  }
}
