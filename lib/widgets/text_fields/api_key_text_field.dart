part of 'package:maid/main.dart';

class ApiKeyTextField extends StatelessWidget {
  final RemoteArtificialIntelligenceController ai;

  const ApiKeyTextField({
    super.key, 
    required this.ai,
  });

  @override
  Widget build(BuildContext context) => ListenableTextField(
    listenable: ai,
    selector: () => ai.apiKey, 
    onChanged: (value) => ai.apiKey = value,
    labelText: AppLocalizations.of(context)!.apiKey,
    requireSave: true,
  );
}