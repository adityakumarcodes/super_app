// ignore_for_file: unused_field

import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:milo/models/note_image_resolver.dart';
import 'package:milo/services/storage_service.dart';

class ImageWidget extends StatefulWidget {
  final String imageUrl;
  final String caption;
  final double borderRadius;

  const ImageWidget({
    super.key,
    required this.imageUrl,
    this.caption = '',
    this.borderRadius = 12,
  });

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  static final Map<String, String> _urlCache = {};
  static final Map<String, Future<String?>> _pendingRequests = {};

  final StorageService _storageService = StorageService();

  String? _resolvedUrl;
  bool _isResolving = true;
  bool _hasError = false;
  bool _retried = false;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant ImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.imageUrl != widget.imageUrl) {
      _resolvedUrl = null;
      _isResolving = true;
      _hasError = false;
      _retried = false;
      _resolve();
    }
  }

  Future<void> _resolve({bool refresh = false}) async {
    final url = widget.imageUrl.trim();

    if (url.isEmpty) {
      _setError();
      return;
    }

    // Public URLs do not require signed URL resolution.
    if (!isStoragePath(url)) {
      if (!mounted) return;

      setState(() {
        _resolvedUrl = url;
        _isResolving = false;
        _hasError = false;
      });
      return;
    }

    if (refresh) {
      _urlCache.remove(url);
    }

    final cachedUrl = refresh ? null : _urlCache[url];

    if (cachedUrl != null) {
      if (!mounted) return;

      setState(() {
        _resolvedUrl = cachedUrl;
        _isResolving = false;
        _hasError = false;
      });
      return;
    }

    try {
      final signedUrl = await _pendingRequests.putIfAbsent(url, () async {
        try {
          return await _storageService.fetchSignedUrl(url);
        } finally {
          _pendingRequests.remove(url);
        }
      });

      if (!mounted) return;

      if (signedUrl == null || signedUrl.isEmpty) {
        _setError();
        return;
      }

      _urlCache[url] = signedUrl;

      setState(() {
        _resolvedUrl = signedUrl;
        _isResolving = false;
        _hasError = false;
      });
    } catch (error) {
      debugPrint('Image URL resolution failed: $error');
      _setError();
    }
  }

  void _setError() {
    if (!mounted) return;

    setState(() {
      _isResolving = false;
      _hasError = true;
    });
  }

  Future<void> _retryExpiredUrl() async {
    if (_retried || !isStoragePath(widget.imageUrl.trim())) {
      _setError();
      return;
    }

    _retried = true;

    setState(() {
      _resolvedUrl = null;
      _isResolving = true;
      _hasError = false;
    });

    await _resolve(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Widget content;

    if (_isResolving) {
      content = _loadingPlaceholder();
    } else {
      content = CachedNetworkImage(
        imageUrl: _resolvedUrl!,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, _) => _loadingPlaceholder(),
        errorWidget: (_, _, error) {
          debugPrint('Image loading failed: $error');

          // Retry once with a fresh URL for private storage images.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_retried) {
              _retryExpiredUrl();
            } else if (mounted) {
              _setError();
            }
          });

          return _loadingPlaceholder();
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: SizedBox(
            width: double.infinity,
            child: AspectRatio(aspectRatio: 1, child: content),
          ),
        ),
        if (widget.caption.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              widget.caption,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  Widget _loadingPlaceholder() {
    return SizedBox.expand(
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        period: const Duration(milliseconds: 1500),
        direction: ShimmerDirection.ltr,
        child: const ColoredBox(color: Colors.white),
      ),
    );
  }
}

class ChecklistWidget extends StatefulWidget {
  final List<dynamic> items;

  const ChecklistWidget({super.key, required this.items});

  @override
  State<ChecklistWidget> createState() => _ChecklistWidgetState();
}

