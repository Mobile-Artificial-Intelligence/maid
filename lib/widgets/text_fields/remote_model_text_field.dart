part of 'package:maid/main.dart';

class RemoteModelTextField extends StatelessWidget {
  final RemoteArtificialIntelligenceController ai;

  const RemoteModelTextField({
    super.key,
    required this.ai,
  });

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: ai,
    builder: buildRow,
  );

  Widget buildRow(BuildContext context, Widget? child) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: ai.customModel
          ? buildCustom(context)
          : buildNormal(context),
      ),
      const SizedBox(width: 8),
      Switch(
        value: ai.customModel,
        onChanged: (value) => ai.customModel = value,
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
        ai: ai,
      ),
    ],
  );


  Widget buildCustom(BuildContext context) => ListenableTextField(
    listenable: ai,
    selector: () => ai.model,
    onChanged: (value) => ai.model = value,
    labelText: AppLocalizations.of(context)!.remoteModel,
    requireSave: true,
  );
}