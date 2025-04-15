part of 'package:maid/main.dart';

class ApiKeyTextField extends StatelessWidget {
  const ApiKeyTextField({super.key});

  @override
  Widget build(BuildContext context) => ListenableTextField(
    listenable: RemoteAIController.instance!,
    selector: () => RemoteAIController.instance!.apiKey, 
    onChanged: (value) => RemoteAIController.instance!.apiKey = value,
    labelText: AppLocalizations.of(context)!.apiKey,
    requireSave: true,
  );
}