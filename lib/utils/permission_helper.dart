import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionHelper {
  // Request storage permission
  static Future<bool> requestStoragePermission() async {
    // Check and request storage permission
    PermissionStatus status = await Permission.storage.request();

    if (status.isGranted) {
      // Permission granted
      return true;
    } else if (status.isDenied) {
      // Permission denied, show a custom message
      return false;
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, prompt the user to enable it manually
      openAppSettings(); // This opens the app settings where the user can enable permissions manually
      return false;
    }
    return false;
  }
}
