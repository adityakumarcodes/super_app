import 'package:google_fonts/google_fonts.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:milo/atoms/circle_text.dart';
import 'package:milo/features/auth/auth_cubit.dart';
import 'package:milo/features/settings/navigation_cubit.dart';
import 'package:milo/features/settings/theme_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const List<Color> accentColors = [
    Colors.deepPurple,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
        shape: const Border(bottom: BorderSide(color: Colors.black, width: 2)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _settingsTile(
                  context: context,
                  icon: Icons.person_outline,
                  title: 'Personal Profile',
                  subtitle: 'Manage your personal information',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ProfilePage(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _appearanceTile(context),

                const SizedBox(height: 16),

                _settingsTile(
                  context: context,
                  icon: Icons.storefront_outlined,
                  title: 'App Store',
                  subtitle: 'Discover and explore available apps',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AppStoreScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _settingsTile(
                  context: context,
                  icon: Icons.delete_outline,
                  title: 'Recently Deleted',
                  subtitle: 'View and restore deleted items',
                  onTap: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute<void>(builder: (_) => _trashPage())),
                ),
                const SizedBox(height: 16),

                _settingsTile(
                  context: context,
                  icon: Icons.info_outline,
                  title: 'About Milo',
                  subtitle: 'App information, version and credits',
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ),
          ),

          // Sign out
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (buttonContext, auth) => ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  tileColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.2),
                  leading: auth.isLoading
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.logout),
                  title: Text(auth.isLoading ? 'Signing Out...' : 'Sign Out'),
                  onTap: auth.isLoading
                      ? null
                      : () async {
                          final authCubit = buttonContext.read<AuthCubit>();

                          if (await authCubit.signOut()) return;
                          if (!buttonContext.mounted) return;

                          ScaffoldMessenger.of(buttonContext).showSnackBar(
                            SnackBar(
                              content: Text(
                                authCubit.state.error ?? 'Could not sign out.',
                              ),
                            ),
                          );
                        },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Appearance and navigation preferences
  Widget _appearanceTile(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeState = context.watch<ThemeCubit>().state;
    final navigationState = context.watch<NavigationCubit>().state;

    final sectionGap = [
      const SizedBox(height: 24),
      Divider(color: colorScheme.outlineVariant),
      const SizedBox(height: 16),
    ];

    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(Icons.palette_outlined, color: colorScheme.primary),
        title: const Text('Appearance & Navigation'),
        subtitle: Text(
          'Customize your theme and navigation preferences',
          style: theme.textTheme.bodySmall,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle(context, 'Display Theme'),
                const SizedBox(height: 16),
                _themeModePicker(context, themeState.mode),

                ...sectionGap,

                _sectionTitle(context, 'Accent Colour'),
                const SizedBox(height: 16),
                _accentColorPicker(context, themeState.color),

                ...sectionGap,

                _sectionTitle(context, 'Navigation Layout'),
                const SizedBox(height: 16),
                _navigationViewPicker(context, navigationState.view),

                ...sectionGap,

                _sectionTitle(context, 'Customize Navigation'),
                _navigationItems(context, navigationState),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _themeModePicker(BuildContext context, ThemeMode mode) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(
            value: ThemeMode.light,
            icon: Icon(Icons.light_mode_outlined),
            label: Text('Light Mode'),
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            icon: Icon(Icons.dark_mode_outlined),
            label: Text('Dark Mode'),
          ),
        ],
        selected: {mode},
        onSelectionChanged: (selection) => _saveSetting(
          context,
          () => context.read<ThemeCubit>().setThemeMode(selection.first),
        ),
      ),
    );
  }

  Widget _accentColorPicker(BuildContext context, Color currentColor) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: accentColors.map((color) {
        final isSelected = currentColor == color;

        return GestureDetector(
          onTap: () => _saveSetting(
            context,
            () => context.read<ThemeCubit>().setThemeColor(color),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: colorScheme.onSurface, width: 3)
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
    );
  }

  Widget _navigationViewPicker(BuildContext context, NavigationView view) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<NavigationView>(
        segments: const [
          ButtonSegment(
            value: NavigationView.navbar,
            icon: Icon(Icons.view_week_outlined),
            label: Text('Nav Bar'),
          ),
          ButtonSegment(
            value: NavigationView.gridView,
            icon: Icon(Icons.grid_view_outlined),
            label: Text('Grid View'),
          ),
        ],
        selected: {view},
        onSelectionChanged: (selection) => _saveSetting(
          context,
          () => context.read<NavigationCubit>().setView(selection.first),
        ),
      ),
    );
  }

  // Reorder and manage navigation items
  Widget _navigationItems(BuildContext context, NavigationState state) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: state.tabOrder.length,
      onReorderItem: (oldIndex, newIndex) => _saveSetting(
        context,
        () => context.read<NavigationCubit>().reorderTabs(oldIndex, newIndex),
      ),
      itemBuilder: (context, index) {
        final tab = state.tabOrder[index];

        return ListTile(
          key: ValueKey(tab),
          contentPadding: EdgeInsets.zero,
          leading: Icon(tab.icon),
          title: Text(tab.label),
          subtitle: tab.isRequired ? const Text('Always Visible') : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!tab.isRequired)
                Switch(
                  value: state.isTabVisible(tab),
                  onChanged: (visible) => _saveSetting(
                    context,
                    () => context.read<NavigationCubit>().setTabVisible(
                      tab,
                      visible,
                    ),
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

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Milo',
      applicationVersion: '1.0.0',
      children: [
        const SizedBox(height: 8),
        const Text('• Frontend: Vite + TanStack Router'),
        const Text('• Backend: NestJS + Prisma ORM'),
        const Text('• Mobile: Flutter'),
        const Text('• Database: Prisma Postgres'),
        const Text('• Authentication: Better Auth'),
      ],
    );
  }

  Widget _trashPage() => Scaffold(
    appBar: AppBar(title: const Text('Recently Deleted')),
    body: const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Deleted items are not available yet.',
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const details = [
    (Icons.badge_outlined, 'Full Name', 'Aditya Kumar'),
    (Icons.email_outlined, 'Email Address', 'ak19992017@gmail.com'),
    (Icons.phone_outlined, 'Phone Number', '+91 00001111'),
    (Icons.cake_outlined, 'Date of Birth', '2 June 2000'),
    (Icons.location_on_outlined, 'Location', 'Noida, UP'),
    (
      Icons.description_outlined,
      'About Me',
      'Software developer interested in data engineering, '
          'cloud technologies, and building open-source applications.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personal Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: SizedBox(
              width: 280,
              height: 280,
              child: CircleText(child: const Placeholder()),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                for (final (icon, label, value) in details)
                  ListTile(
                    leading: Icon(icon),
                    title: Text(label),
                    subtitle: Text(value),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const _logoToken = 'pk_ZTPJWS2aScqrREDBfeY-Bw';

class AppStoreScreen extends StatelessWidget {
  const AppStoreScreen({super.key});
  static const _apps = <(String, String, String)>[
    ('Notion', 'notion.com', 'One place for notes, docs, and ideas.'),
    ('Figma', 'figma.com', 'Design together, from idea to interface.'),
    ('Airbnb', 'airbnb.com', 'Find a place that feels like yours.'),
    ('Slack', 'slack.com', 'Keep your team in the conversation.'),
    ('UnitedHealthcare', 'uhc.com', 'Support for healthier days.'),
    ('Google', 'google.com', 'Find answers and explore more.'),
    ('Microsoft', 'microsoft.com', 'Tools to create, connect, and achieve.'),
    ('Amazon', 'amazon.com', 'Find what you need, delivered.'),
    ('Meta', 'meta.com', 'Connect with people and communities.'),
    ('Adobe', 'adobe.com', 'Bring creative ideas to life.'),
    ('GitLab', 'gitlab.com', 'Build and ship software together.'),
    ('Stripe', 'stripe.com', 'Make online payments feel simple.'),
    ('Shopify', 'shopify.com', 'Turn your ideas into a business.'),
    ('Uber', 'uber.com', 'Get where you need to go.'),
    ('Expedia', 'expedia.com', 'Plan the trip you have in mind.'),
    ('Starbucks', 'starbucks.com', 'A familiar cup, wherever you are.'),
    ('Samsung', 'samsung.com', 'Technology for everyday possibilities.'),
    ('NVIDIA', 'nvidia.com', 'Powering the next wave of computing.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: M3EShapeContainer.square(
        width: 64,
        height: 64,
        color: Theme.of(context).colorScheme.primary,
        child: IconButton(
          tooltip: 'Search',
          icon: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () {},
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width >= 720
                ? 4
                : width >= 480
                ? 3
                : 2;
            const gap = 16.0;
            final itemWidth = (width - gap * (columns - 1)) / columns;
            final shapeSize = itemWidth < 160 ? 96.0 : 120.0;

            return Wrap(
              spacing: gap,
              runSpacing: 24,
              children: [
                for (final (name, logoPath, about) in _apps)
                  SizedBox(
                    width: itemWidth,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => AppDetailsPage(
                            name: name,
                            logoPath: logoPath,
                            about: about,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            Hero(
                              tag: logoPath,
                              child: LogoShape(
                                logoPath: logoPath,
                                size: shapeSize,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class AppDetailsPage extends StatefulWidget {
  const AppDetailsPage({
    required this.name,
    required this.logoPath,
    required this.about,
    super.key,
  });

  final String name;
  final String logoPath;
  final String about;

  @override
  State<AppDetailsPage> createState() => _AppDetailsPageState();
}

class _AppDetailsPageState extends State<AppDetailsPage> {
  bool _installing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: widget.logoPath,
              child: LogoShape(logoPath: widget.logoPath, size: 220),
            ),
            const SizedBox(height: 24),
            Text(
              widget.name,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                textStyle: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.about,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            M3EChip(
              label: 'Productivity',
              type: M3EChipType.suggestion,
              onPressed: () {},
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 96,
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: _installing
                      ? Column(
                          key: const ValueKey('progress'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 220,
                              child: M3EProgressIndicator.linearWavy(
                                value: 0.60,
                                linearSize: M3EProgressIndicatorSize.s,
                                strokeWidth: 4,
                                trackStrokeWidth: 4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            M3EButton(
                              onPressed: () =>
                                  setState(() => _installing = false),
                              style: M3EButtonStyle.outlined,
                              size: M3EButtonSize.md,
                              shape: M3EButtonShape.square,
                              child: const Text('Cancel'),
                            ),
                          ],
                        )
                      : Row(
                          key: const ValueKey('install'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            M3EButton(
                              onPressed: () =>
                                  setState(() => _installing = true),
                              style: M3EButtonStyle.filled,
                              size: M3EButtonSize.md,
                              shape: M3EButtonShape.square,
                              child: const Text('Install'),
                            ),
                            const SizedBox(width: 12),
                            M3EIconButton(
                              icon: const Icon(
                                M3EIcons.favorite,
                                color: Colors.red,
                              ),
                              onPressed: () {},
                              variant: M3EIconButtonVariant.tonal,
                              size: M3EIconButtonSize.md,
                              shape: M3EIconButtonShapeVariant.round,
                              width: M3EIconButtonWidth.defaultWidth,
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const Text(
              'TODO: About, Rating, Report issue, Request feature',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class LogoShape extends StatelessWidget {
  const LogoShape({required this.logoPath, required this.size, super.key});

  final String logoPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final logoUrl = Uri.https('img.logo.dev', '/$logoPath', {
      'token': _logoToken,
      'size': '150',
      'format': 'png',
      'retina': 'true',
      'theme': 'dark',
    }).toString();

    return M3EShapeContainer(
      kind: M3EShapeKind.cookie12Sided,
      width: size,
      height: size,
      color: scheme.primaryContainer,
      child: Center(
        child: Image.network(
          logoUrl,
          width: size * .5,
          height: size * .5,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.error,
            size: size * .4,
            color: scheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
