import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:maid/static/logger.dart';
import 'package:permission_handler/permission_handler.dart';

class Networking {
  static Future<bool> getNearbyDevicesPermission() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return true;
    }
    
    // Get sdk version
    final sdk = await DeviceInfoPlugin().androidInfo.then((value) => value.version.sdkInt);
    var permissions = <Permission>[]; // List of permissions to request

    if (sdk <= 32) {
      // ACCESS_FINE_LOCATION is required
      permissions.add(Permission.location);
    } else {
      // NEARBY_WIFI_DEVICES is required
      permissions.add(Permission.nearbyWifiDevices);
    }

    // Request permissions and check if all are granted
    Map<Permission, PermissionStatus> statuses = await permissions.request();
    bool allPermissionsGranted = statuses.values.every((status) => status.isGranted);

    if (allPermissionsGranted) {
      Logger.log("Nearby Devices - permission granted");
      return true;
    } else {
      Logger.log("Nearby Devices - permission denied");
      return false;
    }
  }
}