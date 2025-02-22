part of 'package:maid/main.dart';

class ApiKeyTextField extends StatelessWidget {
  const ApiKeyTextField({
    super.key,
  });

  @override
  Widget build(BuildContext context) => SelectorTextField<MaidContext>(
    selector: (context, ai) => ai.apiKey, 
    onChanged: (value) => MaidContext.of(context).apiKey = value,
    labelText: 'Api Key',
  );
}