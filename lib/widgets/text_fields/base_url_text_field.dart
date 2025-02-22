part of 'package:maid/main.dart';

class BaseUrlTextField extends StatelessWidget {
  const BaseUrlTextField({
    super.key,
  });

  @override
  Widget build(BuildContext context) => SelectorTextField<MaidContext>(
    selector: (context, ai) => ai.baseUrl, 
    onChanged: (value) => MaidContext.of(context).baseUrl = value,
    labelText: 'Base Url',
  );
}