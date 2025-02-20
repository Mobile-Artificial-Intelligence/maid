part of 'package:maid/main.dart';

class SystemSettings extends StatelessWidget {
  const SystemSettings({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        'System Settings',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      SelectorTextField<AppSettings>(
        selector: (context, settings) => settings.systemPrompt,
        onChanged: AppSettings.of(context).setSystemPrompt,
        labelText: 'System Prompt',
        keyboardType: TextInputType.multiline,
        maxLines: null
      ),
      const SizedBox(height: 8),
      ThemeModeDropdown(),
      const SizedBox(height: 8),
      Text(
        'Theme Seed Color',
        style: Theme.of(context).textTheme.labelLarge,
      ),
      const SizedBox(height: 4),
      buildColorPicker(),
    ],
  );

  Widget buildColorPicker() => Selector<AppSettings, Color>(
    selector: (context, settings) => settings.seedColor,
    builder: (context, color, child) => ColorPicker(
      pickerColor: color, 
      onColorChanged: (newColor) => AppSettings.of(context).seedColor = newColor,
    ),
  );
}