part of 'package:maid/main.dart';

class BaseUrlTextField extends StatelessWidget {
  const BaseUrlTextField({super.key});

  void onChanged(BuildContext context, String value) {
    if (kIsWeb  && value.contains('localhost')) {
      showDialog(
        context: context,
        builder: exceptionBuilder,
      );
    }

    RemoteArtificialIntelligenceController.instance!.baseUrl = value;
  }

  Widget exceptionBuilder(BuildContext context) => ErrorDialog(
    exception: PlatformException(
      code: 'localhost', 
      message: 'localhost is not allowed on web'
    ),
  );

  @override
  Widget build(BuildContext context) => ListenableTextField(
    listenable: RemoteArtificialIntelligenceController.instance!,
    selector: () => RemoteArtificialIntelligenceController.instance!.baseUrl, 
    onChanged: (value) => onChanged(context, value),
    labelText: AppLocalizations.of(context)!.baseUrl,
    requireSave: true,
  );
}