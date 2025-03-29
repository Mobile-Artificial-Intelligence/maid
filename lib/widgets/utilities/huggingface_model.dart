part of 'package:maid/main.dart';

class HuggingfaceModel extends StatelessWidget {
  final String name;
  final double size;
  final double parameters; // Billions of parameters

  const HuggingfaceModel({super.key, required this.name, required this.size, required this.parameters});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceBright,
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: buildColumn(context),
  );

  Widget buildColumn(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildTitle(context),
      Text(
        '${AppLocalizations.of(context)!.size}: ${size.toString()} GB',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      Text(
        '${AppLocalizations.of(context)!.parameters}: ${parameters.toString()} B',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      Divider(
        height: 10,
        color: Theme.of(context).colorScheme.outline,
      ),
      Center(
        child: TextButton.icon(
          onPressed: () => print('Butoon pressed'), // TODO: Implement download
          label: Text(
            AppLocalizations.of(context)!.downloadModel,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          icon: Icon(
            Icons.download,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        )
      )
    ],
  );

  Widget buildTitle(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        IconButton(
          onPressed: () => print('Link button pressed'), // TODO: Implement link
          iconSize: 20,
          icon: Icon(
            Icons.launch,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        )
      ],
    )
  );
}