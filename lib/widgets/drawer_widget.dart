import 'package:flutter/material.dart';
import 'package:system_info2/system_info2.dart';
import 'package:maid/pages/settings_page.dart';
import 'package:maid/pages/about_page.dart';

class MaidDrawer extends StatelessWidget {
  const MaidDrawer({super.key});

  static int ram = SysInfo.getTotalPhysicalMemory() ~/ (1024 * 1024 * 1024);

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
          Text(
            ram == -1 ? 'RAM: Unknown' : 'RAM: $ram GB',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color.lerp(Colors.red, Colors.green, ram.clamp(0, 8) / 8) ?? Colors.red,
              fontSize: 15,
            ),
          ),
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
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text(
              'About',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPage()));
            },
          ),
        ],
      ),
    );
  }
}
