import 'package:flutter/material.dart';
import 'package:settingwala/routes/app_routes.dart';

class LocationDemoScreen extends StatelessWidget {
  const LocationDemoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Demo'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Location Map Demo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'This demo shows how to use the location map functionality:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildFeatureCard(
              title: 'Open Map',
              description: 'Click to open the location map screen with full functionality',
              icon: Icons.map,
              color: Colors.blue,
              onPressed: () {
                AppRoutes.toLocationMap(context);
              },
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              title: 'Map with Initial Location',
              description: 'Open map centered on a specific location',
              icon: Icons.location_on,
              color: Colors.green,
              onPressed: () {
                AppRoutes.toLocationMap(
                  context,
                  latitude: 23.0225, // Example: Ahmedabad, Gujarat
                  longitude: 72.5714,
                  title: 'Ahmedabad',
                );
              },
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              title: 'Calculate Distance',
              description: 'Tap on map to select location and calculate distance from current position',
              icon: Icons.straighten,
              color: Colors.orange,
              onPressed: () {
                AppRoutes.toLocationMap(context);
              },
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              title: 'Get Directions',
              description: 'Get directions to selected location using Google Maps',
              icon: Icons.navigation,
              color: Colors.purple,
              onPressed: () {
                AppRoutes.toLocationMap(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 30,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: const Text('Try it'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}