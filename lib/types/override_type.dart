part of 'package:maid/main.dart';

enum OverrideType {
  int,
  double,
  string,
  bool,
  json;

  String getLocale(BuildContext context) {
    switch (this) {
      case OverrideType.int:
        return AppLocalizations.of(context)!.overrideTypeInteger;
      case OverrideType.double:
        return AppLocalizations.of(context)!.overrideTypeDouble;
      case OverrideType.string:
        return AppLocalizations.of(context)!.overrideTypeString;
      case OverrideType.bool:
        return AppLocalizations.of(context)!.overrideTypeBoolean;
      case OverrideType.json:
        return "JSON";
    }
  }
}