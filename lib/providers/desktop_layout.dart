import 'package:flutter/material.dart';

class DesktopLayout extends ChangeNotifier {
  bool _sidePanelOpen = true;
  bool _terminalOpen = false;

  bool get sidePanelOpen => _sidePanelOpen;
  bool get terminalOpen => _terminalOpen;

  void toggleSidePanel() {
    _sidePanelOpen = !_sidePanelOpen;
    notifyListeners();
  }

  void toggleTerminal() {
    _terminalOpen = !_terminalOpen;
    notifyListeners();
  }
}