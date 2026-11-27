import 'package:milo/atoms/constants.dart';
import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:milo/features/chat/chat_cubit.dart';

part 'chat_details/chat_widgets.dart';

class ChatDetails extends StatefulWidget {
  const ChatDetails({super.key});

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

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature will be available soon.')));
  }

  void _showAttachmentSheet() {
    final attachments = [
      ('Files', LucideIcons.folder),
      ('Camera', LucideIcons.camera),
      ('Gallery', LucideIcons.image),
      ('Audio', LucideIcons.headphones),
      ('Location', LucideIcons.pin),
      ('Contact', LucideIcons.user),
      ('Block', LucideIcons.ban),
      ('Delete chat', LucideIcons.trash2),
      ('Report', LucideIcons.thumbsDown),
    ];

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          children: [
            for (final (label, icon) in attachments)
              CircularIconButton(
                label: label,
                icon: icon,
                onPress: () => Navigator.pop(context),
              ),
          ],
        ),
      ),
    );
  }

  void _showProfilePhoto(ChatUsers user) {
    final heroTag = 'chat-profile-${user.imageURL}';
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) =>
            ProfilePhotoViewer(
              imageURL: user.imageURL,
              name: user.name,
              heroTag: heroTag,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = context.watch<ChatCubit>().state.selectedIndex;
    final selectedUser = chatUsers[selectedIndex];

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
                Semantics(
                  button: true,
                  label: 'View ${selectedUser.name} profile photo',
                  child: GestureDetector(
                    onTap: () => _showProfilePhoto(selectedUser),
                    child: Hero(
                      tag: 'chat-profile-${selectedUser.imageURL}',
                      child: ClipOval(
                        child: Image.asset(
                          selectedUser.imageURL,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                if (selectedIndex % 3 == 0)
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
            onVoice: () => _showComingSoon('Voice messages'),
            canSend: _canSend,
          ),
        ],
      ),
    );
  }
}
