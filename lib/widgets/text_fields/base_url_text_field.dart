part of 'package:maid/main.dart';

class BaseUrlTextField extends StatelessWidget {
  const BaseUrlTextField({
    super.key,
  });

  @override
  Widget build(BuildContext context) => SelectorTextField<ArtificialIntelligenceProvider>(
    selector: (context, ai) => ai.baseUrl, 
    onChanged: (value) => ArtificialIntelligenceProvider.of(context).baseUrl = value,
    labelText: 'Base Url',
  );
}