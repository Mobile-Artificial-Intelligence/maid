part of 'package:maid/main.dart';

class RemoteModelTextField extends StatelessWidget {
  const RemoteModelTextField({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: RemoteArtificialIntelligenceController.instance!,
    builder: buildRow,
  );

  Widget buildRow(BuildContext context, Widget? child) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: RemoteArtificialIntelligenceController.instance!.customModel
          ? buildCustom(context)
          : buildNormal(context),
      ),
      const SizedBox(width: 8),
      Switch(
        value: RemoteArtificialIntelligenceController.instance!.customModel,
        onChanged: (value) => RemoteArtificialIntelligenceController.instance!.customModel = value,
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
    listenable: RemoteArtificialIntelligenceController.instance!,
    selector: () => RemoteArtificialIntelligenceController.instance!.model,
    onChanged: (value) => RemoteArtificialIntelligenceController.instance!.model = value,
    labelText: AppLocalizations.of(context)!.remoteModel,
    requireSave: true,
  );
}