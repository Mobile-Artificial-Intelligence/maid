part of 'package:maid/main.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        AppLocalizations.of(context)!.aboutTitle
      ),
    ),
    body: buildBody(context),
  );

  Widget buildBody(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: buildColumn(context)
  );

  Widget buildColumn(BuildContext context) => Column(
    children: [
      const SizedBox(height: 20.0),
      Image.asset(
        "images/logo.png",
        width: 150,
        height: 150,
      ),
      const SizedBox(height: 30.0),
      Text(
        AppLocalizations.of(context)!.appTitle,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 20.0),
      Text(
        AppLocalizations.of(context)!.aboutContent,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 20.0),
      Text(
        AppLocalizations.of(context)!.leadMaintainer,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Text(
        'Dane Madsen',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    ]
  );
}