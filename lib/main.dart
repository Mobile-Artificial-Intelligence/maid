import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lcpp/lcpp.dart';
import 'package:tree_structs/tree_structs.dart';
import 'package:ollama_dart/ollama_dart.dart';

part 'types/llm_ecosystem.dart';
part 'types/override_type.dart';

part 'providers/app_settings.dart';
part 'providers/artificial_intelligence.dart';

part 'pages/about_page/about_page.dart';

part 'pages/settings_page/settings_page.dart';
part 'pages/settings_page/widgets/theme_mode_dropdown.dart';

part 'pages/settings_page/widgets/llama_cpp_settings.dart';
part 'pages/settings_page/widgets/llm_ecosystem_dropdown.dart';
part 'pages/settings_page/widgets/ollama_settings.dart';
part 'pages/settings_page/widgets/override_type_dropdown.dart';
part 'pages/settings_page/widgets/override_view.dart';
part 'pages/settings_page/widgets/override.dart';

part 'pages/chat_page/chat_page.dart';
part 'pages/chat_page/widgets/chat_tile.dart';
part 'pages/chat_page/widgets/chat_view.dart';
part 'pages/chat_page/widgets/code_box.dart';
part 'pages/chat_page/widgets/load_model_button.dart';
part 'pages/chat_page/widgets/menu_button.dart';
part 'pages/chat_page/widgets/message_view.dart';
part 'pages/chat_page/widgets/message.dart';
part 'pages/chat_page/widgets/prompt_field.dart';

part 'utilities/chat_messages_extension.dart';
part 'utilities/string_extension.dart';

part 'widgets/remote_model_dropdown.dart';

void main() => runApp(const Maid());

class Maid extends StatelessWidget {
  const Maid({super.key});

  ThemeData getTheme(ColorScheme colorScheme) {
    final appBarTheme = AppBarTheme(
      elevation: 0.0,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
    );

    final inputDecorationTheme = InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20.0, 
        vertical: 15.0
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide.none,
      ),
      filled: true,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      appBarTheme: appBarTheme,
      inputDecorationTheme: inputDecorationTheme
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider<AppSettings>(
        create: (context) => AppSettings(),
      ),
      ChangeNotifierProvider<ArtificialIntelligence>(
        create: (context) => ArtificialIntelligence(),
      ),
    ],
    child: buildConsumer(),
  );

  Widget buildConsumer() => Consumer<AppSettings>(
    builder: buildApp
  );

  Widget buildApp(BuildContext context, AppSettings settings, Widget? child) => MaterialApp(
    title: 'Maid',
    theme: getTheme(ColorScheme.fromSeed(seedColor: settings.seedColor, brightness: Brightness.light)),
    darkTheme: getTheme(ColorScheme.fromSeed(seedColor: settings.seedColor, brightness: Brightness.dark)),
    themeMode: settings.themeMode,
    home: const ChatPage(),
    routes: {
      '/settings': (context) => const SettingsPage(),
      '/chat': (context) => const ChatPage(),
      '/about': (context) => const AboutPage(),
    },
    debugShowCheckedModeBanner: false,
  );
}
