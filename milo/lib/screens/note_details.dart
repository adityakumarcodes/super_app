import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:milo/models/task.dart';

class NoteDetailsPage extends StatelessWidget {
  final Task task;

  const NoteDetailsPage({super.key, required this.task});

  static const Color _ink = Color(0xFF2F2D2D);
  static const Color _paper = Color(0xFFF8F6F2);

  @override
  Widget build(BuildContext context) {
    final createdDate = DateTime.tryParse(task.createdOn);

    return Scaffold(
      backgroundColor: _paper,
      appBar: AppBar(
        backgroundColor: _paper,
        foregroundColor: _ink,
        // elevation: 0,
        // centerTitle: true,
        // title: const Text('Note'),
        // shape: const Border(bottom: BorderSide(color: Colors.black, width: 2)),
        // actions: [
        //   IconButton(
        //     tooltip: 'Edit note',
        //     onPressed: () {},
        //     icon: const Icon(LucideIcons.pen),
        //   ),
        //   IconButton(
        //     tooltip: 'Delete note',
        //     onPressed: () => _confirmDelete(context),
        //     icon: const Icon(LucideIcons.trash2),
        //   ),
        // ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: GoogleFonts.bodoniModa(
                  fontSize: 42,
                  height: 1.12,
                  fontWeight: FontWeight.w500,
                  color: _ink,
                ),
              ),

              const SizedBox(height: 16),

              if (createdDate != null)
                Row(
                  children: [
                    const Icon(LucideIcons.clock, size: 15, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat.yMMMd().add_jm().format(createdDate),
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),

              const SizedBox(height: 28),

              const Divider(color: Colors.black, thickness: 1.5),

              const SizedBox(height: 24),

              // Render the note content.
              // if (task.content != null && task.content!.isNotEmpty)
              //   UIBuilder(json: task.content!)
              // else
              const Text(
                'No content yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 40),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Navigate to your existing note editor.
                      },
                      icon: const Icon(LucideIcons.pen),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _ink,
                        side: const BorderSide(color: Colors.black, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _confirmDelete(context),
                      icon: const Icon(LucideIcons.trash2),
                      label: const Text('Delete'),
                      style: FilledButton.styleFrom(
                        backgroundColor: _ink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete note?'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && context.mounted) {
      // TODO: Call your TaskProvider delete method here.
      // After successful deletion:
      Navigator.pop(context);
    }
  }
}
