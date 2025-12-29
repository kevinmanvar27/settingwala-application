import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Helper class for handling file access permissions
class PermissionHelper {
  /// Request storage/file access permission
  /// Returns true if permission is granted
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Android 13+ (API 33+) uses granular media permissions
      if (await _isAndroid13OrHigher()) {
        final photos = await Permission.photos.request();
        final videos = await Permission.videos.request();
        
        return photos.isGranted || videos.isGranted;
      } else {
        // Android 12 and below
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted || status.isLimited;
    }
    return true;
  }

  /// Check if storage permission is granted
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

  /// Request all media permissions (photos, videos, audio)
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

  /// Show permission denied dialog with option to open settings
  static Future<void> showPermissionDeniedDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'File access permission is required to use this feature. '
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

  /// Check if device is Android 13 or higher
  static Future<bool> _isAndroid13OrHigher() async {
    if (!Platform.isAndroid) return false;
    // Android 13 is API level 33
    // We use permission_handler's built-in check
    return await Permission.photos.status != PermissionStatus.permanentlyDenied ||
           await Permission.photos.request() != PermissionStatus.permanentlyDenied;
  }
}
