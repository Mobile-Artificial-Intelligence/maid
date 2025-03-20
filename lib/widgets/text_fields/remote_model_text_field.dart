part of 'package:maid/main.dart';

class RemoteModelTextField extends StatelessWidget {
  final RemoteArtificialIntelligenceController aiController;

  const RemoteModelTextField({
    super.key,
    required this.aiController,
  });

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: aiController,
    builder: buildRow,
  );

  Widget buildRow(BuildContext context, Widget? child) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: aiController.customModel
          ? buildCustom(context)
          : buildNormal(context),
      ),
      const SizedBox(width: 8),
      Switch(
        value: aiController.customModel,
        onChanged: (value) => aiController.customModel = value,
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
        aiController: aiController,
      ),
    ],
  );


  Widget buildCustom(BuildContext context) => ListenableTextField(
    listenable: aiController,
    selector: () => aiController.model,
    onChanged: (value) => aiController.model = value,
    labelText: AppLocalizations.of(context)!.remoteModel,
    requireSave: true,
  );
}