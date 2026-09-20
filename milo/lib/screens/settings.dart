import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:milo/providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  final List<Color> accentColors = const [
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.pink,
    Colors.teal,
    Colors.red,
  ];

  @override
  Widget build(BuildContext context) {
    final currentThemeColor = context.watch<ThemeProvider>().themeColor;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
        shape: Border(bottom: BorderSide(color: Colors.black, width: 2)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          Theme(
            // This removes the default borders and lines from ExpansionTile
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: Icon(Icons.palette_outlined, color: colorScheme.primary),
              title: const Text('Appearance'),
              subtitle: Text(
                'Theme color',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              collapsedBackgroundColor: colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.2),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Color Picker Section ---
                      Text(
                        'Accent Color',
                        style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: accentColors.map((color) {
                          final isSelected = currentThemeColor == color;
                          return GestureDetector(
                            onTap: () =>
                                context.read<ThemeProvider>().themeColor =
                                    color,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 44, // Slightly smaller for the dropdown
                              height: 44,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(
                                        color: colorScheme.onSurface,
                                        width: 3,
                                      )
                                    : null,
                              ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check,
                                      size: 20,
                                      color: color.computeLuminance() > 0.5
                                          ? Colors.black
                                          : Colors.white,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Other settings categories could go here...
        ],
      ),
    );
  }
}
