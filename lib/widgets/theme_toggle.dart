import 'package:flutter/material.dart';
import '../theme/theme.dart';

class ThemeToggle extends StatelessWidget {
  final bool showLabel;
  
  const ThemeToggle({
    super.key,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ThemeProvider.of(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel) ...[
          Icon(
            themeNotifier.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
        ],
        Switch(
          value: themeNotifier.isDarkMode,
          onChanged: (_) => themeNotifier.toggleTheme(),
        ),
      ],
    );
  }

  static Widget segmented() => const _ThemeSegmentedButton();

  static Widget listTile({
    String? title,
    String? subtitle,
  }) => _ThemeListTile(
    title: title,
    subtitle: subtitle,
  );

  static Widget dropdown() => const _ThemeDropdown();
}

class _ThemeSegmentedButton extends StatelessWidget {
  const _ThemeSegmentedButton();

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ThemeProvider.of(context);
    
    return SegmentedButton<AppThemeMode>(
      segments: const [
        ButtonSegment(
          value: AppThemeMode.light,
          icon: Icon(Icons.light_mode),
          label: Text('Light'),
        ),
        ButtonSegment(
          value: AppThemeMode.system,
          icon: Icon(Icons.settings_brightness),
          label: Text('System'),
        ),
        ButtonSegment(
          value: AppThemeMode.dark,
          icon: Icon(Icons.dark_mode),
          label: Text('Dark'),
        ),
      ],
      selected: {themeNotifier.themeMode},
      onSelectionChanged: (selected) {
        themeNotifier.setThemeMode(selected.first);
      },
      showSelectedIcon: false,
    );
  }
}

class _ThemeListTile extends StatelessWidget {
  final String? title;
  final String? subtitle;

  const _ThemeListTile({
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ThemeProvider.of(context);
    
    String getSubtitleText() {
      switch (themeNotifier.themeMode) {
        case AppThemeMode.light:
          return 'Light mode';
        case AppThemeMode.dark:
          return 'Dark mode';
        case AppThemeMode.system:
          return 'System default';
      }
    }
    
    return ListTile(
      leading: Icon(
        themeNotifier.isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(title ?? 'Theme'),
      subtitle: Text(subtitle ?? getSubtitleText()),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showThemeBottomSheet(context),
    );
  }

  void _showThemeBottomSheet(BuildContext context) {
    final themeNotifier = ThemeProvider.of(context);
    
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Choose Theme',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 16),
            _ThemeOption(
              icon: Icons.light_mode,
              title: 'Light',
              subtitle: 'Always use light theme',
              isSelected: themeNotifier.themeMode == AppThemeMode.light,
              onTap: () {
                themeNotifier.setLightMode();
                Navigator.pop(context);
              },
            ),
            _ThemeOption(
              icon: Icons.dark_mode,
              title: 'Dark',
              subtitle: 'Always use dark theme',
              isSelected: themeNotifier.themeMode == AppThemeMode.dark,
              onTap: () {
                themeNotifier.setDarkMode();
                Navigator.pop(context);
              },
            ),
            _ThemeOption(
              icon: Icons.settings_brightness,
              title: 'System',
              subtitle: 'Follow system settings',
              isSelected: themeNotifier.themeMode == AppThemeMode.system,
              onTap: () {
                themeNotifier.setSystemMode();
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? colorScheme.primary : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? colorScheme.primary : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}

class _ThemeDropdown extends StatelessWidget {
  const _ThemeDropdown();

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ThemeProvider.of(context);
    
    return DropdownButton<AppThemeMode>(
      value: themeNotifier.themeMode,
      underline: const SizedBox(),
      borderRadius: BorderRadius.circular(12),
      items: const [
        DropdownMenuItem(
          value: AppThemeMode.light,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.light_mode, size: 20),
              SizedBox(width: 8),
              Text('Light'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: AppThemeMode.dark,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.dark_mode, size: 20),
              SizedBox(width: 8),
              Text('Dark'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: AppThemeMode.system,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.settings_brightness, size: 20),
              SizedBox(width: 8),
              Text('System'),
            ],
          ),
        ),
      ],
      onChanged: (mode) {
        if (mode != null) {
          themeNotifier.setThemeMode(mode);
        }
      },
    );
  }
}
