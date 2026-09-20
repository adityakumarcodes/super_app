import 'package:flutter/material.dart';
import 'dart:async';

class ScrollingText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration initialDelay;
  final Duration endDelay;
  final Duration startDelay;
  final Duration scrollDuration;

  const ScrollingText({
    super.key,
    required this.text,
    this.style,
    this.initialDelay = const Duration(seconds: 1),
    this.endDelay = const Duration(seconds: 1),
    this.startDelay = const Duration(seconds: 1),
    this.scrollDuration = const Duration(seconds: 2),
  });

  @override
  State<ScrollingText> createState() => _ScrollingTextState();
}

class _ScrollingTextState extends State<ScrollingText> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrollingLoop());
  }

  Future<void> _startScrollingLoop() async {
    await Future.delayed(widget.initialDelay);

    while (mounted) {
      // if (_scrollController.position.maxScrollExtent == 0) {
      //   // No scrolling needed; check again after some time
      //   await Future.delayed(const Duration(seconds: 5));
      //   continue;
      // }

      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: widget.scrollDuration,
        curve: Curves.linear,
      );

      await Future.delayed(widget.endDelay);

      await _scrollController.animateTo(
        0,
        duration: widget.scrollDuration,
        curve: Curves.linear,
      );

      await Future.delayed(widget.startDelay);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Text(
              widget.text,
              style: widget.style,
              overflow: TextOverflow.visible,
            ),
          ),
        );
      },
    );
  }
}
