import 'package:flutter/material.dart';
import 'package:maid/enumerators/side_panel_route.dart';

class DesktopLayout extends ChangeNotifier {
  bool _sidePanelOpen = true;
  bool _terminalOpen = false;
  bool _settingsOpen = false;

  SidePanelRoute _sidePanelRoute = SidePanelRoute.sessions;

  bool get sidePanelOpen => _sidePanelOpen;
  bool get terminalOpen => _terminalOpen;
  bool get settingsOpen => _settingsOpen;

  SidePanelRoute get sidePanelRoute => _sidePanelRoute;

  void toggleSidePanel() {
    _sidePanelOpen = !_sidePanelOpen;
    notifyListeners();
  }

  void toggleTerminal() {
    _terminalOpen = !_terminalOpen;
    notifyListeners();
  }

  void toggleSettings() {
    _settingsOpen = !_settingsOpen;
    notifyListeners();
  }

  void navigateSidePanel(SidePanelRoute route) {
    if (_sidePanelRoute != route) {
      _sidePanelRoute = route;
      notifyListeners();
    }
  }
}