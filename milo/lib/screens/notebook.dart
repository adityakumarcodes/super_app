import 'package:milo/atoms/scrolling_text.dart';
import 'package:milo/atoms/speed_fab.dart';
import 'package:milo/screens/home.dart';
import 'package:milo/atoms/icon_tile.dart';
import 'package:milo/atoms/new_folder_dialog.dart';
import 'package:milo/core/task.dart';
import 'package:milo/features/notes/task_cubit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class NotebookPage extends StatefulWidget {
  const NotebookPage({super.key});

  @override
  State<NotebookPage> createState() => _NotebookPageState();
}

class _NotebookPageState extends State<NotebookPage> {
  final List<CategoryItem> folders = [
    _folder('My Notes'),
    _folder('My Skills'),
    _folder('TODOS'),
  ];

  static CategoryItem _folder(String name) => CategoryItem(
    icon: LucideIcons.folder,
    text: name,
    route: '/notebook/folder/${Uri.encodeComponent(name.replaceAll(' ', '-'))}',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskCubit>().fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        centerTitle: true,
        elevation: 2,
        shape: Border(bottom: BorderSide(color: Colors.black, width: 2)),
      ),
      body: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, taskState) {
          final tasks = taskState.tasks;
          final isLoading = taskState.isLoading;
          final error = taskState.error;

          // Once notes are shown, refreshing keeps them on screen.
          if (isLoading && tasks.isEmpty) {
            return const _NotesSkeleton();
          }

          if (error != null && tasks.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(error, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => context.read<TaskCubit>().refreshTasks(),
                      icon: const Icon(LucideIcons.refreshCw),
                      label: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<TaskCubit>().refreshTasks(),
            child: CustomScrollView(
              // Lets pull-to-refresh work when the list is short.
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                if (error != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Text(
                        error,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                SliverPadding(
                  padding: const EdgeInsets.all(8.0),
                  sliver: SliverGrid.count(
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: folders.map((item) {
                      return IconTile(
                        item: item,
                        onTap: () => context.push(item.route),
                      );
                    }).toList(),
                  ),
                ),
                if (tasks.isEmpty)
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('No notes yet. Tap + to write one.'),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildTaskItem(context, tasks[index]),
                      childCount: tasks.length,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: SpeedFab(
        onNewNote: () => context.push('/notebook/addTask'),
        onTranscribeAudio: () =>
            _showFeatureComingSoon(context, 'Transcribe Audio'),
        onNewFolder: _createFolder,
        onUpload: () =>
            _showFeatureComingSoon(context, 'Upload files & photos'),
      ),
    );
  }

  void _showFeatureComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature will be available soon.')));
  }

  Widget _buildTaskItem(BuildContext context, Task task) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Theme.of(context).colorScheme.onSurface,
            width: 2,
          ),
        ),
        leading: const Icon(LucideIcons.asterisk),
        title: ScrollingText(
          text: task.displayTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        onTap: () {
          context.push('/notebook/note/${task.id}', extra: task);
        },
      ),
    );
  }

  Future<void> _createFolder() async {
    final name = await showNewFolderDialog(context);
    if (name == null || !mounted) return;
    setState(() => folders.add(_folder(name)));
  }
}

/// Placeholder tiles shown while the first list of notes loads.
class _NotesSkeleton extends StatelessWidget {
  const _NotesSkeleton();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Loading notes',
      child: Shimmer.fromColors(
        baseColor: colorScheme.surfaceContainerHighest,
        highlightColor: colorScheme.surfaceContainerLow,
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: 6,
          itemBuilder: (_, _) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            child: SizedBox(
              height: 68,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
