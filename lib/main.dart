import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart' as anthropic;
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'package:maid/locale/app_localizations.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:dio/dio.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:lcpp/lcpp.dart'
    if (dart.library.html) 'package:lcpp/lcpp.web.dart';
import 'package:tree_structs/tree_structs.dart';
import 'package:ollama_dart/ollama_dart.dart' as ollama;
import 'package:openai_dart/openai_dart.dart' as open_ai;
import 'package:mistralai_dart/mistralai_dart.dart' as mistral;
import 'package:url_launcher/url_launcher.dart';

part 'controllers/app_settings.dart';
part 'controllers/artificial_intelligence_controller.dart';
part 'controllers/chat_controller.dart';

part 'utilities/chat_messages_extension.dart';
part 'utilities/huggingface_manager.dart';
part 'utilities/platform_extension.dart';
part 'utilities/string_extension.dart';
part 'utilities/theme_mode_extension.dart';

part 'widgets/buttons/load_model_button.dart';
part 'widgets/buttons/menu_button.dart';

part 'widgets/chat/chat_tile.dart';
part 'widgets/chat/chat_view.dart';

part 'widgets/dialogs/error_dialog.dart';
part 'widgets/dialogs/sharing_dialog.dart';

part 'widgets/dropdowns/artificial_intelligence_dropdown.dart';
part 'widgets/dropdowns/locale_dropdown.dart';
part 'widgets/dropdowns/remote_model_dropdown.dart';
part 'widgets/dropdowns/theme_mode_dropdown.dart';

part 'widgets/message/message_view.dart';
part 'widgets/message/message.dart';

part 'widgets/parameter/parameter_view.dart';
part 'widgets/parameter/parameter.dart';

part 'widgets/pages/about_page.dart';
part 'widgets/pages/home_page.dart';
part 'widgets/pages/huggingface_page.dart';
part 'widgets/pages/settings_page.dart';

part 'widgets/settings/artificial_intelligence_settings.dart';
part 'widgets/settings/assistant_settings.dart';
part 'widgets/settings/system_settings.dart';
part 'widgets/settings/user_settings.dart';

part 'widgets/text_fields/api_key_text_field.dart';
part 'widgets/text_fields/base_url_text_field.dart';
part 'widgets/text_fields/listenable_text_field.dart';
part 'widgets/text_fields/prompt_field.dart';
part 'widgets/text_fields/remote_model_text_field.dart';

part 'widgets/utilities/code_box.dart';
part 'widgets/utilities/huggingface_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(Maid());
}

class Maid extends StatefulWidget {
  final AppSettings settings;
  final ChatController chatController;
  final ArtificialIntelligenceController? aiController;

  Maid({
    super.key,
    AppSettings? settings,
    ChatController? chatController,
    this.aiController
  }) : settings = settings ?? AppSettings.load(),
       chatController = chatController ?? ChatController.load();

  @override
  State<Maid> createState() => MaidState();
}


class MaidState extends State<Maid> {
  ArtificialIntelligenceController aiController = LlamaCppController();

  static MaidState of(BuildContext context) => context.findAncestorStateOfType<MaidState>()!;

  @override
  void initState() {
    super.initState();
    
    if (widget.aiController != null) {
      aiController = widget.aiController!;
    }
    else {
      ArtificialIntelligenceController.load().then(
        (newController) => setState(() => aiController = newController)
      );
    }
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
    localizationsDelegates: [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    routes: {
      '/settings': (context) => buildSettingsPage(),
      '/chat': (context) => buildHomePage(),
      '/about': (context) => const AboutPage(),
      '/huggingface': (context) => HuggingFacePage(aiController: aiController),
    },
    supportedLocales: AppLocalizations.supportedLocales,
    locale: widget.settings.locale,
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