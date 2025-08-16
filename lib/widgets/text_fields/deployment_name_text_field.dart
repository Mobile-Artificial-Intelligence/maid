part of 'package:maid/main.dart';

class DeploymentNameTextField extends StatelessWidget {
  const DeploymentNameTextField({super.key});

  void onChanged(String value) {
    if (AzureOpenAIController.instance != null) {
      try {
        AzureOpenAIController.instance!.deploymentName = value.isEmpty ? null : value;
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
          selector: () => AzureOpenAIController.instance!.deploymentName,
          onChanged: onChanged,
          labelText: AppLocalizations.of(context)!.deploymentName,
          requireSave: true,
        )
      : const SizedBox.shrink();
}