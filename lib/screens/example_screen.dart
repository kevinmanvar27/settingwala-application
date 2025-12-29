import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Example Screen',
      showBackButton: true, // Show back button since this is a secondary screen
      body: FadeTransition(
        opacity: _animation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This is an example screen using BaseScreen',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E263D),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'The BaseScreen widget provides a consistent layout with:',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF868C94),
                ),
              ),
              const SizedBox(height: 16),
              _buildFeatureItem('Custom AppBar with gradient'),
              _buildFeatureItem('Drawer with user profile'),
              _buildFeatureItem('Navigation to all app sections'),
              _buildFeatureItem('Consistent styling across screens'),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Button pressed!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA055B8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Example Action'),
                ),
              ),
            ],
          ),
        ),
      ),
      // You can also add a floating action button if needed
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('FAB pressed!')),
          );
        },
        backgroundColor: const Color(0xFFA055B8),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF1AB068),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1E263D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}