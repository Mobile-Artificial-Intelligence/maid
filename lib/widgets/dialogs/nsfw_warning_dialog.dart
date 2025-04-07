part of 'package:maid/main.dart';

class NsfwWarningDialog extends StatelessWidget {
  const NsfwWarningDialog({super.key});

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: Theme.of(context).colorScheme.onError,
    title: Text(
      AppLocalizations.of(context)!.warning,
      textAlign: TextAlign.center,
    ),
    content: ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 400,
      ),
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
        child: Text(AppLocalizations.of(context)!.proceed),
      ),
    ],
  );
}