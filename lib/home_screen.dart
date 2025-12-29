// import 'package:flutter/material.dart';
// import 'screens/main_navigation_screen.dart';
//
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MainNavigationScreen();
//   }
// }


import 'package:flutter/material.dart';
import 'package:settingwala/screens/main_navigation_screen.dart';

import 'google.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GoogleAuthService _authService = GoogleAuthService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getSavedUser();
    setState(() {
      _userData = user;
      _isLoading = false;
    });
  }

  Future<void> _handleSignOut() async {
    await _authService.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settingwala'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _handleSignOut,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: _userData?['avatar'] != null
                          ? NetworkImage(_userData!['avatar'])
                          : null,
                      child: _userData?['avatar'] == null
                          ? Icon(Icons.person, size: 35)
                          : null,
                    ),
                    SizedBox(width: 16),

                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userData?['name'] ?? 'User',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _userData?['email'] ?? '',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),

            // Welcome Message
            Text(
              'Welcome to Settingwala!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'You are successfully logged in.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
           OutlinedButton(onPressed: (){
             Navigator.of(context).pushReplacement(
               MaterialPageRoute(builder: (context) => MainNavigationScreen()),
             );
           }, child: Text("Go To App"))
          ],
        ),
      ),
    );
  }
}