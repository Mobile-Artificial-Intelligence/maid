part of 'package:maid/main.dart';

class SystemSettings extends StatelessWidget {
  const SystemSettings({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        AppLocalizations.of(context)!.systemSettings,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      ListenableTextField<AppSettings>(
        listenable: AppSettings.instance,
        selector: () => AppSettings.instance.systemPrompt,
        onChanged: AppSettings.instance.setSystemPrompt,
        labelText: AppLocalizations.of(context)!.systemPrompt,
        keyboardType: TextInputType.multiline,
        maxLines: null
      ),
      const SizedBox(height: 8),
      LocaleDropdown(),
      const SizedBox(height: 8),
      ThemeModeDropdown(),
      const SizedBox(height: 8),
      Text(
        AppLocalizations.of(context)!.themeSeedColor,
        style: Theme.of(context).textTheme.labelLarge,
      ),
      const SizedBox(height: 4),
      buildColorPicker(),
    ],
  );

  Widget buildColorPicker() => ListenableBuilder(
    listenable: AppSettings.instance,
    builder: (context, child) => HueRingPicker(
      portraitOnly: true,
      displayThumbColor: false,
      pickerColor: AppSettings.instance.seedColor, 
      onColorChanged: (newColor) => AppSettings.instance.seedColor = newColor,
    ),
  );
}