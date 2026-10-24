import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Editor.js `delimiter` block.
class DelimiterWidget extends StatelessWidget {
  const DelimiterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.asterisk, size: 15),
          Icon(LucideIcons.asterisk, size: 15),
          Icon(LucideIcons.asterisk, size: 15),
        ],
      ),
    );
  }
}
