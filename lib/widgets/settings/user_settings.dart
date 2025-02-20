part of 'package:maid/main.dart';

class UserSettings extends StatelessWidget {
  const UserSettings({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        'User Settings',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      Selector<AppSettings, File?>(
        selector: (context, settings) => settings.userImage,
        builder: userImageBuilder,
      ),
      const SizedBox(height: 8),
      ElevatedButton(
        onPressed: AppSettings.of(context).loadUserImage, 
        child: const Text('Load User Image')
      ),
      const SizedBox(height: 8),
      SelectorTextField<AppSettings>(
        selector: (context, settings) => settings.userName,
        onChanged: AppSettings.of(context).setUserName,
        labelText: 'User Name',
      ),
    ],
  );

  Widget userImageBuilder(BuildContext context, File? image, Widget? child) {
    if (image == null) {
      return Icon(
        Icons.person, 
        size: 50,
        color: Theme.of(context).colorScheme.onSurface
      );
    }

    return CircleAvatar(
      radius: 50,
      backgroundImage: FileImage(image),
    );
  }
}