part of 'package:maid/main.dart';

class BaseUrlTextField extends StatelessWidget {
  final LlmEcosystem ecosystem;

  const BaseUrlTextField({
    super.key,
    required this.ecosystem,
  });

  @override
  Widget build(BuildContext context) => Selector<ArtificialIntelligence, String?>(
    selector: (context, ai) => ai.baseUrl[ecosystem],
    builder: (context, baseUrl, child) => TextField(
      decoration: InputDecoration(
        labelText: 'Base URL',
      ),
      controller: TextEditingController(
        text: baseUrl ?? '',
      ),
      onChanged: (value) => ArtificialIntelligence.of(context).baseUrl[ecosystem] = value,
    ),
  );
}