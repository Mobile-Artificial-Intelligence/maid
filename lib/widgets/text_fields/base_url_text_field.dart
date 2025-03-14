part of 'package:maid/main.dart';

class BaseUrlTextField extends StatelessWidget {
  final RemoteArtificialIntelligenceController aiController;

  const BaseUrlTextField({
    super.key, 
    required this.aiController,
  });

  void onChanged(BuildContext context, String value) {
    if (kIsWeb  && value.contains('localhost')) {
      showDialog(
        context: context,
        builder: exceptionBuilder,
      );
    }

    aiController.baseUrl = value;
  }

  Widget exceptionBuilder(BuildContext context) => ErrorDialog(
    exception: PlatformException(
      code: 'localhost', 
      message: 'localhost is not allowed on web'
    ),
  );

  @override
  Widget build(BuildContext context) => ListenableTextField(
    listenable: aiController,
    selector: () => aiController.baseUrl, 
    onChanged: (value) => onChanged(context, value),
    labelText: AppLocalizations.of(context)!.baseUrl,
    requireSave: true,
  );
}