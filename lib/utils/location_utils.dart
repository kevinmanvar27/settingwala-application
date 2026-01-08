import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;

class LocationUtils {
  static const double earthRadiusInKilometers = 6371.0;

  /// Calculate distance between two coordinates in kilometers
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    final lat1Rad = lat1 * pi / 180;
    final lat2Rad = lat2 * pi / 180;
    final deltaLatRad = (lat2 - lat1) * pi / 180;
    final deltaLonRad = (lon2 - lon1) * pi / 180;

    final a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(deltaLonRad / 2) * sin(deltaLonRad / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusInKilometers * c;
  }

  /// Get current location
  static Future<Position?> getCurrentLocation() async {
    try {
      final location = loc.Location();
      final hasPermission = await location.hasPermission();
      
      if (hasPermission == loc.PermissionStatus.denied) {
        await location.requestPermission();
      }

      if (await location.serviceEnabled()) {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      } else {
        // Request to enable location services
        await location.requestService();
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      }
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission
  static Future<bool> checkLocationPermission() async {
    final location = loc.Location();
    final permission = await location.hasPermission();
    
    if (permission == loc.PermissionStatus.denied ||
        permission == loc.PermissionStatus.deniedForever) {
      final result = await location.requestPermission();
      return result == loc.PermissionStatus.granted;
    }
    
    return permission == loc.PermissionStatus.granted;
  }
}