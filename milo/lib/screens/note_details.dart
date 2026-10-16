import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:milo/models/task.dart';

class NoteDetailsPage extends StatelessWidget {
  final Task task;

  const NoteDetailsPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final createdDate = DateTime.tryParse(task.createdOn);
    final hasDescription = task.description.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        //   // Use the application's Material 3 theme.
        //   backgroundColor: colorScheme.surface,
        //   foregroundColor: colorScheme.onSurface,
        //   elevation: 0,
        //   scrolledUnderElevation: 0,
        //   centerTitle: true,
        //   title: Text('Note', style: theme.textTheme.titleLarge),
        //   shape: Border(bottom: BorderSide(color: colorScheme.outline, width: 2)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.displayTitle,
                style: GoogleFonts.bodoniModa(
                  textStyle: theme.textTheme.headlineMedium,
                  fontSize: 42,
                  height: 1.12,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 16),

              if (createdDate != null)
                Row(
                  children: [
                    Icon(
                      LucideIcons.clock,
                      size: 15,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat.yMMMd().add_jm().format(createdDate),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 28),

              Divider(color: colorScheme.outline, thickness: 1.5),

              const SizedBox(height: 24),

              Text(
                hasDescription ? task.description : 'No content yet.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.7,
                  color: hasDescription
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                ),
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
                        foregroundColor: colorScheme.primary,
                        side: BorderSide(
                          color: colorScheme.outline,
                          width: 1.5,
                        ),
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
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
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
    final theme = Theme.of(context);

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
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
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
