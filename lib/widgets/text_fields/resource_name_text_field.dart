part of 'package:maid/main.dart';

class ResourceNameTextField extends StatelessWidget {
  const ResourceNameTextField({super.key});

  void onChanged(String value) {
    if (AzureOpenAIController.instance != null) {
      try {
        AzureOpenAIController.instance!.resourceName = value.isEmpty ? null : value;
      } catch (e) {
        // Handle validation error - the controller will throw if invalid
        // The UI will show the error through validation
      }
    }
  }

  @override
  Widget build(BuildContext context) => AzureOpenAIController.instance != null
      ? ListenableTextField(
          listenable: AzureOpenAIController.instance!,
          selector: () => AzureOpenAIController.instance!.resourceName,
          onChanged: onChanged,
          labelText: AppLocalizations.of(context)!.resourceName,
          requireSave: true,
        )
      : const SizedBox.shrink();
}