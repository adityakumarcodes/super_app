import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:milo/providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  final List<Color> accentColors = const [
    Colors.deepPurple,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
  ];

  @override
  Widget build(BuildContext context) {
    final currentThemeColor = context.watch<ThemeProvider>().themeColor;
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
        shape: const Border(
          bottom: BorderSide(color: Colors.black, width: 2),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        children: [
          // Profile
          _settingsTile(
            context: context,
            icon: Icons.person_outline,
            title: 'Profile',
            subtitle: 'View your account details',
            onTap: () => _showProfileSheet(context),
          ),

          const SizedBox(height: 16),

          // Appearance
          Theme(
            data: theme.copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              leading: Icon(
                Icons.palette_outlined,
                color: colorScheme.primary,
              ),
              title: const Text('Appearance'),
              subtitle: Text(
                'Theme & Accent color',
                style: theme.textTheme.bodySmall,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor:
                  colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              collapsedBackgroundColor:
                  colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.2,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Accent Color',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: accentColors.map((color) {
                          final isSelected =
                              currentThemeColor == color;

                          return GestureDetector(
                            onTap: () {
                              context
                                  .read<ThemeProvider>()
                                  .themeColor = color;
                            },
                            child: AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 200),
                              width: 44,
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
                                      color:
                                          color.computeLuminance() > 0.5
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

          // About dialog
          _settingsTile(
            context: context,
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'About Milo',
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  // Reusable settings tile
  Widget _settingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      tileColor:
          colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
      leading: Icon(
        icon,
        color: colorScheme.primary,
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  // Built-in About dialog
  void _showAboutDialog(BuildContext context) {

    showAboutDialog(
      context: context,
      applicationName: 'Milo',
      applicationVersion: '1.0.0',
      children: [
        const SizedBox(height: 8),
        const Text('• Frontend: Vite + TanStack Router'),
        const Text('• Backend: NestJS + PrismaORM'),
        const Text('• Mobile: Flutter'),
        const Text('• Database: Prisma Postgres'),
        const Text('• Authentication: Better Auth'),
      ],
    );
  }

  // Profile bottom sheet
  void _showProfileSheet(BuildContext context) {
    const String name = 'Aditya Kumar';
    const String email = 'aditya@example.com';

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final colorScheme = theme.colorScheme;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Profile avatar
                CircleAvatar(
                  radius: 44,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    size: 48,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),

                const SizedBox(height: 16),

                // Name
                Text(
                  name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 24),

                // Email
                ListTile(
                  leading: Icon(
                    Icons.email_outlined,
                    color: colorScheme.primary,
                  ),
                  title: const Text('Email'),
                  subtitle: const Text(email),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  tileColor:
                      colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.3,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copy email',
                    onPressed: () async {
                      await Clipboard.setData(
                        const ClipboardData(text: email),
                      );

                      if (!sheetContext.mounted) return;

                      // Close the sheet first.
                      Navigator.pop(sheetContext);

                      // Show confirmation on the parent page.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Email copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),

                // Sign out
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Sign out is not connected yet.',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign out'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}