# SettingWala Custom Widgets

This directory contains reusable custom widgets for the SettingWala app.

## Available Widgets

### 1. CustomAppBar

A consistent app bar with gradient background, logo, and user profile button.

**Usage:**
```dart
CustomAppBar(
  scaffoldKey: _scaffoldKey,
  title: 'Screen Title',
  showBackButton: true, // Optional, defaults to false
  actions: [ // Optional, custom action buttons
    IconButton(...),
  ],
)
```

### 2. CustomDrawer

A drawer with user profile header and navigation menu items.

**Usage:**
```dart
const CustomDrawer()
```

### 3. BaseScreen

A complete screen template that combines CustomAppBar and CustomDrawer with proper scaffolding.

**Usage:**
```dart
BaseScreen(
  title: 'Screen Title',
  showBackButton: true, // Optional, defaults to false
  body: YourScreenContent(),
  bottomNavigationBar: YourBottomNavBar(), // Optional
  floatingActionButton: FloatingActionButton(...), // Optional
  backgroundColor: Colors.white, // Optional
)
```

## Implementation Example

```dart
import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';

class YourScreen extends StatelessWidget {
  const YourScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Your Screen',
      showBackButton: true,
      body: Center(
        child: Text('Your screen content goes here'),
      ),
    );
  }
}
```

## Benefits

1. **Consistency**: Ensures a consistent look and feel across all screens
2. **Maintainability**: Changes to UI components can be made in one place
3. **Reduced Code Duplication**: No need to repeat drawer and app bar code
4. **Simplified Screen Creation**: Focus on screen content, not boilerplate

## Customization

Each component can be customized through its parameters. For more extensive customization, modify the widget files directly.