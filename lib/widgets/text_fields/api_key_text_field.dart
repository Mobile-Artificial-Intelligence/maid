part of 'package:maid/main.dart';

class ApiKeyTextField extends StatelessWidget {
  const ApiKeyTextField({super.key});

  @override
  Widget build(BuildContext context) => ListenableTextField(
    listenable: RemoteArtificialIntelligenceController.instance!,
    selector: () => RemoteArtificialIntelligenceController.instance!.apiKey, 
    onChanged: (value) => RemoteArtificialIntelligenceController.instance!.apiKey = value,
    labelText: AppLocalizations.of(context)!.apiKey,
    requireSave: true,
  );
}