import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';
import '../utils/auth_helper.dart';
import 'home_page.dart';
import 'events_screen.dart';
import 'find_person_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  bool _isValidating = true;
  
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _validateUser();
  }
  
  Future<void> _validateUser() async {
    final isValid = await AuthHelper.validateUserOrRedirect(context);
    if (mounted && isValid) {
      setState(() {
        _isValidating = false;
      });
    }
  }
  
  final List<Widget> _screens = [
    const HomePage(),
    const EventsScreen(),
    const FindPersonScreen(),
  ];
  
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while validating user
    if (_isValidating) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
