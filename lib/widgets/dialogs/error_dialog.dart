part of 'package:maid/main.dart';

class ErrorDialog extends StatelessWidget {
  final dynamic exception;

  const ErrorDialog({
    super.key,
    required this.exception,
  });

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      'An error occurred',
      textAlign: TextAlign.center,
    ),
    content: SingleChildScrollView(
      child: CodeBox(
        label: 'Error',
        code: exception.toString()
      )
    ),
    actionsAlignment: MainAxisAlignment.center,
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text('OK'),
      ),
    ],
  );
}