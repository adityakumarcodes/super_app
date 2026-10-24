import 'package:milo/atoms/speed_fab.dart';
import 'package:milo/atoms/uibuilder.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class FolderList extends StatefulWidget {
  final String folderName;

  const FolderList({super.key, required this.folderName});

  @override
  State<FolderList> createState() => _FolderListState();
}

class _FolderListState extends State<FolderList> {
  late final Future<List<Map<String, dynamic>>> _tasksFuture = fetchTasks();

  // Mock data until folders exist in the backend.
  Future<List<Map<String, dynamic>>> fetchTasks() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      {
        'id': 1,
        'title': 'Sample Task 1',
        'category': widget.folderName.toLowerCase(),
        'status_flag': 'active',
      },
      {
        'id': 2,
        'title': 'Sample Task 2',
        'category': widget.folderName.toLowerCase(),
        'status_flag': 'active',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.folderName.replaceAll('-', ' '),
          style: const TextStyle(fontSize: 20),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        elevation: 2,
        shape: Border(bottom: BorderSide(color: Colors.black, width: 2)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(
              child: Text('Empty Folder', style: TextStyle(fontSize: 20)),
            );
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 10,
                ),
                child: ListTile(
                  title: Text(
                    data[index]['title'],
                    style: const TextStyle(fontSize: 18),
                  ),
                  leading: const Icon(LucideIcons.asterisk),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 15,
                  ),
                  onTap: () {
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
                                    data[index]['title'] ?? '',
                                    style: GoogleFonts.bodoniModa(fontSize: 45),
                                    overflow: TextOverflow.visible,
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(_formatDate(data[index]['createdOn'])),
                                  const SizedBox(height: 15),
                                  UIBuilder(json: data[index]['content']),
                                  const SizedBox(height: 40),
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      FilledButton.icon(
                                        onPressed: () {},
                                        label: Text('Edit'),
                                        icon: Icon(LucideIcons.pen),
                                      ),
                                      FilledButton.icon(
                                        onPressed: () => Navigator.pop(context),
                                        label: Text('Close'),
                                        icon: Icon(LucideIcons.x),
                                      ),
                                      FilledButton.icon(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Confirm Delete'),
                                                content: Text(
                                                  'Are you sure you want to delete this item?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(
                                                        context,
                                                      ).pop(); // Close dialog
                                                    },
                                                    child: Text('Cancel'),
                                                  ),
                                                  FilledButton(
                                                    onPressed: () {
                                                      // Perform delete logic here
                                                      Navigator.of(
                                                        context,
                                                      ).pop(); // Close dialog
                                                    },
                                                    child: Text('Delete'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        label: Text('Delete'),
                                        icon: Icon(LucideIcons.trash2),
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
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: SpeedFab(
        onNewNote: () => context.push('/notebook/addTask'),
        onTranscribeAudio: () =>
            _showFeatureComingSoon(context, 'Transcribe Audio'),
        onNewFolder: () => _showFeatureComingSoon(context, 'New folder'),
        onUpload: () =>
            _showFeatureComingSoon(context, 'Upload files & photos'),
      ),
    );
  }

  String _formatDate(Object? value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    if (date == null) return '';
    return DateFormat.yMMMd().add_jm().format(date.toLocal());
  }

  void _showFeatureComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature will be available soon.')));
  }
}
