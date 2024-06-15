import 'package:flutter/material.dart';
import 'package:maid/enumerators/large_language_model_type.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/ui/shared/widgets/shaders/blade_runner_gradient.dart';
import 'package:provider/provider.dart';

class LlmDropdown extends StatefulWidget {
  const LlmDropdown({super.key});

  @override
  State<LlmDropdown> createState() => _LlmDropdownState();
}

class _LlmDropdownState extends State<LlmDropdown> {
  bool open = false;

  @override
  Widget build(BuildContext context) {
    return BladeRunnerGradientShader(
      stops: const [0.25, 0.75],
      child: dropdownBuilder()
    );
  }

  Widget dropdownBuilder() {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        final session = appData.currentSession;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              session.model.type.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold
              )
            ),
            PopupMenuButton(
              tooltip: 'Select Large Language Model API',
              icon: Icon(
                open ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: Colors.white,
                size: 24,
              ),
              offset: const Offset(0, 40),
              itemBuilder: itemBuilder,
              onOpened: () => setState(() => open = true),
              onCanceled: () => setState(() => open = false),
              onSelected: (_) => setState(() => open = false)
            )
          ]
        );
      }
    );
  }

  List<PopupMenuEntry<dynamic>> itemBuilder(BuildContext context) {
    final session = context.read<AppData>().currentSession;

    return [
      PopupMenuItem(
        padding: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          title: const Text('LlamaCPP'),
          onTap: session.switchLlamaCpp,
        ),
      ),
      PopupMenuItem(
        padding: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          title: const Text('OpenAI'),
          onTap: session.switchOpenAI,
        ),
      ),
      PopupMenuItem(
        padding: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          title: const Text('Ollama'),
          onTap: session.switchOllama,
        ),
      ),
      PopupMenuItem(
        padding: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          title: const Text('MistralAI'),
          onTap: session.switchMistralAI,
        ),
      ),
      PopupMenuItem(
        padding: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          title: const Text('Gemini'),
          onTap: session.switchGemini,
        ),
      )
    ];
  }
}
