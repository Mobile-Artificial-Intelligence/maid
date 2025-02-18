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

part 'providers/app_settings.dart';
part 'providers/artificial_intelligence/artificial_intelligence.dart';
part 'providers/artificial_intelligence/extensions/chat_extension.dart';
part 'providers/artificial_intelligence/extensions/inference_extension.dart';
part 'providers/artificial_intelligence/extensions/llama_cpp_extension.dart';
part 'providers/artificial_intelligence/extensions/ollama_extension.dart';

part 'types/llm_ecosystem.dart';
part 'types/override_type.dart';

part 'utilities/chat_messages_extension.dart';
part 'utilities/string_extension.dart';

part 'widgets/buttons/load_model_button.dart';
part 'widgets/buttons/menu_button.dart';

part 'widgets/chat/chat_tile.dart';
part 'widgets/chat/chat_view.dart';

part 'widgets/dropdowns/llm_ecosystem_dropdown.dart';
part 'widgets/dropdowns/override_type_dropdown.dart';
part 'widgets/dropdowns/remote_model_dropdown.dart';
part 'widgets/dropdowns/theme_mode_dropdown.dart';

part 'widgets/message/message_view.dart';
part 'widgets/message/message.dart';

part 'widgets/override/override_view.dart';
part 'widgets/override/override.dart';

part 'widgets/pages/about_page.dart';
part 'widgets/pages/chat_page.dart';
part 'widgets/pages/settings_page.dart';

part 'widgets/settings/llama_cpp_settings.dart';
part 'widgets/settings/ollama_settings.dart';

part 'widgets/code_box.dart';
part 'widgets/prompt_field.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    runApp(ErrorApp(details: details));
  };

  runApp(Maid());
}

class ErrorApp extends StatelessWidget {
  final FlutterErrorDetails details;
  const ErrorApp({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: getTheme(ColorScheme.fromSeed(seedColor: Colors.red, brightness: Brightness.dark)),
      home: Scaffold(
        appBar: AppBar(title: Text("An Error Occurred")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("An error occurred:"),
              Text(details.exceptionAsString()),
              Text(details.stack.toString()),
            ]
          )
        )
      ),
    );
  }
}

class Maid extends StatelessWidget {
  const Maid({super.key});

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