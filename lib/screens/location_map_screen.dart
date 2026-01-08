import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:settingwala/utils/location_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class LocationMapScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialTitle;
  
  const LocationMapScreen({
    Key? key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialTitle,
  }) : super(key: key);

  @override
  State<LocationMapScreen> createState() => _LocationMapScreenState();

  static LocationMapScreen fromRouteArgs(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;
    return LocationMapScreen(
      initialLatitude: args?['latitude'] as double?,
      initialLongitude: args?['longitude'] as double?,
      initialTitle: args?['title'] as String?,
    );
  }
}

class _LocationMapScreenState extends State<LocationMapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = <Marker>{};
  Position? _currentPosition;
  double? _selectedLatitude;
  double? _selectedLongitude;
  double? _distanceInKm;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    
    // If initial coordinates are provided, add a marker at that location
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _markers.add(
            Marker(
              markerId: const MarkerId('initial_location'),
              position: LatLng(
                widget.initialLatitude!,
                widget.initialLongitude!,
              ),
              infoWindow: InfoWindow(
                title: widget.initialTitle ?? 'Initial Location',
              ),
            ),
          );
        });
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    final locationPermission = await LocationUtils.checkLocationPermission();
    if (!locationPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location permission is required to get current location'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final position = await LocationUtils.getCurrentLocation();
    if (position != null) {
      setState(() {
        _currentPosition = position;
      });
      
      // Move camera to current position if no initial coordinates provided
      if (widget.initialLatitude == null || widget.initialLongitude == null) {
        _moveToCurrentLocation();
      }
    }
  }

  void _moveToCurrentLocation() {
    if (_currentPosition != null && _mapController != null) {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
            zoom: 15,
          ),
        ),
      );
    }
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedLatitude = position.latitude;
      _selectedLongitude = position.longitude;
      
      // Remove existing markers
      _markers.clear();
      
      // Add marker at tapped location
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          infoWindow: const InfoWindow(
            title: 'Selected Location',
          ),
        ),
      );
      
      // Calculate distance if current position is available
      if (_currentPosition != null) {
        _distanceInKm = LocationUtils.calculateDistance(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          position.latitude,
          position.longitude,
        );
      }
    });
  }

  Future<void> _openMapsForDirections() async {
    if (_currentPosition != null && _selectedLatitude != null && _selectedLongitude != null) {
      final url = 'https://www.google.com/maps/dir/?api=1'
          '&origin=${_currentPosition!.latitude},${_currentPosition!.longitude}'
          '&destination=$_selectedLatitude,$_selectedLongitude'
          '&travelmode=driving';
      
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch maps'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getDistanceText() {
    if (_distanceInKm == null) {
      return 'Distance: Not calculated';
    } else if (_distanceInKm! < 1) {
      return 'Distance: ${( _distanceInKm! * 1000).round()} meters';
    } else {
      return 'Distance: ${_distanceInKm!.toStringAsFixed(2)} km';
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialCameraPosition = CameraPosition(
      target: LatLng(
        widget.initialLatitude ?? 0.0,
        widget.initialLongitude ?? 0.0,
      ),
      zoom: widget.initialLatitude != null && widget.initialLongitude != null ? 15 : 2,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Map'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: widget.initialLatitude != null && widget.initialLongitude != null
                ? initialCameraPosition
                : const CameraPosition(target: LatLng(0, 0), zoom: 2),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            onTap: _onMapTapped,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          if (_selectedLatitude != null && _selectedLongitude != null)
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Location:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Latitude: ${_selectedLatitude?.toStringAsFixed(6)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Longitude: ${_selectedLongitude?.toStringAsFixed(6)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getDistanceText(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _openMapsForDirections,
                            icon: const Icon(Icons.navigation),
                            label: const Text('Get Directions'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (_currentPosition != null) {
                                _mapController?.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                      target: LatLng(
                                        _currentPosition!.latitude,
                                        _currentPosition!.longitude,
                                      ),
                                      zoom: 15,
                                    ),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.my_location),
                            label: const Text('My Location'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}