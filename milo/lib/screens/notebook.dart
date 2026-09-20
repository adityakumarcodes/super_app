import 'package:milo/atoms/speed_fab.dart';
import 'package:milo/screens/home.dart';
import 'package:milo/atoms/icon_tile.dart';
import 'package:milo/atoms/uibuilder.dart';
import 'package:milo/models/task.dart';
import 'package:milo/providers/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

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
      context.read<TaskProvider>().fetchTasks();
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
        title: const Text('Notebook'),
        centerTitle: true,
        elevation: 2,
        shape: Border(bottom: BorderSide(color: Colors.black, width: 2)),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final tasks = taskProvider.tasks ?? [];
          final isLoading = taskProvider.isLoading;
          final error = taskProvider.error;

          if (isLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator.adaptive(),
              ),
            );
          }

          if (error != null) {
            return Center(child: Text('Error: $error'));
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$feature coming soon')));
  }

  Widget _buildTaskItem(BuildContext context, Task task) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(
        title: Text(task.title, style: const TextStyle(fontSize: 18)),
        leading: const Icon(LucideIcons.asterisk),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        tileColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        onTap: () => _showTaskModal(context, task),
      ),
    );
  }

  void _showTaskModal(BuildContext context, Task task) {
    showModalBottomSheet(
      clipBehavior: Clip.hardEdge,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.2,
          maxChildSize: 1,
          expand: false,
          builder: (_, controller) => SingleChildScrollView(
            controller: controller,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Icon(
                    LucideIcons.chevronUp,
                    color: Colors.grey,
                    size: 30,
                  ),
                  Text(
                    task.title,
                    style: GoogleFonts.bodoniModa(fontSize: 45),
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    DateFormat.yMMMd().add_jm().format(
                      DateTime.parse(task.createdOn),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // SelectableText(
                  //   jsonEncode(
                  //     task.content,
                  //   ),
                  //   style: const TextStyle(
                  //     fontSize: 25,
                  //   ),
                  // ),
                  UIBuilder(json: task.content ?? {}),
                  const SizedBox(height: 40),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.icon(
                        onPressed: () {},
                        label: const Text('Edit'),
                        icon: const Icon(LucideIcons.pen),
                      ),
                      FilledButton.icon(
                        onPressed: () => Navigator.pop(context),
                        label: const Text('Close'),
                        icon: const Icon(LucideIcons.x),
                      ),
                      FilledButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirm Delete'),
                                content: const Text(
                                  'Are you sure you want to delete this item?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () {
                                      // Perform delete logic here
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        label: const Text('Delete'),
                        icon: const Icon(LucideIcons.trash2),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(50),
          topRight: Radius.circular(50),
        ),
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
