part of 'package:maid/main.dart';

class ApiKeyTextField extends StatelessWidget {
  final RemoteArtificialIntelligenceController aiController;

  const ApiKeyTextField({
    super.key, 
    required this.aiController,
  });

  @override
  Widget build(BuildContext context) => ListenableTextField(
    listenable: aiController,
    selector: () => aiController.apiKey, 
    onChanged: (value) => aiController.apiKey = value,
    labelText: AppLocalizations.of(context)!.apiKey,
  );
}