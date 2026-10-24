import 'package:flutter/material.dart';

/// Editor.js `header` block (levels 1-6).
class HeadingWidget extends StatelessWidget {
  static final Map<int, TextStyle Function(TextTheme)> _headingStyles = {
    1: (theme) => theme.headlineLarge!,
    2: (theme) => theme.headlineMedium!,
    3: (theme) => theme.headlineSmall!,
    4: (theme) => theme.titleLarge!,
    5: (theme) => theme.titleMedium!,
    6: (theme) => theme.titleSmall!,
  };

  final String text;
  final int level;

  const HeadingWidget({super.key, required this.text, this.level = 1});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final headingStyle = _headingStyles[level.clamp(1, 6)]!(textTheme);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SelectableText(text, style: headingStyle),
    );
  }
}
