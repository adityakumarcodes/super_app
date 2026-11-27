import 'package:material_ui/material_ui.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ChatFab extends StatelessWidget {
  const ChatFab({
    super.key,
    this.onNewChat,
    this.onScheduleMeeting,
    this.onCalendar,
    this.onSendFile,
    this.onShareLocation,
    this.onCreateGroup,
  });

  final VoidCallback? onNewChat;
  final VoidCallback? onScheduleMeeting;
  final VoidCallback? onCalendar;
  final VoidCallback? onSendFile;
  final VoidCallback? onShareLocation;
  final VoidCallback? onCreateGroup;

  @override
  Widget build(BuildContext context) {
    final items = <M3EFabMenuItem>[
      if (onScheduleMeeting != null)
        M3EFabMenuItem(
          icon: const Icon(LucideIcons.video),
          label: 'Schedule Meet',
          onPressed: onScheduleMeeting,
        ),
      if (onCalendar != null)
        M3EFabMenuItem(
          icon: const Icon(LucideIcons.calendarDays),
          label: 'Calendar',
          onPressed: onCalendar,
        ),
      if (onSendFile != null)
        M3EFabMenuItem(
          icon: const Icon(LucideIcons.paperclip),
          label: 'Send File',
          onPressed: onSendFile,
        ),
      if (onShareLocation != null)
        M3EFabMenuItem(
          icon: const Icon(LucideIcons.mapPin),
          label: 'Share Location',
          onPressed: onShareLocation,
        ),
      if (onCreateGroup != null)
        M3EFabMenuItem(
          icon: const Icon(LucideIcons.users),
          label: 'Create Group',
          onPressed: onCreateGroup,
        ),
      if (onNewChat != null)
        M3EFabMenuItem(
          icon: const Icon(LucideIcons.messageSquarePlus),
          label: 'New Chat',
          onPressed: onNewChat,
        ),
    ];

    // No actions available.
    if (items.isEmpty && onNewChat == null) {
      return const SizedBox.shrink();
    }

    // Only New Chat available.
    if (items.isEmpty) {
      return M3EFab(
        icon: const Icon(LucideIcons.messageSquarePlus),
        onPressed: onNewChat,
      );
    }

    // One action: use a regular FAB.
    if (items.length == 1) {
      return M3EFab(icon: items.first.icon, onPressed: items.first.onPressed);
    }

    return M3EFabMenu(
      position: M3EFabMenuPosition.right,
      size: M3EFabSize.regular,
      color: M3EFabColor.primary,
      expandIcon: const Icon(LucideIcons.messageSquarePlus),
      collapseIcon: const Icon(LucideIcons.x),
      closeOnItemTap: true,
      items: items,
    );
  }
}
