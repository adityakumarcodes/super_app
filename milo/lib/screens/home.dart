import 'package:milo/atoms/icon_tile.dart';
import 'package:milo/atoms/wordoftheday.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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

const List<CategoryItem> categoriesList = [
  CategoryItem(
    icon: LucideIcons.bookOpen,
    text: 'Notebook',
    route: '/notebook',
  ),
  CategoryItem(
    icon: LucideIcons.messageCircleMore,
    text: 'Chat',
    route: '/chat',
  ),
  CategoryItem(
    icon: LucideIcons.calendar,
    text: 'Calendar',
    route: '/calendar',
  ),
  // CategoryItem(
  //   icon: LucideIcons.calculator,
  //   text: 'Calculator',
  //   route: '/calculator',
  // ),
  CategoryItem(icon: LucideIcons.store, text: 'Shop', route: '/shop'),
  CategoryItem(icon: LucideIcons.pyramid, text: 'Social', route: '/social'),

  CategoryItem(icon: LucideIcons.bolt, text: 'Settings', route: '/settings'),
];

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // Access theme colors here to pass them down or rely on IconTile's internal theme access
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      // Setting scaffold background ensures theme consistency
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const WordOfTheDay(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 10,
                ),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categoriesList.length,
                itemBuilder: (context, index) {
                  final item = categoriesList[index];
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
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {},
      //   icon: const Icon(LucideIcons.search),
      //   label: const Text('Search'),
      // ),
    );
  }
}
