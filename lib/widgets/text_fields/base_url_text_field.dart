part of 'package:maid/main.dart';

class BaseUrlTextField extends StatelessWidget {
  final RemoteArtificialIntelligenceController aiController;

  const BaseUrlTextField({
    super.key, 
    required this.aiController,
  });

  @override
  Widget build(BuildContext context) => ListenableTextField(
    listenable: aiController,
    selector: () => aiController.baseUrl, 
    onChanged: (value) => aiController.baseUrl = value,
    labelText: AppLocalizations.of(context)!.baseUrl,
    requireSave: true,
  );
}