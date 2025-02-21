part of 'package:maid/main.dart';

extension PlatformExtension on Platform {
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  static bool get isDesktop => Platform.isWindows || Platform.isLinux || Platform.isMacOS;
}