import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<int> _getAndroidSdkInt() async {
    if (!Platform.isAndroid) return 0;
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    return deviceInfo.version.sdkInt;
  }

  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      throw Exception('Camera permission is permanently denied. Please enable it in app settings.');
    } else {
      throw Exception('Camera permission is required.');
    }
  }

  static Future<bool> requestGalleryPermission() async {
    if (Platform.isIOS) {
      final status = await Permission.photos.request();

      if (status.isGranted) return true;

      if (status.isPermanentlyDenied) {
        await openAppSettings();
        throw Exception('Photo access is permanently denied. Please enable it in app settings.');
      } else {
        throw Exception('Photo access is required.');
      }
    } else if (Platform.isAndroid) {
      final sdkInt = await _getAndroidSdkInt();

      if (sdkInt >= 33) {
        final photos = await Permission.photos.request();
        final videos = await Permission.videos.request();

        if (photos.isGranted || videos.isGranted) return true;

        if (photos.isPermanentlyDenied || videos.isPermanentlyDenied) {
          await openAppSettings();
          throw Exception('Gallery access is permanently denied. Please enable it in app settings.');
        } else {
          throw Exception('Gallery access is required.');
        }
      } else {
        final status = await Permission.storage.request();

        if (status.isGranted) return true;

        if (status.isPermanentlyDenied) {
          await openAppSettings();
          throw Exception('Storage access is permanently denied. Please enable it in app settings.');
        } else {
          throw Exception('Storage access is required.');
        }
      }
    }
    return false;
  }

  static Future<bool> requestLocationPermission({bool background = false}) async {
    final sdkInt = await _getAndroidSdkInt();

    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      if (background && Platform.isAndroid && sdkInt >= 29) {
        final backgroundStatus = await Permission.locationAlways.request();
        if (backgroundStatus.isGranted) return true;

        if (backgroundStatus.isPermanentlyDenied) {
          await openAppSettings();
          throw Exception('Background location permission is permanently denied. Please enable it in app settings.');
        } else {
          throw Exception('Background location permission is required.');
        }
      }
      return true;
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      throw Exception('Location permission is permanently denied. Please enable it in app settings.');
    } else {
      throw Exception('Location permission is required.');
    }
  }

  static Future<bool> areAllPermissionsGranted() async {
    final camera = await Permission.camera.status;
    final gallery = Platform.isIOS ? await Permission.photos.status : await Permission.storage.status;
    final location = await Permission.locationWhenInUse.status;

    return camera.isGranted && gallery.isGranted && location.isGranted;
  }
}
