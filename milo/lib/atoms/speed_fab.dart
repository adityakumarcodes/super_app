import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SpeedFab extends StatelessWidget {
  final VoidCallback? onNewNote;
  final VoidCallback? onTranscribeAudio;
  final VoidCallback? onNewFolder;
  final VoidCallback? onUpload;

  const SpeedFab({
    super.key,
    this.onNewNote,
    this.onTranscribeAudio,
    this.onNewFolder,
    this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: LucideIcons.plus,
      activeIcon: LucideIcons.x,
      spacing: 3,
      childPadding: const EdgeInsets.all(5),
      spaceBetweenChildren: 4,
      renderOverlay: true,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      children: [
        if (onNewNote != null)
          SpeedDialChild(
            child: const Icon(LucideIcons.filePlus),
            label: 'New Note',
            onTap: onNewNote,
          ),
        if (onTranscribeAudio != null)
          SpeedDialChild(
            child: const Icon(LucideIcons.audioLines),
            label: 'Transcribe Audio',
            onTap: onTranscribeAudio,
          ),
        if (onNewFolder != null)
          SpeedDialChild(
            child: const Icon(LucideIcons.folderPlus),
            label: 'New Folder',
            onTap: onNewFolder,
          ),
        if (onUpload != null)
          SpeedDialChild(
            child: const Icon(LucideIcons.imagePlus),
            label: 'Upload files & photos',
            onTap: onUpload,
          ),
      ],
    );
  }
}
