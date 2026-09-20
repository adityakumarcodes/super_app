import 'package:milo/atoms/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class ChatDetails extends StatefulWidget {
  final ChatUsers user;

  const ChatDetails({super.key, required this.user});

  @override
  State<ChatDetails> createState() => _ChatDetailsState();
}

class _ChatDetailsState extends State<ChatDetails> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _messageController = TextEditingController();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_updateSendState);
  }

  @override
  void dispose() {
    _messageController.removeListener(_updateSendState);
    _messageController.dispose();
    super.dispose();
  }

  void _updateSendState() {
    final canSend = _messageController.text.trim().isNotEmpty;
    if (canSend != _canSend) {
      setState(() {
        _canSend = canSend;
      });
    }
  }

  void _handleSend() {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    setState(() {
      messages.add(
        ChatMessage(messageContent: messageText, messageType: 'sender'),
      );
      _messageController.clear();
      _canSend = false;
    });
  }

  void _showAttachmentSheet() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      context: context,
      constraints: const BoxConstraints(maxWidth: 500),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircularIconButton(
                    label: 'Document',
                    icon: LucideIcons.file,
                    color: Colors.purple,
                    onPress: () {},
                  ),
                  CircularIconButton(
                    label: 'Camera',
                    icon: Icons.photo_camera,
                    color: Colors.red,
                    onPress: () {},
                  ),
                  CircularIconButton(
                    label: 'Gallery',
                    icon: LucideIcons.image,
                    color: Colors.pink,
                    onPress: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircularIconButton(
                    label: 'Audio',
                    icon: LucideIcons.headphones,
                    color: Colors.orange,
                    onPress: () {},
                  ),
                  CircularIconButton(
                    label: 'Location',
                    icon: LucideIcons.pin,
                    color: Colors.green,
                    onPress: () {},
                  ),
                  CircularIconButton(
                    label: 'Contact',
                    icon: LucideIcons.user,
                    color: Colors.blue,
                    onPress: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final friendProvider = context.watch<FriendProvider>();
    final selectedUser = chatUsers[friendProvider.friendSelectedToChat];
    final isOnline = (friendProvider.friendSelectedToChat % 3 != 0);

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 2,
        shape: const Border(bottom: BorderSide(color: Colors.black, width: 2)),
        leading: const BackButton(),
        title: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(selectedUser.imageURL),
                  radius: 20,
                ),
                if (isOnline)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      height: 12,
                      width: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    selectedUser.name,
                    style: GoogleFonts.poppins(fontSize: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(LucideIcons.video),
            tooltip: 'Video call',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(LucideIcons.phone),
            tooltip: 'Voice call',
          ),
          PopupMenuButton<String>(
            tooltip: 'More options',
            enableFeedback: true,
            icon: const Icon(LucideIcons.ellipsisVertical),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onSelected: handleClick,
            itemBuilder: (context) {
              return {'View profile', 'Search', 'Mute notifications'}.map((
                String choice,
              ) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isSender = message.messageType == 'sender';
                return Padding(
                  padding: EdgeInsets.only(
                    left: isSender ? 60 : 0,
                    right: isSender ? 0 : 60,
                    bottom: 12,
                  ),
                  child: Align(
                    alignment: isSender
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: ChatMessageBubble(
                      message: message.messageContent,
                      isSender: isSender,
                      time: DateFormat.Hm().format(DateTime.now()),
                    ),
                  ),
                );
              },
            ),
          ),
          ChatInputBar(
            controller: _messageController,
            onSend: _handleSend,
            onAttach: _showAttachmentSheet,
            canSend: _canSend,
          ),
        ],
      ),
      endDrawer: ClipRRect(
        child: Drawer(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                currentAccountPicture: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    selectedUser.imageURL,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                accountEmail: const Text('ak19992017@gmail.com'),
                accountName: Text(selectedUser.name),
              ),
              ListTile(
                leading: const Icon(LucideIcons.paperclip),
                title: const Text('Media, links and docs'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.block),
                title: const Text('Block'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(LucideIcons.trash2),
                title: const Text('Delete chat'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.thumb_down),
                title: const Text('Report'),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  void handleClick(String value) {
    switch (value) {
      case 'View profile':
        _scaffoldKey.currentState!.openEndDrawer();
        break;
      default:
        break;
    }
  }
}

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final bool canSend;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onAttach,
    required this.canSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.paperclip),
                      onPressed: onAttach,
                    ),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        minLines: 1,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: 'Write a message...',
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: canSend ? () {} : null,
              icon: const Icon(Icons.send),
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
