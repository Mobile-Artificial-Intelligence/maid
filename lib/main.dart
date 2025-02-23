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
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lcpp/lcpp.dart';
import 'package:tree_structs/tree_structs.dart';
import 'package:ollama_dart/ollama_dart.dart' as ollama;
import 'package:openai_dart/openai_dart.dart' as open_ai;
import 'package:mistralai_dart/mistralai_dart.dart' as mistral;

part 'controllers/app_settings.dart';
part 'controllers/artificial_intelligence_controller.dart';
part 'controllers/chat_controller.dart';

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
part 'widgets/text_fields/listenable_text_field.dart';

part 'widgets/code_box.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(Maid());
}

class Maid extends StatefulWidget {
  final AppSettings settings = AppSettings.load();
  final ChatController chatController = ChatController();

  Maid({super.key});

  @override
  State<Maid> createState() => MaidState();
}

class MaidState extends State<Maid> {
  ArtificialIntelligenceController aiController = LlamaCppController();

  static MaidState of(BuildContext context) => context.findAncestorStateOfType<MaidState>()!;

  @override
  void initState() {
    super.initState();
    ArtificialIntelligenceController.load().then(
      (newController) => setState(() => aiController = newController)
    );
  }

  Future<void> switchAi(String type) async {
    await aiController.save();

    if (aiController.type == type) return;

    aiController = await ArtificialIntelligenceController.load(type);

    setState(() => log('AI switched to $type'));
  }

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
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.settings,
    builder: buildApp
  );

  Widget buildApp(BuildContext context, Widget? child) => MaterialApp(
    title: 'Maid',
    theme: getTheme(ColorScheme.fromSeed(seedColor: widget.settings.seedColor, brightness: Brightness.light)),
    darkTheme: getTheme(ColorScheme.fromSeed(seedColor: widget.settings.seedColor, brightness: Brightness.dark)),
    themeMode: widget.settings.themeMode,
    home: buildHomePage(),
    routes: {
      '/settings': (context) => buildSettingsPage(),
      '/chat': (context) => buildHomePage(),
      '/about': (context) => const AboutPage(),
    },
    debugShowCheckedModeBanner: false,
  );

  Widget buildHomePage() => HomePage(
    aiController: aiController, 
    chatController: widget.chatController, 
    settings: widget.settings
  );

  Widget buildSettingsPage() => SettingsPage(
    aiController: aiController, 
    chatController: widget.chatController,
    settings: widget.settings
  );
}