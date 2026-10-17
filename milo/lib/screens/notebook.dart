import 'package:milo/atoms/speed_fab.dart';
import 'package:milo/screens/home.dart';
import 'package:milo/atoms/icon_tile.dart';
import 'package:milo/models/task.dart';
import 'package:milo/features/notes/presentation/bloc/task_cubit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// ignore: unused_import
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotebookPage extends StatefulWidget {
  const NotebookPage({super.key});

  @override
  State<NotebookPage> createState() => _NotebookPageState();
}

class _NotebookPageState extends State<NotebookPage> {
  final TextEditingController _folderController = TextEditingController();
  final List<CategoryItem> folders = [
    const CategoryItem(
      icon: LucideIcons.folder,
      text: 'My Notes',
      route: '/home',
    ),
    const CategoryItem(
      icon: LucideIcons.folder,
      text: 'My Skills',
      route: '/play',
    ),
    const CategoryItem(icon: LucideIcons.folder, text: 'TODOS', route: '/code'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskCubit>().fetchTasks();
    });
  }

  @override
  void dispose() {
    _folderController.dispose();
    super.dispose();
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

          if (isLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator.adaptive(),
              ),
            );
          }

          if (error != null) {
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

          return CustomScrollView(
            slivers: [
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
                      onTap: () => context.push(
                        '/notebook/folder/${item.text.replaceAll(' ', '-')}',
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (tasks.isEmpty)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No tasks found'),
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
          );
        },
      ),
      floatingActionButton: SpeedFab(
        onNewNote: () => context.push('/notebook/addTask'),
        onTranscribeAudio: () =>
            _showFeatureComingSoon(context, 'Transcribe Audio'),
        onNewFolder: () => _dialogBuilder(context),
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
        tileColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
        leading: const Icon(LucideIcons.asterisk),
        title: Text(
          task.displayTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        // subtitle: task.preview.isEmpty ? null : Text(task.preview),
        onTap: () {
          context.push('/notebook/note/${task.id}', extra: task);
        },
      ),
    );
  }

  Future<void> _dialogBuilder(BuildContext context) {
    _folderController.clear();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('New folder'),
          content: TextField(
            controller: _folderController,
            decoration: const InputDecoration(
              hintText: 'Enter folder name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FilledButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Create'),
              onPressed: () {
                final folderName = _folderController.text.trim();
                if (folderName.isNotEmpty) {
                  setState(() {
                    folders.add(
                      CategoryItem(
                        icon: LucideIcons.folder,
                        text: folderName,
                        route: '/home',
                      ),
                    );
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
