part of 'package:maid/main.dart';

class BaseUrlTextField extends StatelessWidget {
  const BaseUrlTextField({
    super.key,
  });

  @override
  Widget build(BuildContext context) => SelectorTextField<ArtificialIntelligence>(
    selector: (context, ai) => ai.baseUrl, 
    onChanged: (value) => ArtificialIntelligence.of(context).baseUrl = value,
    labelText: 'Base Url',
  );
}