part of 'package:maid/main.dart';

class BaseUrlTextField extends StatelessWidget {
  final LlmEcosystem ecosystem;

  const BaseUrlTextField({
    super.key,
    required this.ecosystem,
  }) : assert(ecosystem != LlmEcosystem.llamaCPP);

  @override
  Widget build(BuildContext context) => SelectorTextField<ArtificialIntelligence>(
    selector: (context, ai) => ai.baseUrl[ecosystem], 
    onChanged: (value) => ArtificialIntelligence.of(context).setBaseUrl(ecosystem, value), 
    labelText: 'Base Url',
  );
}