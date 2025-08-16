part of 'package:maid/main.dart';

class ApiVersionDropdown extends StatelessWidget {
  static const List<String> supportedApiVersions = [
    // Control plane (latest)
    '2024-10-01',
    '2024-06-01-preview',

    // Data plane – Authoring & Inference
    '2024-10-21',
    '2025-04-01-preview',

    // .NET SDK preview versions
    '2024-08-01-preview',
    '2024-09-01-preview',
    '2024-10-01-preview',
    '2024-12-01-preview',
    '2025-01-01-preview',
    '2025-03-01-preview',

    // Legacy API versions (for backward compatibility)
    '2023-03-15-preview',
    '2022-12-01',
    '2023-05-15',
    '2023-06-01-preview',
    '2023-07-01-preview',
    '2023-08-01-preview',
    '2023-09-01-preview',
    '2023-12-01-preview',
    '2024-02-15-preview',
  ];

  const ApiVersionDropdown({super.key});

  void onSelected(String? apiVersion) {
    if (AzureOpenAIController.instance != null) {
      AzureOpenAIController.instance!.apiVersion = apiVersion;
    }
  }

  @override
  Widget build(BuildContext context) => AzureOpenAIController.instance != null
      ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.apiVersion,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            PopupMenuButton<String>(
              tooltip: AppLocalizations.of(context)!.apiVersion,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AzureOpenAIController.instance!.apiVersion ??
                        supportedApiVersions.first,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 24,
                  ),
                ],
              ),
              itemBuilder: (context) => supportedApiVersions
                  .map((version) => PopupMenuItem(
                        value: version,
                        child: Text(version),
                        onTap: () => onSelected(version),
                      ))
                  .toList(),
            ),
          ],
        )
      : const SizedBox.shrink();
}
