import 'package:any_link_preview/any_link_preview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ChecklistWidget extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const ChecklistWidget({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) {
        return CheckboxListTile(
          value: item['meta']['checked'] ?? false,
          onChanged: null,
          title: SelectableText(item['content'] ?? ''),
          controlAffinity: ListTileControlAffinity.leading,
        );
      }).toList(),
    );
  }
}

class DelimiterWidget extends StatelessWidget {
  const DelimiterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(LucideIcons.asterisk),
        Icon(LucideIcons.asterisk),
        Icon(LucideIcons.asterisk),
      ],
    );
  }
}

class ImageWidget extends StatelessWidget {
  final String imageUrl;
  final double borderRadius;

  const ImageWidget({
    super.key,
    required this.imageUrl,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover),
      ),
    );
  }
}

class HeadingWidget extends StatelessWidget {
  static const Map<int, double> _fontSizes = {
    1: 40.0,
    2: 35.0,
    3: 30.0,
    4: 25.0,
    5: 20.0,
    6: 15.0,
  };

  final String text;
  final int level;

  const HeadingWidget({super.key, required this.text, this.level = 1});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SelectableText(
        text,
        style: GoogleFonts.bodoniModa(fontSize: _fontSizes[level.clamp(1, 6)]!),
      ),
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
        return Padding(
          padding: EdgeInsets.only(left: 16.0 * indentLevel, bottom: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ordered ? '${index + 1}.' : '•',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item['content'] ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              if (item['items'] != null && item['items'].isNotEmpty)
                RecursiveListWidget(
                  items: List<Map<String, dynamic>>.from(item['items']),
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

// class YTPreviewWidget extends StatefulWidget {
//   final String url;

//   const YTPreviewWidget({super.key, required this.url});

//   @override
//   State<YTPreviewWidget> createState() => _YTPreviewWidgetState();
// }

// class _YTPreviewWidgetState extends State<YTPreviewWidget> {
//   YoutubePlayerController? _controller;
//   String? _videoId;
//   bool _isPlayerReady = false;

//   void _extractVideoId() {
//     final id = YoutubePlayer.convertUrlToId(widget.url);
//     if (id != null) {
//       setState(() {
//         _videoId = id;
//         _isPlayerReady = false;
//         _controller?.dispose();
//         _controller = null;
//       });
//     } else {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text('Invalid YouTube URL')));
//     }
//   }

//   void _loadPlayer() {
//     if (_videoId == null) return;
//     _controller = YoutubePlayerController(
//       initialVideoId: _videoId!,
//       flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
//     );
//     setState(() {
//       _isPlayerReady = true;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     _extractVideoId();
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         if (_videoId != null && !_isPlayerReady)
//           ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 Image.network(
//                   YoutubePlayer.getThumbnail(videoId: _videoId!),
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                 ),
//                 IconButton(
//                   iconSize: 64,
//                   icon: const Icon(Icons.play_circle_fill, color: Colors.white),
//                   onPressed: _loadPlayer,
//                 ),
//               ],
//             ),
//           ),
//         if (_controller != null && _isPlayerReady)
//           ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: YoutubePlayer(
//               controller: _controller!,
//               showVideoProgressIndicator: true,
//               progressIndicatorColor: Colors.amber,
//               progressColors: const ProgressBarColors(
//                 playedColor: Colors.amber,
//                 handleColor: Colors.amberAccent,
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }

class LinkPreviewWidget extends StatelessWidget {
  final String url;

  const LinkPreviewWidget({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AnyLinkPreview(
        link: url,
        displayDirection: UIDirection.uiDirectionVertical,
        titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        bodyStyle: const TextStyle(fontSize: 14),
        errorBody: 'Could not load preview',
        errorTitle: 'Invalid link',
        errorWidget: const Icon(Icons.error),
      ),
    );
  }
}

class UIBuilder extends StatelessWidget {
  final Map<String, dynamic> json;

  const UIBuilder({super.key, required this.json});

  @override
  Widget build(BuildContext context) {
    final blocks = (json['blocks'] as List<dynamic>?)?.skip(1).toList() ?? [];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: blocks.length,
      itemBuilder: (context, index) {
        return _buildBlock(context, blocks[index]);
      },
    );
  }

  Widget _buildBlock(BuildContext context, dynamic block) {
    final type = block['type'] as String?;
    final data = block['data'] as Map<String, dynamic>? ?? {};

    switch (type) {
      case 'header':
        return HeadingWidget(
          text: data['text'] ?? '',
          level: data['level'] is int ? data['level'] as int : 1,
        );
      case 'paragraph':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(data['text'] ?? '', style: const TextStyle(fontSize: 16)),
        );
      case 'delimiter':
        return const DelimiterWidget();
      case 'image':
        return ImageWidget(imageUrl: data['file']?['url'] ?? '');
      case 'list':
        return RecursiveListWidget(
          items: List<dynamic>.from(data['items'] ?? []),
          ordered: data['style'] == 'ordered',
        );
      case 'checklist':
        return ChecklistWidget(
          items: List<Map<String, dynamic>>.from(data['items'] ?? []),
        );
      // case 'embed':
      //   return YTPreviewWidget(url: data['source'] ?? '');
      case 'linkTool':
        return LinkPreviewWidget(url: data['link'] ?? '');
      default:
        return const SizedBox.shrink();
    }
  }
}
