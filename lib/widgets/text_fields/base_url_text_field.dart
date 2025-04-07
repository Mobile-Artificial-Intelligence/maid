part of 'package:maid/main.dart';

class BaseUrlTextField extends StatelessWidget {
  final RemoteArtificialIntelligenceController ai;

  const BaseUrlTextField({
    super.key, 
    required this.ai,
  });

  void onChanged(BuildContext context, String value) {
    if (kIsWeb  && value.contains('localhost')) {
      showDialog(
        context: context,
        builder: exceptionBuilder,
      );
    }

    ai.baseUrl = value;
  }

  Widget exceptionBuilder(BuildContext context) => ErrorDialog(
    exception: PlatformException(
      code: 'localhost', 
      message: 'localhost is not allowed on web'
    ),
  );

  @override
  Widget build(BuildContext context) => ListenableTextField(
    listenable: ai,
    selector: () => ai.baseUrl, 
    onChanged: (value) => onChanged(context, value),
    labelText: AppLocalizations.of(context)!.baseUrl,
    requireSave: true,
  );
}