class _ChecklistWidgetState extends State<ChecklistWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.items
          .map((item) {
            final itemData = _asMap(item);
            final meta = _asMap(itemData['meta']);
            final children = _asList(itemData['items']);

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Column(
                children: [
                  CheckboxListTile(
                    value: meta['checked'] == true,
                    onChanged: (value) {
                      setState(() {
                        meta['checked'] = value ?? false;
                      });
                    },
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: SelectableText(
                      _plainText(itemData['content'] ?? item),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  if (children.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: ChecklistWidget(items: children),
                    ),
                ],
              ),
            );
          })
          .toList(growable: false),
    );
  }
}

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

class RecursiveListWidget extends StatelessWidget {
  final List<dynamic> items;
  final bool ordered;
  final int indentLevel;

  const RecursiveListWidget({
    super.key,
    required this.items,
    this.ordered = false,
    this.indentLevel = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(items.length, (index) {
        final item = items[index];
        final itemData = _asMap(item);
        final content = itemData.isEmpty ? item : itemData['content'];
        final children = _asList(itemData['items']);

        return Padding(
          padding: EdgeInsets.only(left: 16.0 * indentLevel, bottom: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ordered ? '${index + 1}.' : '•',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SelectableText(
                      _plainText(content),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              if (children.isNotEmpty)
                RecursiveListWidget(
                  items: children,
                  ordered: ordered,
                  indentLevel: indentLevel + 1,
                ),
            ],
          ),
        );
      }),
    );
  }
}

class CalloutWidget extends StatelessWidget {
  final String text;

  const CalloutWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: SelectableText(
              text,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class UIBuilder extends StatelessWidget {
  final List<dynamic>? blocks;
  final Map<String, dynamic>? json;

  const UIBuilder({super.key, this.blocks, this.json});

  @override
  Widget build(BuildContext context) {
    final resolvedBlocks = blocks ?? _asList(json?['blocks']);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final block in resolvedBlocks) _buildBlock(context, block),
        ],
      ),
    );
  }

  Widget _buildBlock(BuildContext context, dynamic block) {
    final blockData = _asMap(block);
    final type = blockData['type']?.toString().toLowerCase() ?? '';
    final data = _asMap(blockData['data']);

    switch (type) {
      case 'header':
        return HeadingWidget(
          text: _plainText(data['text']),
          level: data['level'] is num ? (data['level'] as num).toInt() : 1,
        );
      case 'paragraph':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: SelectableText(
            _plainText(data['text']),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.7),
          ),
        );
      case 'delimiter':
        return const DelimiterWidget();
      case 'image':
        final file = _asMap(data['file']);
        final storagePath = extractStoragePath(file);
        final url =
            storagePath ??
            file['url']?.toString() ??
            file['path']?.toString() ??
            '';
        return ImageWidget(imageUrl: url, caption: _plainText(data['caption']));
      case 'list':
        final items = _asList(data['items']);
        if (data['style'] == 'checklist') {
          return ChecklistWidget(items: items);
        }
        return RecursiveListWidget(
          items: items,
          ordered: data['style'] == 'ordered',
        );
      case 'checklist':
        return ChecklistWidget(items: _asList(data['items']));
      case 'callout':
        return CalloutWidget(text: _plainText(data['text']));
      default:
        return _UnsupportedBlock(type: type, data: data);
    }
  }
}

class _UnsupportedBlock extends StatelessWidget {
  final String type;
  final Map<String, dynamic> data;

  const _UnsupportedBlock({required this.type, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: ExpansionTile(
        title: const Text('Unsupported block'),
        subtitle: Text(type.isEmpty ? 'Unknown type' : type),
        childrenPadding: const EdgeInsets.all(12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Type: ${type.isEmpty ? 'Unknown' : type}'),
          const SizedBox(height: 8),
          const Text('Data', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          SelectableText(const JsonEncoder.withIndent('  ').convert(data)),
        ],
      ),
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is! Map) return const {};
  return Map<String, dynamic>.from(value);
}

List<dynamic> _asList(dynamic value) => value is List ? value : const [];

String _plainText(dynamic value) {
  if (value == null) return '';

  return value
      .toString()
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</p\s*>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&apos;', "'")
      .replaceAll('&amp;', '&')
      .trim();
}
