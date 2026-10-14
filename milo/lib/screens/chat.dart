import 'dart:ui';

import 'package:milo/atoms/action_button.dart';
import 'package:milo/atoms/constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = <({String label, IconData icon, VoidCallback onPressed})>[
      (
        label: 'Schedule meeting',
        icon: LucideIcons.video,
        onPressed: () => _showComingSoon(context, 'Meeting scheduling'),
      ),
      (
        label: 'Calendar',
        icon: LucideIcons.calendarDays,
        onPressed: () => context.push('/calendar'),
      ),
      (
        label: 'Send file',
        icon: LucideIcons.paperclip,
        onPressed: () => _showComingSoon(context, 'File sharing'),
      ),
      (
        label: 'Share location',
        icon: LucideIcons.mapPin,
        onPressed: () => _showComingSoon(context, 'Location sharing'),
      ),
      (
        label: 'Create group',
        icon: LucideIcons.users,
        onPressed: () => _showComingSoon(context, 'Group creation'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        centerTitle: true,
        elevation: 2,
        shape: Border(bottom: BorderSide(color: Colors.black, width: 2)),
      ),
      body: Consumer<FriendProvider>(
        builder: (context, friendProvider, child) {
          final selectedIndex = friendProvider.friendSelectedToChat;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: actions
                        .map(
                          (action) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ActionButton(
                              label: action.label,
                              icon: action.icon,
                              onPressed: action.onPressed,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: chatUsers.length,
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        friendProvider.setFriendSelectedToChat(index);
                        context.push('/chat/details');
                      },
                      shape: Border(
                        top: index == 0
                            ? const BorderSide(color: Colors.black, width: 2)
                            : BorderSide.none,
                        bottom: index == chatUsers.length - 1
                            ? BorderSide.none
                            : const BorderSide(color: Colors.black, width: 2),
                      ),
                      tileColor: selectedIndex == index
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Colors.transparent,
                      leading: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          GestureDetector(
                            onTap: () =>
                                _showProfilePreview(context, chatUsers[index]),
                            child: Semantics(
                              button: true,
                              label:
                                  'Preview ${chatUsers[index].name} profile photo',
                              child: Hero(
                                tag:
                                    'chat-profile-${chatUsers[index].imageURL}',
                                child: CircleAvatar(
                                  backgroundImage: AssetImage(
                                    chatUsers[index].imageURL,
                                  ),
                                  maxRadius: 30,
                                ),
                              ),
                            ),
                          ),
                          if (index % 3 != 0)
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                height: 15,
                                width: 15,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        chatUsers[index].name,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      subtitle: Text(chatUsers[index].messageText),
                      trailing: Text(chatUsers[index].time),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'New chat',
        child: const Icon(LucideIcons.messageSquarePlus),
      ),
    );
  }
}

void _showComingSoon(BuildContext context, String feature) {
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text('$feature is not connected yet.')));
}

void _showProfilePreview(BuildContext context, ChatUsers user) {
  final heroTag = 'chat-profile-${user.imageURL}';
  Navigator.of(context).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) =>
          _ChatProfilePhotoViewer(user: user, heroTag: heroTag),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}

class _ChatProfilePhotoViewer extends StatelessWidget {
  final ChatUsers user;
  final String heroTag;

  const _ChatProfilePhotoViewer({required this.user, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    final imageSize = (MediaQuery.sizeOf(context).width - 64).clamp(0.0, 320.0);

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: ColoredBox(color: Colors.black.withValues(alpha: 0.12)),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: heroTag,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      user.imageURL,
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => SizedBox(
                        width: imageSize,
                        height: imageSize,
                        child: const ColoredBox(
                          color: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 120,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
