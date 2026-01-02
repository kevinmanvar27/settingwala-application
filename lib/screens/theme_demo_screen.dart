import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../widgets/theme_toggle.dart';

class ThemeDemoScreen extends StatelessWidget {
  const ThemeDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Demo'),
        actions: [
          const ThemeToggle(showLabel: false),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('Theme Mode'),
            const SizedBox(height: 8),
            Center(child: ThemeToggle.segmented()),
            const SizedBox(height: 24),
            
            _SectionTitle('Brand Colors'),
            const SizedBox(height: 8),
            _ColorRow('Primary', AppColors.primary),
            _ColorRow('Primary Light', AppColors.primaryLight),
            _ColorRow('Primary Dark', AppColors.primaryDark),
            _ColorRow('Secondary', AppColors.secondary),
            const SizedBox(height: 24),
            
            _SectionTitle('Semantic Colors'),
            const SizedBox(height: 8),
            _ColorRow('Success', AppColors.success),
            _ColorRow('Warning', AppColors.warning),
            _ColorRow('Error', AppColors.error),
            _ColorRow('Info', AppColors.info),
            const SizedBox(height: 24),
            
            _SectionTitle('Theme-aware Colors'),
            const SizedBox(height: 8),
            _ColorRow('Background', colors.background),
            _ColorRow('Surface', colors.surface),
            _ColorRow('Card', colors.card),
            _ColorRow('Border', colors.border),
            _ColorRow('Text Primary', colors.textPrimary),
            _ColorRow('Text Secondary', colors.textSecondary),
            const SizedBox(height: 24),
            
            _SectionTitle('Buttons'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Elevated'),
                ),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Outlined'),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Text'),
                ),
                ElevatedButton(
                  onPressed: null,
                  child: const Text('Disabled'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            _SectionTitle('Input Fields'),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Label',
                hintText: 'Enter text...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'With Error',
                errorText: 'This field has an error',
              ),
            ),
            const SizedBox(height: 24),
            
            _SectionTitle('Cards'),
            const SizedBox(height: 8),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Card Title',
                      style: context.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This is a card with some content. Cards adapt to the current theme automatically.',
                      style: context.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('Action'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            _SectionTitle('List Tiles'),
            const SizedBox(height: 8),
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Profile'),
                    subtitle: const Text('View and edit your profile'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Notifications'),
                    subtitle: const Text('Manage notification settings'),
                    trailing: Switch(
                      value: true,
                      onChanged: (_) {},
                    ),
                  ),
                  const Divider(height: 1),
                  ThemeToggle.listTile(),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            _SectionTitle('Chips'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                const Chip(label: Text('Default')),
                Chip(
                  avatar: const Icon(Icons.check, size: 18),
                  label: const Text('With Icon'),
                  onDeleted: () {},
                ),
                ChoiceChip(
                  label: const Text('Selected'),
                  selected: true,
                  onSelected: (_) {},
                ),
                FilterChip(
                  label: const Text('Filter'),
                  selected: false,
                  onSelected: (_) {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            _SectionTitle('Typography'),
            const SizedBox(height: 8),
            Text('Headline Large', style: context.textTheme.headlineLarge),
            Text('Headline Medium', style: context.textTheme.headlineMedium),
            Text('Headline Small', style: context.textTheme.headlineSmall),
            Text('Title Large', style: context.textTheme.titleLarge),
            Text('Title Medium', style: context.textTheme.titleMedium),
            Text('Title Small', style: context.textTheme.titleSmall),
            Text('Body Large', style: context.textTheme.bodyLarge),
            Text('Body Medium', style: context.textTheme.bodyMedium),
            Text('Body Small', style: context.textTheme.bodySmall),
            Text('Label Large', style: context.textTheme.labelLarge),
            Text('Label Medium', style: context.textTheme.labelMedium),
            Text('Label Small', style: context.textTheme.labelSmall),
            const SizedBox(height: 24),
            
            _SectionTitle('Progress Indicators'),
            const SizedBox(height: 8),
            const Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 24),
                Expanded(child: LinearProgressIndicator()),
              ],
            ),
            const SizedBox(height: 24),
            
            _SectionTitle('Dialogs & Sheets'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showDialog(context),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Show Dialog'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showBottomSheet(context),
                  icon: const Icon(Icons.expand_less),
                  label: const Text('Bottom Sheet'),
                ),
                TextButton.icon(
                  onPressed: () => _showSnackBar(context),
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Snackbar'),
                ),
              ],
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dialog Title'),
        content: const Text(
          'This is a dialog that adapts to the current theme. '
          'Notice how colors and styling change automatically.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bottom Sheet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'This bottom sheet also adapts to the theme automatically.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('This is a themed snackbar'),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {},
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _ColorRow extends StatelessWidget {
  final String name;
  final Color color;

  const _ColorRow(this.name, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
