import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:milo/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:milo/features/notes/presentation/bloc/task_cubit.dart';
import 'package:milo/features/settings/presentation/bloc/navigation_cubit.dart';
import 'package:milo/features/settings/presentation/bloc/theme_cubit.dart';

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
    final themeState = context.watch<ThemeCubit>().state;
    final navigationState = context.watch<NavigationCubit>().state;
    final currentThemeColor = themeState.color;
    final navigationView = navigationState.view;
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
        shape: const Border(bottom: BorderSide(color: Colors.black, width: 2)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
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
            data: theme.copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: Icon(Icons.palette_outlined, color: colorScheme.primary),
              title: const Text('Appearance'),
              subtitle: Text(
                'Theme, accent color, navigation menu & items',
                style: theme.textTheme.bodySmall,
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
                      Text(
                        'Theme mode',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<ThemeMode>(
                          segments: const [
                            ButtonSegment(
                              value: ThemeMode.system,
                              icon: Icon(Icons.brightness_auto_outlined),
                              label: Text('System'),
                            ),
                            ButtonSegment(
                              value: ThemeMode.light,
                              icon: Icon(Icons.light_mode_outlined),
                              label: Text('Light'),
                            ),
                            ButtonSegment(
                              value: ThemeMode.dark,
                              icon: Icon(Icons.dark_mode_outlined),
                              label: Text('Dark'),
                            ),
                          ],
                          selected: {themeState.mode},
                          onSelectionChanged: (selection) => _saveSetting(
                            context,
                            () => context.read<ThemeCubit>().setThemeMode(
                              selection.first,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Divider(color: colorScheme.outlineVariant),
                      const SizedBox(height: 16),
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
                          final isSelected = currentThemeColor == color;

                          return GestureDetector(
                            onTap: () => _saveSetting(
                              context,
                              () => context.read<ThemeCubit>().setThemeColor(
                                color,
                              ),
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
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
                                      color: color.computeLuminance() > 0.5
                                          ? Colors.black
                                          : Colors.white,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      Divider(color: colorScheme.outlineVariant),
                      const SizedBox(height: 16),
                      Text(
                        'Navigation menu',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<NavigationView>(
                          segments: const [
                            ButtonSegment(
                              value: NavigationView.navbar,
                              icon: Icon(Icons.view_week_outlined),
                              label: Text('Navbar'),
                            ),
                            ButtonSegment(
                              value: NavigationView.gridView,
                              icon: Icon(Icons.grid_view_outlined),
                              label: Text('Grid'),
                            ),
                          ],
                          selected: {navigationView},
                          onSelectionChanged: (selection) => _saveSetting(
                            context,
                            () => context.read<NavigationCubit>().setView(
                              selection.first,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Divider(color: colorScheme.outlineVariant),
                      const SizedBox(height: 16),
                      Text(
                        'Navigation items',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        buildDefaultDragHandles: false,
                        itemCount: navigationState.tabOrder.length,
                        onReorderItem: (oldIndex, newIndex) => _saveSetting(
                          context,
                          () => context.read<NavigationCubit>().reorderTabs(
                            oldIndex,
                            newIndex,
                          ),
                        ),
                        itemBuilder: (context, index) {
                          final tab = navigationState.tabOrder[index];
                          return ListTile(
                            key: ValueKey(tab),
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(tab.icon),
                            title: Text(tab.label),
                            subtitle: tab.isRequired
                                ? const Text('Required')
                                : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!tab.isRequired)
                                  Switch(
                                    value: navigationState.isTabVisible(tab),
                                    onChanged: (visible) => _saveSetting(
                                      context,
                                      () => context
                                          .read<NavigationCubit>()
                                          .setTabVisible(tab, visible),
                                    ),
                                  ),
                                ReorderableDragStartListener(
                                  index: index,
                                  child: const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Icon(Icons.drag_handle),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
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

  Future<void> _saveSetting(
    BuildContext context,
    Future<void> Function() save,
  ) async {
    try {
      await save();
    } catch (error) {
      debugPrint('Failed to save app setting: $error');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to save setting. Try again.')),
      );
    }
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      tileColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
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
    final user = context.read<AuthCubit>().state.user;
    final email = user?.email ?? '';
    final name = user?.name.trim().isNotEmpty == true
        ? user!.name
        : email.split('@').first;

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
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Icon(
                        Icons.person_outline,
                        size: 34,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(color: colorScheme.outlineVariant),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.email_outlined,
                    color: colorScheme.primary,
                  ),
                  title: Text(email, style: theme.textTheme.bodyLarge),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copy email',
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: email));

                      if (!sheetContext.mounted || !context.mounted) return;

                      Navigator.pop(sheetContext);

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

                SizedBox(
                  width: double.infinity,
                  child: BlocBuilder<AuthCubit, AuthState>(
                    builder: (buttonContext, auth) {
                      return FilledButton.icon(
                        onPressed: auth.isLoading
                            ? null
                            : () async {
                                final tasks = buttonContext.read<TaskCubit>();
                                Navigator.pop(sheetContext);

                                final signedOut = await buttonContext
                                    .read<AuthCubit>()
                                    .signOut();
                                if (signedOut) {
                                  tasks.clear();
                                  return;
                                }

                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      auth.error ?? 'Could not sign out.',
                                    ),
                                  ),
                                );
                              },
                        icon: auth.isLoading
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.logout),
                        label: Text(
                          auth.isLoading ? 'Signing out...' : 'Sign out',
                        ),
                      );
                    },
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
