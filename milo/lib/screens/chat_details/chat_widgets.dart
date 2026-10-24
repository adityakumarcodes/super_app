part of '../chat_details.dart';

/// Message composer modelled on WhatsApp / Google Messages: a rounded field
/// that grows up to six lines with attach and camera icons inside, and one
/// round action button that is a mic while empty and Send once there is text.
class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final VoidCallback onCamera;
  final VoidCallback onVoice;
  final bool canSend;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onAttach,
    required this.onCamera,
    required this.onVoice,
    required this.canSend,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        minLines: 1,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          hintText: 'Message',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.fromLTRB(18, 12, 4, 12),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Attach',
                      icon: const Icon(LucideIcons.paperclip),
                      onPressed: onAttach,
                    ),
                    if (!canSend)
                      IconButton(
                        tooltip: 'Camera',
                        icon: const Icon(Icons.photo_camera_outlined),
                        onPressed: onCamera,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            IconButton.filled(
              tooltip: canSend ? 'Send' : 'Voice message',
              iconSize: 22,
              style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
              onPressed: canSend ? onSend : onVoice,
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Icon(
                  canSend ? Icons.send : Icons.mic,
                  key: ValueKey(canSend),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessageBubble extends StatelessWidget {
  final String message;
  final bool isSender;
  final String time;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isSender,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final bubbleColor = isSender
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;

    final textColor = isSender
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isSender ? 20 : 4),
          bottomRight: Radius.circular(isSender ? 4 : 20),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: isSender
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: GoogleFonts.poppins(color: textColor, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            time,
            style: TextStyle(
              color: textColor.withAlpha((0.75 * 255).round()),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilePhotoViewer extends StatelessWidget {
  final String imageURL;
  final String name;
  final String heroTag;

  const ProfilePhotoViewer({
    super.key,
    required this.imageURL,
    required this.name,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(name),
      ),
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: Hero(
            tag: heroTag,
            child: Image.asset(
              imageURL,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.person, size: 120, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class CircularIconButton extends StatelessWidget {
  final Color color;
  final String label;
  final IconData icon;
  final void Function()? onPress;

  const CircularIconButton({
    super.key,
    required this.color,
    required this.label,
    required this.icon,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          margin: const EdgeInsets.all(16),
          height: 60,
          width: 60,
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 30),
            onPressed: onPress,
          ),
        ),
        Text(label),
      ],
    );
  }
}
