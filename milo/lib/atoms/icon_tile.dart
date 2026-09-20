import 'package:milo/atoms/scrolling_text.dart';
import 'package:milo/screens/home.dart';
import 'package:flutter/material.dart';

class IconTile extends StatelessWidget {
  final CategoryItem item;
  final VoidCallback onTap;

  const IconTile({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Accessing the theme's color scheme
    final colorScheme = Theme.of(context).colorScheme;

    // Applying your logic style for theme-aware colors
    final tileColor = colorScheme.primaryContainer;
    final contentColor = colorScheme.onPrimaryContainer;
    final iconColor =
        colorScheme.onPrimaryContainer; // Using primary for a M3 pop

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Icon(
                item.icon,
                color: iconColor, // Use primary for consistent branding
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ScrollingText(
                text: item.text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: contentColor, // Theme-aware text color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
