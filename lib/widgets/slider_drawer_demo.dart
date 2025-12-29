import 'package:flutter/material.dart';
// Commenting out the problematic import temporarily
// import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';

class SliderDrawerDemo extends StatefulWidget {
  const SliderDrawerDemo({super.key});

  @override
  State<SliderDrawerDemo> createState() => _SliderDrawerDemoState();
}

class _SliderDrawerDemoState extends State<SliderDrawerDemo> {
  // Using standard ScaffoldKey instead of SliderDrawerState
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Slider Drawer Demo'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('Item 1'),
              onTap: () {
                Navigator.pop(context); // Close drawer
              },
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {
                Navigator.pop(context); // Close drawer
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Main Content'),
            ElevatedButton(
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              child: const Text('Open Drawer'),
            ),
          ],
        ),
      ),
    );
  }
}