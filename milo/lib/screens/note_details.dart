import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:milo/atoms/uibuilder.dart';
import 'package:milo/models/task.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:milo/features/notes/presentation/bloc/task_cubit.dart';

class NoteDetailsPage extends StatefulWidget {
  final Task task;

  const NoteDetailsPage({super.key, required this.task});

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
    if (oldWidget.task.id != widget.task.id) {
      _details = _fetchDetails();
    }
  }

  Future<Task> _fetchDetails({bool forceRefresh = false}) {
    return context.read<TaskCubit>().fetchTask(
      widget.task.id,
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
        final task = snapshot.data ?? widget.task;
        return _buildPage(
          context,
          task,
          isLoading: snapshot.connectionState == ConnectionState.waiting,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final createdDate = DateTime.tryParse(task.createdOn);
    final hasDescription = task.description.trim().isNotEmpty;
    final hasBlocks = task.blocks.isNotEmpty;

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

                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  )
                else if (error != null)
                  _DetailsError(onRetry: _retry)
                else ...[
                  if (hasDescription)
                    Text(
                      task.description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.7,
                        color: colorScheme.onSurface,
                      ),
                    ),

                  if (hasDescription && hasBlocks) const SizedBox(height: 24),

                  if (hasBlocks) UIBuilder(blocks: task.blocks),

                  if (!hasDescription && !hasBlocks)
                    Text(
                      'No content yet.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],

                const SizedBox(height: 40),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Navigate to the existing note editor.
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

    if (shouldDelete == true && context.mounted) {
      // TODO: Dispatch the delete use case after the write API is available.
      Navigator.pop(context);
    }
  }
}

class _DetailsError extends StatelessWidget {
  final VoidCallback onRetry;

  const _DetailsError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
            'Could not load note details.',
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
