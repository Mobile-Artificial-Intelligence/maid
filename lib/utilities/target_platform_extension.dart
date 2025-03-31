part of 'package:maid/main.dart';

extension TargetPlatformExtension on TargetPlatform {
  static bool get isMobile => defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;

  static bool get isDesktop => defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.linux;
}