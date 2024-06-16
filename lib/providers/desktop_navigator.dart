import 'package:flutter/material.dart';
import 'package:maid/ui/desktop/widgets/settings_panels/user_panel.dart';
import 'package:maid/ui/desktop/widgets/side_panels/characters_panel.dart';
import 'package:maid/ui/desktop/widgets/side_panels/model_settings_panel.dart';
import 'package:maid/ui/desktop/widgets/side_panels/sessions_panel.dart';
import 'package:maid/ui/shared/pages/character_customization_page.dart';
import 'package:provider/provider.dart';

class DesktopNavigator extends ChangeNotifier {
  bool _sidePanelOpen = true;

  Widget Function(BuildContext) _sidePanelRoute = (context) => const SessionsPanel();

  Widget Function(BuildContext)? _settingsPanelRoute;

  final Map<String, Widget Function(BuildContext)> _sidePanelRoutes = {
    "/sessions": (context) => const SessionsPanel(),
    "/character": (context) => const CharacterCustomizationPage(),
    "/characters": (context) => const CharactersPanel(),
    "/model-settings": (context) => const ModelSettingsPanel(),
  };

  final Map<String, Widget Function(BuildContext)> _settingsPanelRoutes = {
    "/user-settings": (context) => const UserPanel(),
  };

  bool get sidePanelOpen => _sidePanelOpen;

  Widget Function(BuildContext) get sidePanelRoute => _sidePanelRoute;

  Widget Function(BuildContext)? get settingsPanelRoute => _settingsPanelRoute;

  static DesktopNavigator of(BuildContext context) => Provider.of<DesktopNavigator>(context, listen: false);

  void toggleSidePanel() {
    _sidePanelOpen = !_sidePanelOpen;
    notifyListeners();
  }

  void navigateSidePanel(String route) {
    if (_sidePanelRoute != _sidePanelRoutes[route]) {
      _sidePanelRoute = _sidePanelRoutes[route] ?? _sidePanelRoute;
      notifyListeners();
    }
  }

  void navigateSettingsPanel(String route) {
    if (_settingsPanelRoute != _settingsPanelRoutes[route]) {
      _settingsPanelRoute = _settingsPanelRoutes[route] ?? _settingsPanelRoute;
    }
    else {
      _settingsPanelRoute = null;
    }
    notifyListeners();
  }
}