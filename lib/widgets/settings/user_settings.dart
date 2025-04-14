part of 'package:maid/main.dart';

class UserSettings extends StatelessWidget {
  const UserSettings({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        AppLocalizations.of(context)!.userSettings,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      ListenableBuilder(
        listenable: AppSettings.instance,
        builder: userImageBuilder,
      ),
      const SizedBox(height: 8),
      ElevatedButton(
        onPressed: AppSettings.instance.loadUserImage, 
        child: Text(AppLocalizations.of(context)!.loadUserImage),
      ),
      const SizedBox(height: 8),
      ListenableTextField<AppSettings>(
        listenable: AppSettings.instance,
        selector: () => AppSettings.instance.userName,
        onChanged: AppSettings.instance.setUserName,
        labelText: AppLocalizations.of(context)!.userName,
      ),
    ],
  );

  Widget userImageBuilder(BuildContext context, Widget? child) {
    if (AppSettings.instance.userImage == null) {
      return Icon(
        Icons.person, 
        size: 50,
        color: Theme.of(context).colorScheme.onSurface
      );
    }

    return CircleAvatar(
      radius: 50,
      backgroundImage: MemoryImage(AppSettings.instance.userImage!),
    );
  }
}