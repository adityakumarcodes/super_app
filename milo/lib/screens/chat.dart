import 'dart:ui';

import 'package:milo/atoms/constants.dart';
import 'package:material_ui/material_ui.dart';
import 'package:milo/atoms/my_app_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:milo/atoms/speed_fab.dart';
import 'package:milo/features/chat/chat_cubit.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: 'Chat'),
      body: BlocSelector<ChatCubit, ChatState, int>(
        selector: (state) => state.selectedIndex,
        builder: (context, selectedIndex) {
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: chatUsers.length,
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () {
                  context.read<ChatCubit>().selectConversation(index);
                  context.push('/chat/details');
                },
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
                        label: 'Preview ${chatUsers[index].name} profile photo',
                        child: Hero(
                          tag: 'chat-profile-${chatUsers[index].imageURL}',
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
                              color: Theme.of(context).scaffoldBackgroundColor,
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
          );
        },
      ),
      floatingActionButton: ActionFab(
        expandIcon: const Icon(LucideIcons.messagesCircle),
        collapseIcon: const Icon(LucideIcons.x),
        actions: [
          FabAction(
            icon: const Icon(LucideIcons.calendarDays),
            label: 'Calendar',
            onPressed: () => context.push('/calendar'),
          ),
          FabAction(icon: const Icon(LucideIcons.users), label: 'Create Group'),
          FabAction(
            icon: const Icon(LucideIcons.video),
            label: 'Schedule Meet',
          ),
          FabAction(
            icon: const Icon(LucideIcons.messageSquarePlus),
            label: 'New Chat',
          ),
        ],
      ),
    );
  }
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
