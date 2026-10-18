import 'dart:async';

import 'package:flutter/material.dart';

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

  bool _needsScrolling = false;
  int _loopId = 0;

  @override
  void initState() {
    super.initState();
    _scheduleScrolling();
  }

  @override
  void didUpdateWidget(covariant ScrollingText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.text != widget.text) {
      _scheduleScrolling();
    }
  }

  void _scheduleScrolling() {
    final loopId = ++_loopId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _startScrollingLoop(loopId);
    });
  }

  Future<void> _startScrollingLoop(int loopId) async {
    await Future.delayed(widget.initialDelay);

    while (mounted && loopId == _loopId) {
      if (!_scrollController.hasClients) {
        await Future.delayed(const Duration(milliseconds: 200));
        continue;
      }

      final maxExtent = _scrollController.position.maxScrollExtent;

      if (maxExtent <= 0) {
        if (_needsScrolling) {
          setState(() => _needsScrolling = false);
        }

        await Future.delayed(const Duration(seconds: 2));
        continue;
      }

      if (!_needsScrolling) {
        setState(() => _needsScrolling = true);
      }

      await _scrollController.animateTo(
        maxExtent,
        duration: widget.scrollDuration,
        curve: Curves.linear,
      );

      if (!mounted || loopId != _loopId) return;

      await Future.delayed(widget.endDelay);

      if (!mounted || loopId != _loopId) return;

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
    _loopId++;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Text(
              widget.text,
              style: widget.style,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.visible,
            ),
          ),
        );
      },
    );
  }
}
