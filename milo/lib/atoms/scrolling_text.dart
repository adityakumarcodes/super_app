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

  int _loopId = 0;
  bool _needsScrolling = false;

  @override
  void initState() {
    super.initState();
    _scheduleScrolling();
  }

  @override
  void didUpdateWidget(covariant ScrollingText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.text != widget.text ||
        oldWidget.style != widget.style ||
        oldWidget.initialDelay != widget.initialDelay ||
        oldWidget.endDelay != widget.endDelay ||
        oldWidget.startDelay != widget.startDelay ||
        oldWidget.scrollDuration != widget.scrollDuration) {
      _scheduleScrolling();
    }
  }

  void _scheduleScrolling() {
    final loopId = ++_loopId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || loopId != _loopId) return;

      _startScrollingLoop(loopId);
    });
  }

  Future<void> _startScrollingLoop(int loopId) async {
    await Future<void>.delayed(widget.initialDelay);

    while (mounted && loopId == _loopId) {
      if (!_scrollController.hasClients) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        continue;
      }

      final position = _scrollController.position;

      if (!position.hasContentDimensions) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        continue;
      }

      final maxExtent = position.maxScrollExtent;

      if (maxExtent <= 0) {
        _needsScrolling = false;

        // No repeated polling while the text fits.
        return;
      }

      _needsScrolling = true;

      try {
        await _scrollController.animateTo(
          maxExtent,
          duration: widget.scrollDuration,
          curve: Curves.linear,
        );

        if (!_isCurrentLoop(loopId)) return;

        await Future<void>.delayed(widget.endDelay);

        if (!_isCurrentLoop(loopId)) return;

        await _scrollController.animateTo(
          0,
          duration: widget.scrollDuration,
          curve: Curves.linear,
        );

        if (!_isCurrentLoop(loopId)) return;

        await Future<void>.delayed(widget.startDelay);
      } on TickerCanceled {
        // Animation was cancelled; the next loop owns the controller.
        return;
      }
    }
  }

  bool _isCurrentLoop(int loopId) {
    return mounted && loopId == _loopId;
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
