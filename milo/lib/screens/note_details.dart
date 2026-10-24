// ignore_for_file: unused_import

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:milo/atoms/uibuilder.dart';
import 'package:milo/core/task.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:milo/features/notes/task_cubit.dart';

class NoteDetailsPage extends StatefulWidget {
  final int noteId;
  final Task? initialTask;

  const NoteDetailsPage({super.key, required this.noteId, this.initialTask});

  @override
  State<NoteDetailsPage> createState() => _NoteDetailsPageState();
}

class _NoteDetailsPageState extends State<NoteDetailsPage> {
  late Future<Task> _details;

  @override
  void initState() {
    super.initState();
    _details = _fetchDetails();
  }

  @override
  void didUpdateWidget(covariant NoteDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.noteId != widget.noteId) {
      _details = _fetchDetails();
    }
  }

  Future<Task> _fetchDetails({bool forceRefresh = false}) {
    return context.read<TaskCubit>().fetchTask(
      widget.noteId,
      forceRefresh: forceRefresh,
    );
  }

  void _retry() {
    setState(() {
      _details = _fetchDetails(forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Task>(
      future: _details,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final task = snapshot.data ?? widget.initialTask;
        if (task == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: isLoading
                  ? const CircularProgressIndicator.adaptive()
                  : _DetailsError(error: snapshot.error, onRetry: _retry),
            ),
          );
        }
        return _buildPage(
          context,
          task,
          isLoading: isLoading,
          error: snapshot.error,
        );
      },
    );
  }

  Widget _buildPage(
    BuildContext context,
    Task task, {
    required bool isLoading,
    required Object? error,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            pinned: true,
            title: Text(
              task.displayTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // centerTitle: true,
            actions: [
              IconButton(
                tooltip: 'Search',
                icon: const Icon(Icons.search),
                onPressed: () {},
              ),
              IconButton(
                tooltip: 'More options',
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
              ),
              const SizedBox(width: 4),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // if (createdDate != null)
                //   Row(
                //     children: [
                //       Icon(
                //         LucideIcons.clock,
                //         size: 15,
                //         color: colorScheme.onSurfaceVariant,
                //       ),
                //       const SizedBox(width: 8),
                //       Text(
                //         DateFormat.yMMMd().add_jm().format(createdDate),
                //         style: theme.textTheme.bodySmall?.copyWith(
                //           color: colorScheme.onSurfaceVariant,
                //         ),
                //       ),
                //     ],
                //   ),

                const SizedBox(height: 28),
                if (task.coverUrl != null)
                  ImageWidget(imageUrl: task.coverUrl!),
                const SizedBox(height: 24),

                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  )
                else if (error != null)
                  _DetailsError(error: error, onRetry: _retry)
                else if (task.blocks.isNotEmpty)
                  UIBuilder(blocks: task.blocks),

                const SizedBox(height: 40),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        // Editing needs the full note, not the list preview.
                        onPressed: isLoading || error != null
                            ? null
                            : () => _edit(task),
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
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
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

    if (shouldDelete != true || !context.mounted) return;
    try {
      await context.read<TaskCubit>().deleteTask(widget.noteId);
      if (!context.mounted) return;
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/notebook');
      }
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  Future<void> _edit(Task task) async {
    final updated = await context.push<Task>(
      '/notebook/note/${task.id}/edit',
      extra: task,
    );
    if (updated == null || !mounted) return;
    // The save response is the full note, so show it without refetching.
    setState(() => _details = SynchronousFuture(updated));
  }
}

class _DetailsError extends StatelessWidget {
  final Object? error;
  final VoidCallback onRetry;

  const _DetailsError({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final message =
        error?.toString().replaceFirst('Exception: ', '') ??
        'Could not load note details.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onErrorContainer),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(LucideIcons.refreshCw),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
