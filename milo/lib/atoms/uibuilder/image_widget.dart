// ignore_for_file: unused_field

part of '../uibuilder.dart';

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
