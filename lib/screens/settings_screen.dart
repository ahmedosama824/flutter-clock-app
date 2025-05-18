import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;

  const SettingsScreen({super.key, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(
            context,
            icon: Icons.color_lens_outlined,
            title: 'Toggle Theme',
            subtitle: isDark ? "Currently: Dark Mode" : "Currently: Light Mode",
            onTap: () {
              onToggleTheme();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Theme switched to ${isDark ? 'Light' : 'Dark'} mode"),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          _buildCard(
            context,
            icon: Icons.info_outline,
            title: 'About App',
            subtitle: 'View app info',
            onTap: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('Stopwatch App',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Version: 1.0.0'),
                      SizedBox(height: 8),
                      Text('© 2025 Ahmed'),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          ),
          _buildCard(
            context,
            icon: Icons.feedback_outlined,
            title: 'Send Feedback',
            subtitle: 'We value your feedback',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Thanks for your feedback!")),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
