part of 'package:maid/main.dart';

class ApiKeyTextField extends StatelessWidget {
  final LlmEcosystem ecosystem;

  const ApiKeyTextField({
    super.key,
    required this.ecosystem,
  }) : assert(ecosystem != LlmEcosystem.llamaCPP);

  @override
  Widget build(BuildContext context) => Selector<ArtificialIntelligence, String?>(
    selector: (context, ai) => ai.apiKey[ecosystem],
    builder: buildTextField
  );

  Widget buildTextField(BuildContext context, String? apiKey, Widget? child) => TextField(
    decoration: InputDecoration(
      labelText: 'Api Key',
    ),
    controller: TextEditingController(
      text: apiKey ?? '',
    ),
    onChanged: (value) => ArtificialIntelligence.of(context).apiKey[ecosystem] = value,
    onEditingComplete: () => onDone(context),
    onTapOutside: (event) => onDone(context),
  );

  void onDone(BuildContext context) {
    ArtificialIntelligence.of(context).notify();
    FocusScope.of(context).unfocus();
  }
}