import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({
    required this.title,
    this.actions,
    this.titleStyle,
    this.titleMaxLines,
    this.titleOverflow,
    super.key,
  });

  final String title;
  final List<Widget>? actions;
  final TextStyle? titleStyle;
  final int? titleMaxLines;
  final TextOverflow? titleOverflow;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: titleStyle,
        maxLines: titleMaxLines,
        overflow: titleOverflow,
      ),
      centerTitle: true,
      elevation: 2,
      shape: const Border(bottom: BorderSide(color: Colors.black, width: 2)),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
