import 'package:flutter/material.dart';
import 'package:maid/classes/large_language_model.dart';
import 'package:maid/providers/session.dart';
import 'package:provider/provider.dart';

class AiPlatformDropdown extends StatelessWidget {
  const AiPlatformDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (context, session, child) {
        return ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color.fromARGB(255, 0, 200, 255),
              Color.fromARGB(255, 255, 80, 200)
            ],
            stops: [0.25, 0.75],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          blendMode: BlendMode
              .srcIn, // This blend mode applies the shader to the text color.
          child: DropdownMenu<AiPlatformType>(
              dropdownMenuEntries: const [
                DropdownMenuEntry<AiPlatformType>(
                  value: AiPlatformType.llamacpp,
                  label: "LlamaCPP",
                ),
                DropdownMenuEntry<AiPlatformType>(
                  value: AiPlatformType.ollama,
                  label: "Ollama",
                ),
                DropdownMenuEntry<AiPlatformType>(
                  value: AiPlatformType.openAI,
                  label: "OpenAI",
                ),
                DropdownMenuEntry<AiPlatformType>(
                  value: AiPlatformType.mistralAI,
                  label: "MistralAI",
                ),
              ],
              onSelected: (AiPlatformType? value) {
                if (value != null) {
                  switch (value) {
                    case AiPlatformType.llamacpp:
                      session.switchLlamaCpp();
                      break;
                    case AiPlatformType.openAI:
                      session.switchOpenAI();
                      break;
                    case AiPlatformType.ollama:
                      session.switchOllama();
                      break;
                    case AiPlatformType.mistralAI:
                      session.switchMistralAI();
                      break;
                    default:
                      break;
                  }
                }
              },
              initialSelection: session.model.type,
              inputDecorationTheme: const InputDecorationTheme(
                labelStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                    fontSize: 15.0),
                hintStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                    fontSize: 15.0),
                floatingLabelBehavior: FloatingLabelBehavior.never,
              ),
              width: 175),
        );
      }
    );
  }
}
