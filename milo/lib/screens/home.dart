import 'package:milo/atoms/icon_tile.dart';
import 'package:milo/atoms/wordoftheday.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:milo/providers/navigation_provider.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class CategoryItem {
  final IconData icon;
  final String text;
  final String route;

  const CategoryItem({
    required this.icon,
    required this.text,
    required this.route,
  });
}

const settingsCategory = CategoryItem(
  icon: LucideIcons.bolt,
  text: 'Settings',
  route: '/settings',
);

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // Access theme colors here to pass them down or rely on IconTile's internal theme access
    final colorScheme = Theme.of(context).colorScheme;
    final navigationProvider = context.watch<NavigationProvider>();
    final navigationView = navigationProvider.view;
    final showNavigationGrid = navigationView == NavigationView.gridView;
    final categories = [
      for (final tab in navigationProvider.visibleTabs)
        if (tab != NavigationTab.home)
          CategoryItem(icon: tab.icon, text: tab.label, route: tab.route),
    ];

    return Scaffold(
      key: _scaffoldKey,
      // Setting scaffold background ensures theme consistency
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const WordOfTheDay(),
            if (showNavigationGrid)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 10,
                  ),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final item = categories[index];
                    return IconTile(
                      item: item,
                      onTap: () => context.push(item.route),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(settingsCategory.route),
        tooltip: 'Settings',
        child: const Icon(LucideIcons.bolt),
      ),
    );
  }
}

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final colorScheme = Theme.of(context).colorScheme;
    final tabs = context.watch<NavigationProvider>().visibleTabs;

    final currentIndex = tabs.indexWhere((tab) => location == tab.route);

    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black, width: 2)),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex < 0
            ? tabs.indexOf(NavigationTab.home)
            : currentIndex,
        onDestinationSelected: (index) {
          final route = tabs[index].route;
          if (location != route) context.push(route);
        },
        backgroundColor: colorScheme.surface,
        elevation: 4,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          );
        }),
        destinations: tabs.map((tab) {
          return NavigationDestination(icon: Icon(tab.icon), label: tab.label);
        }).toList(),
      ),
    );
  }
}
