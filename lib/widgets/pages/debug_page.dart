part of 'package:maid/main.dart';

class DebugPage extends StatelessWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Debug',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildColorLabel(context, "primary", Theme.of(context).colorScheme.primary),
            buildColorLabel(context, "onPrimary", Theme.of(context).colorScheme.onPrimary),
            buildColorLabel(context, "primaryContainer", Theme.of(context).colorScheme.primaryContainer),
            buildColorLabel(context, "onPrimaryContainer", Theme.of(context).colorScheme.onPrimaryContainer),
            buildColorLabel(context, "secondary", Theme.of(context).colorScheme.secondary),
            buildColorLabel(context, "onSecondary", Theme.of(context).colorScheme.onSecondary),
            buildColorLabel(context, "secondaryContainer", Theme.of(context).colorScheme.secondaryContainer),
            buildColorLabel(context, "onSecondaryContainer", Theme.of(context).colorScheme.onSecondaryContainer),
            buildColorLabel(context, "tertiary", Theme.of(context).colorScheme.tertiary),
            buildColorLabel(context, "onTertiary", Theme.of(context).colorScheme.onTertiary),
            buildColorLabel(context, "tertiaryContainer", Theme.of(context).colorScheme.tertiaryContainer),
            buildColorLabel(context, "onTertiaryContainer", Theme.of(context).colorScheme.onTertiaryContainer),
            buildColorLabel(context, "error", Theme.of(context).colorScheme.error),
            buildColorLabel(context, "onError", Theme.of(context).colorScheme.onError),
            buildColorLabel(context, "errorContainer", Theme.of(context).colorScheme.errorContainer),
            buildColorLabel(context, "onErrorContainer", Theme.of(context).colorScheme.onErrorContainer),
            buildColorLabel(context, "surface", Theme.of(context).colorScheme.surface),
            buildColorLabel(context, "onSurface", Theme.of(context).colorScheme.onSurface),
            buildColorLabel(context, "onSurfaceVariant", Theme.of(context).colorScheme.onSurfaceVariant),
            buildColorLabel(context, "outline", Theme.of(context).colorScheme.outline),
            buildColorLabel(context, "inverseSurface", Theme.of(context).colorScheme.inverseSurface),
            buildColorLabel(context, "onInverseSurface", Theme.of(context).colorScheme.onInverseSurface),
            buildColorLabel(context, "inversePrimary", Theme.of(context).colorScheme.inversePrimary),
            buildColorLabel(context, "shadow", Theme.of(context).colorScheme.shadow),
            buildColorLabel(context, "surfaceTint", Theme.of(context).colorScheme.surfaceTint),
            buildColorLabel(context, "outlineVariant", Theme.of(context).colorScheme.outlineVariant),
            buildColorLabel(context, "scrim", Theme.of(context).colorScheme.scrim),
          ],
        ),
      ),
    );
  }

  Widget buildColorLabel(BuildContext context, String label, Color color) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label),
      Container(
        width: 100,
        height: 20,
        color: color,
      ),
    ],
  );
}