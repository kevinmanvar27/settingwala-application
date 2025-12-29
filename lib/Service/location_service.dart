import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  // Nominatim OpenStreetMap API (Free, no API key required)
  static const String _nominatimUrl = 'https://nominatim.openstreetmap.org/search';

  /// Search locations using Nominatim OpenStreetMap API (Free)
  /// Returns real location suggestions based on user input
  static Future<List<LocationSuggestion>> searchLocations(String query) async {
    if (query.trim().isEmpty || query.length < 2) {
      return [];
    }

    try {
      final uri = Uri.parse(_nominatimUrl).replace(
        queryParameters: {
          'q': query,
          'format': 'json',
          'addressdetails': '1',
          'limit': '10',
          'countrycodes': 'in', // Restrict to India
          'accept-language': 'en',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'SettingwalaApp/1.0', // Required by Nominatim
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        if (data.isEmpty) {
          return [];
        }

        return data.map((place) {
          final displayName = place['display_name'] as String? ?? '';
          final type = place['type'] as String? ?? '';
          final addressDetails = place['address'] as Map<String, dynamic>? ?? {};
          
          // Extract address components
          final city = addressDetails['city']?.toString() ?? 
                       addressDetails['town']?.toString() ?? 
                       addressDetails['village']?.toString() ?? 
                       addressDetails['county']?.toString() ?? '';
          final state = addressDetails['state']?.toString() ?? '';
          final suburb = addressDetails['suburb']?.toString() ?? '';
          final neighbourhood = addressDetails['neighbourhood']?.toString() ?? '';
          
          // Create main text (shorter, more readable)
          String mainText = '';
          if (suburb.isNotEmpty) {
            mainText = suburb;
          } else if (neighbourhood.isNotEmpty) {
            mainText = neighbourhood;
          } else if (city.isNotEmpty) {
            mainText = city;
          } else {
            mainText = displayName.split(',').first.trim();
          }
          
          // Create secondary text
          List<String> secondaryParts = [];
          if (city.isNotEmpty && city != mainText) secondaryParts.add(city);
          if (state.isNotEmpty) secondaryParts.add(state);
          String secondaryText = secondaryParts.join(', ');
          
          // Determine location type
          LocationType locationType = _getLocationTypeFromOSMType(type);
          
          return LocationSuggestion(
            displayName: displayName,
            mainText: mainText,
            secondaryText: secondaryText,
            placeId: place['place_id']?.toString() ?? '',
            type: locationType,
          );
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Determine LocationType from OpenStreetMap type
  static LocationType _getLocationTypeFromOSMType(String type) {
    switch (type.toLowerCase()) {
      case 'city':
      case 'town':
      case 'village':
        return LocationType.city;
      case 'county':
      case 'state_district':
      case 'district':
        return LocationType.district;
      case 'suburb':
      case 'neighbourhood':
      case 'residential':
      case 'quarter':
        return LocationType.area;
      case 'station':
      case 'airport':
      case 'bus_station':
      case 'railway':
      case 'attraction':
      case 'monument':
        return LocationType.landmark;
      default:
        return LocationType.locality;
    }
  }
}

/// Location suggestion model
class LocationSuggestion {
  final String displayName;
  final String mainText;
  final String secondaryText;
  final String placeId;
  final LocationType type;

  LocationSuggestion({
    required this.displayName,
    required this.mainText,
    required this.secondaryText,
    required this.placeId,
    required this.type,
  });

  /// Get the value to be sent to API
  String get apiValue => displayName;

  @override
  String toString() => displayName;
}

/// Location type enum
enum LocationType {
  city,
  district,
  area,
  landmark,
  locality,
}
