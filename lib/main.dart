import 'dart:io';
import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maid/lib.dart';
import 'package:maid/model.dart';
import 'package:maid/widgets/settings_widget.dart';
import 'package:maid/widgets/chat_widget.dart';
import 'package:system_info_plus/system_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MaidApp());
}

class MaidApp extends StatelessWidget {
  const MaidApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Maid',
      theme: MaidTheme().getTheme(),
      home: const MaidHomePage(title: 'Maid'),
    );
  }
}

class MaidTheme {
  static Color gradientColorA = const Color(0xFFFFFFFF);
  static Color gradientColorB = const Color(0xFF000000);

  ThemeData getTheme() {
    gradientColorA = const Color(0xFF000000);
    gradientColorB = const Color(0xFFFFFFFF);
    return _darkTheme;
  }

  static final ThemeData _darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.grey[700],
    colorScheme: ColorScheme.dark(
      primary: Colors.cyan.shade700,
      secondary: Colors.purple.shade900,
    ),
  );
}

class MaidHomePage extends StatefulWidget {
  const MaidHomePage({super.key, required this.title});

  final String title;

  @override
  State<MaidHomePage> createState() => _MaidHomePageState();
}

class _MaidHomePageState extends State<MaidHomePage> {
 
  Model model = Model();

  Color color = Colors.black;

  void showInfosAlert() {
    showDialog(
      context: context,
      builder: (BuildContext contextAlert) {
        return AlertDialog(
          title: const Text("Infos"),
          content: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 300,
            ),
            child: SingleChildScrollView(
              child: ListBody(
                children: [
                  const SelectableText(
                      "This app is a demo of the llama.cpp model.\n\n"
                      "You can find the source code of this app on GitHub\n\n"
                      'It was made on Flutter using an implementation of ggerganov/llama.cpp recompiled to work on mobiles\n\n'
                      'The LLaMA models are officially distributed by Meta and will never be provided by us\n\n'
                      'It was made by Maxime GUERIN and Thibaut LEAUX from the french company Bip-Rep based in Lyon (France)'),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(0),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: () async {
                      var url = 'https://bip-rep.com';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url));
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    child: Image.asset(
                      "assets/biprep.jpg",
                      width: 100,
                      height: 100,
                    ),
                  ),
                ],
              ),
            ),
          )
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade900,  // Set a solid color here
          ),
        ),
        title: GestureDetector(
          onTap: () {
            showInfosAlert();
          },
          child: Text(widget.title),
        ),
      ),
      drawer: SettingsWidget(model: model),
      body: ChatWidget(model: model),
    );
  }
}