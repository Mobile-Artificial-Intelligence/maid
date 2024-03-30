import 'package:flutter/material.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/ui/mobile/widgets/tiles/slider_list_tile.dart';
import 'package:provider/provider.dart';

class NKeepParameter extends StatelessWidget {
  const NKeepParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (context, session, child) {
      return SliderListTile(
          labelText: 'n_keep',
          inputValue: session.model.nKeep,
          sliderMin: 1.0,
          sliderMax: 1024.0,
          sliderDivisions: 1023,
          onValueChanged: (value) {
            session.model.nKeep = value.round();
            session.notify();
          }
        );
      }
    );
  }
}
