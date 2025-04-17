part of 'package:maid/main.dart';

class RemoteModelTextField extends StatelessWidget {
  static ValueNotifier<bool> useCustomModel = ValueNotifier(false);

  const RemoteModelTextField({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: RemoteAIController.instance!,
    builder: buildListener,
  );

  Widget buildListener(BuildContext context, Widget? child) => ListenableBuilder(
    listenable: useCustomModel,
    builder: buildRow,
  );

  Widget buildRow(BuildContext context, Widget? child) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: useCustomModel.value
          ? buildCustom(context)
          : buildNormal(context),
      ),
      const SizedBox(width: 8),
      Switch(
        value: useCustomModel.value,
        onChanged: (value) => useCustomModel.value = value,
      ),
    ],
  );

  Widget buildNormal(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        AppLocalizations.of(context)!.remoteModel,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      RemoteModelDropdown(
        refreshButton: true,
      ),
    ],
  );


  Widget buildCustom(BuildContext context) => ListenableTextField(
    listenable: RemoteAIController.instance!,
    selector: () => RemoteAIController.instance!.model,
    onChanged: (value) => RemoteAIController.instance!.model = value,
    labelText: AppLocalizations.of(context)!.remoteModel,
    requireSave: true,
  );
}