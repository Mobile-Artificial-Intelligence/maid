import 'package:flutter/material.dart';
import 'package:maid/ui/desktop/widgets/side_panels/characters_panel.dart';
import 'package:maid/ui/desktop/widgets/side_panels/sessions_panel.dart';
import 'package:provider/provider.dart';

class DesktopNavigator extends ChangeNotifier {
  bool _sidePanelOpen = true;
  bool _settingsPanelOpen = false;

  Widget Function(BuildContext) _sidePanelRoute = (context) => const SessionsPanel();

  final Map<String, Widget Function(BuildContext)> _sidePanelRoutes = {
    "/sessions": (context) => const SessionsPanel(),
    "/characters": (context) => const CharactersPanel()
  };

  bool get sidePanelOpen => _sidePanelOpen;
  bool get settingsPanelOpen => _settingsPanelOpen;

  Widget Function(BuildContext) get sidePanelRoute => _sidePanelRoute;

  static DesktopNavigator of(BuildContext context) => Provider.of<DesktopNavigator>(context, listen: false);

  void toggleSidePanel() {
    _sidePanelOpen = !_sidePanelOpen;
    notifyListeners();
  }

  void toggleSettingsPanel() {
    _settingsPanelOpen = !_settingsPanelOpen;
    notifyListeners();
  }

  void navigateSidePanel(String route) {
    if (_sidePanelRoute != _sidePanelRoutes[route]) {
      _sidePanelRoute = _sidePanelRoutes[route] ?? _sidePanelRoute;
      notifyListeners();
    }
  }
}