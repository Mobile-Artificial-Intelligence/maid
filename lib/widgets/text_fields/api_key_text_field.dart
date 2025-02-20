part of 'package:maid/main.dart';

class ApiKeyTextField extends StatelessWidget {
  final LlmEcosystem ecosystem;

  const ApiKeyTextField({
    super.key,
    required this.ecosystem,
  }) : assert(ecosystem != LlmEcosystem.llamaCPP);

  @override
  Widget build(BuildContext context) => SelectorTextField<ArtificialIntelligence>(
    selector: (context, ai) => ai.apiKey[ecosystem], 
    onChanged: (value) => ArtificialIntelligence.of(context).setApiKey(ecosystem, value), 
    labelText: 'Api Key',
  );
}