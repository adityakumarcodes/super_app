import 'package:material_ui/material_ui.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SpeedFab extends StatelessWidget {
  const SpeedFab({
    super.key,
    this.onNewNote,
    this.onTranscribeAudio,
    this.onNewFolder,
    this.onUpload,
  });

  final VoidCallback? onNewNote;
  final VoidCallback? onTranscribeAudio;
  final VoidCallback? onNewFolder;
  final VoidCallback? onUpload;

  @override
  Widget build(BuildContext context) {
    final items = <M3EFabMenuItem>[
      if (onNewNote != null)
        M3EFabMenuItem(
          icon: const Icon(LucideIcons.filePlus),
          label: 'New Note',
          onPressed: onNewNote,
        ),
      if (onTranscribeAudio != null)
        M3EFabMenuItem(
          icon: const Icon(LucideIcons.mic),
          label: 'Record',
          onPressed: onTranscribeAudio,
        ),
      if (onUpload != null)
        M3EFabMenuItem(
          icon: const Icon(LucideIcons.upload),
          label: 'Upload',
          onPressed: onUpload,
        ),
      if (onNewFolder != null)
        M3EFabMenuItem(
          icon: const Icon(LucideIcons.folderPlus),
          label: 'New Folder',
          onPressed: onNewFolder,
        ),
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    // M3EFabMenu supports 2–6 items.
    if (items.length == 1) {
      return M3EFab(icon: items.first.icon, onPressed: items.first.onPressed);
    }

    return M3EFabMenu(
      position: M3EFabMenuPosition.right,
      size: M3EFabSize.regular,
      color: M3EFabColor.primary,
      expandIcon: const Icon(LucideIcons.plus),
      collapseIcon: const Icon(LucideIcons.x),
      closeOnItemTap: true,
      items: items,
    );
  }
}
