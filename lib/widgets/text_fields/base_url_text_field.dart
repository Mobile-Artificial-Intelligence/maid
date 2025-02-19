part of 'package:maid/main.dart';

class BaseUrlTextField extends StatelessWidget {
  final LlmEcosystem ecosystem;

  const BaseUrlTextField({
    super.key,
    required this.ecosystem,
  }) : assert(ecosystem != LlmEcosystem.llamaCPP);

  @override
  Widget build(BuildContext context) => Selector<ArtificialIntelligence, String?>(
    selector: (context, ai) => ai.baseUrl[ecosystem],
    builder: buildTextField
  );

  Widget buildTextField(BuildContext context, String? baseUrl, Widget? child) => TextField(
    decoration: InputDecoration(
      labelText: 'Base URL',
    ),
    controller: TextEditingController(
      text: baseUrl ?? '',
    ),
    onChanged: (value) => ArtificialIntelligence.of(context).baseUrl[ecosystem] = value,
    onEditingComplete: () => onDone(context),
    onTapOutside: (event) => onDone(context),
  );

  void onDone(BuildContext context) {
    ArtificialIntelligence.of(context).notify();
    FocusScope.of(context).unfocus();
  }
}