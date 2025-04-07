part of 'package:maid/main.dart';

class NsfwWarningDialog extends StatelessWidget {
  const NsfwWarningDialog({super.key});

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      AppLocalizations.of(context)!.warning,
      textAlign: TextAlign.center,
    ),
    content: SingleChildScrollView(
      child: Text(
        AppLocalizations.of(context)!.nsfwWarning,
        textAlign: TextAlign.center,
      ),
    ),
    actionsAlignment: MainAxisAlignment.center,
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(false),
        child: Text(AppLocalizations.of(context)!.cancel),
      ),
      TextButton(
        onPressed: () => Navigator.of(context).pop(true),
        child: Text(AppLocalizations.of(context)!.ok),
      ),
    ],
  );
}