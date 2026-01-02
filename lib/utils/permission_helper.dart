import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class PermissionHelper {


  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await _isAndroid13OrHigher()) {
        final photos = await Permission.photos.request();
        final videos = await Permission.videos.request();

        return photos.isGranted || videos.isGranted;
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted || status.isLimited;
    }
    return true;
  }

  static Future<bool> hasStoragePermission() async {
    if (Platform.isAndroid) {
      if (await _isAndroid13OrHigher()) {
        return await Permission.photos.isGranted ||
            await Permission.videos.isGranted;
      } else {
        return await Permission.storage.isGranted;
      }
    } else if (Platform.isIOS) {
      final status = await Permission.photos.status;
      return status.isGranted || status.isLimited;
    }
    return true;
  }

  static Future<Map<Permission, PermissionStatus>> requestAllMediaPermissions() async {
    if (Platform.isAndroid && await _isAndroid13OrHigher()) {
      return await [
        Permission.photos,
        Permission.videos,
        Permission.audio,
      ].request();
    } else if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return {Permission.storage: status};
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return {Permission.photos: status};
    }
    return {};
  }


  static Future<bool> requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  static Future<bool> hasLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  static Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) return null;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      return position;
    } catch (e) {
      
      return null;
    }
  }


  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> hasCameraPermission() async {
    return await Permission.camera.isGranted;
  }


  static Future<Map<String, bool>> requestAllAppPermissions() async {
    Map<String, bool> results = {};

    results['camera'] = await requestCameraPermission();

    results['gallery'] = await requestStoragePermission();

    results['location'] = await requestLocationPermission();

    
    return results;
  }

  static Future<Map<String, bool>> checkAllPermissions() async {
    return {
      'camera': await hasCameraPermission(),
      'gallery': await hasStoragePermission(),
      'location': await hasLocationPermission(),
    };
  }


  static Future<void> showPermissionDeniedDialog(BuildContext context, {String? permissionName}) async {
    final name = permissionName ?? 'Required';
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$name Permission Required'),
        content: Text(
          '$name permission is required to use this feature. '
              'Please grant permission in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  static Future<void> showLocationServicesDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Services Disabled'),
        content: const Text(
          'Location services are disabled. Please enable GPS in your device settings to use this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openLocationSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }


  static Future<bool> _isAndroid13OrHigher() async {
    if (!Platform.isAndroid) return false;
    return await Permission.photos.status != PermissionStatus.permanentlyDenied ||
        await Permission.photos.request() != PermissionStatus.permanentlyDenied;
  }
}
