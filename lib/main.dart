import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lcpp/lcpp.dart';
import 'package:tree_structs/tree_structs.dart';
import 'package:ollama_dart/ollama_dart.dart' as ollama;
import 'package:openai_dart/openai_dart.dart' as open_ai;
import 'package:mistralai_dart/mistralai_dart.dart' as mistral;

part 'providers/maid_context/classes/artificial_intelligence_notifier.dart';

part 'providers/app_settings/app_settings.dart';
part 'providers/app_settings/extensions/silly_tavern_extension.dart';
part 'providers/maid_context/maid_context.dart';
part 'providers/maid_context/extensions/chat_extension.dart';

part 'types/override_type.dart';

part 'utilities/chat_messages_extension.dart';
part 'utilities/platform_extension.dart';
part 'utilities/string_extension.dart';

part 'widgets/buttons/load_model_button.dart';
part 'widgets/buttons/menu_button.dart';

part 'widgets/chat/chat_tile.dart';
part 'widgets/chat/chat_view.dart';

part 'widgets/dialogs/error_dialog.dart';
part 'widgets/dialogs/sharing_dialog.dart';

part 'widgets/dropdowns/ecosystem_dropdown.dart';
part 'widgets/dropdowns/override_type_dropdown.dart';
part 'widgets/dropdowns/remote_model_dropdown.dart';
part 'widgets/dropdowns/theme_mode_dropdown.dart';

part 'widgets/message/message_view.dart';
part 'widgets/message/message.dart';

part 'widgets/override/override_view.dart';
part 'widgets/override/override.dart';

part 'widgets/pages/about_page.dart';
part 'widgets/pages/home_page.dart';
part 'widgets/pages/settings_page.dart';

part 'widgets/settings/artificial_intelligence_settings.dart';
part 'widgets/settings/assistant_settings.dart';
part 'widgets/settings/system_settings.dart';
part 'widgets/settings/user_settings.dart';

part 'widgets/text_fields/api_key_text_field.dart';
part 'widgets/text_fields/base_url_text_field.dart';
part 'widgets/text_fields/prompt_field.dart';
part 'widgets/text_fields/selector_text_field.dart';

part 'widgets/code_box.dart';

void main() => runApp(Maid());

class Maid extends StatelessWidget {
  const Maid({super.key});

  static ThemeData getTheme(ColorScheme colorScheme) {
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
      ChangeNotifierProvider<MaidContext>(
        create: (context) => MaidContext(),
      ),
    ],
    child: buildConsumer(),
  );

  Widget buildConsumer() => Consumer2<AppSettings, MaidContext>(
    builder: buildApp
  );

  Widget buildApp(BuildContext context, AppSettings settings, MaidContext maid, Widget? child) => MaterialApp(
    title: 'Maid',
    theme: getTheme(ColorScheme.fromSeed(seedColor: settings.seedColor, brightness: Brightness.light)),
    darkTheme: getTheme(ColorScheme.fromSeed(seedColor: settings.seedColor, brightness: Brightness.dark)),
    themeMode: settings.themeMode,
    home: HomePage(ai: maid.aiNotifier, chat: maid, settings: settings),
    routes: {
      '/settings': (context) => const SettingsPage(),
      '/chat': (context) => HomePage(ai: maid.aiNotifier, chat: maid, settings: settings),
      '/about': (context) => const AboutPage(),
    },
    debugShowCheckedModeBanner: false,
  );
}