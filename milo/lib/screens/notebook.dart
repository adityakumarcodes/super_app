import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:milo/atoms/speed_fab.dart';
import 'package:milo/models/note_folder.dart';
import 'package:milo/models/task.dart';
import 'package:milo/providers/task_provider.dart';
import 'package:provider/provider.dart';

enum _FolderAction { rename, delete }

enum _NoteAction { select, move, copy, delete }

enum _BulkAction { selectAll, move, copy, delete }

class _FolderDestination {
  final int? folderId;

  const _FolderDestination(this.folderId);
}

class NotebookPage extends StatefulWidget {
  final int? folderId;

  const NotebookPage({super.key, this.folderId});

  @override
  State<NotebookPage> createState() => _NotebookPageState();
}

class _NotebookPageState extends State<NotebookPage> {
  final Set<int> _selectedTaskIds = <int>{};

  bool get _isSelecting => _selectedTaskIds.isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final currentFolder = taskProvider.folderById(widget.folderId);
        final notes = widget.folderId == null
            ? taskProvider.tasks
            : taskProvider.tasks
                  .where((task) => task.folderId == widget.folderId)
                  .toList();

        return Scaffold(
          appBar: _buildAppBar(context, taskProvider, currentFolder, notes),
          body: _buildBody(context, taskProvider, currentFolder, notes),
          floatingActionButton: _isSelecting
              ? null
              : SpeedFab(
                  onNewNote: () => _openNewNote(context),
                  onNewFolder: () => _showFolderDialog(context),
                  onUploadAndRecord: () =>
                      _showFeatureComingSoon(context, 'Upload files & photos'),
                ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    TaskProvider taskProvider,
    NoteFolder? currentFolder,
    List<Task> notes,
  ) {
    if (_isSelecting) {
      return AppBar(
        leading: IconButton(
          tooltip: 'Clear selection',
          icon: const Icon(Icons.close_rounded),
          onPressed: _clearSelection,
        ),
        title: Text('${_selectedTaskIds.length} selected'),
        actions: [
          IconButton(
            tooltip: 'Move selected notes',
            icon: const Icon(Icons.drive_file_move_outline),
            onPressed: () => _moveTasks(taskProvider, _selectedTaskIds),
          ),
          IconButton(
            tooltip: 'Copy selected notes',
            icon: const Icon(Icons.copy_outlined),
            onPressed: () => _copyTasks(taskProvider, _selectedTaskIds),
          ),
          IconButton(
            tooltip: 'Share selected notes',
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _showSharePlaceholder(context),
          ),
          PopupMenuButton<_BulkAction>(
            tooltip: 'More actions',
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (action) =>
                _handleBulkAction(action, taskProvider, notes),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _BulkAction.selectAll,
                child: ListTile(
                  leading: Icon(Icons.select_all_rounded),
                  title: Text('Select all'),
                ),
              ),
              PopupMenuItem(
                value: _BulkAction.move,
                child: ListTile(
                  leading: Icon(Icons.drive_file_move_outline),
                  title: Text('Move'),
                ),
              ),
              PopupMenuItem(
                value: _BulkAction.copy,
                child: ListTile(
                  leading: Icon(Icons.copy_outlined),
                  title: Text('Copy'),
                ),
              ),
              PopupMenuItem(
                value: _BulkAction.delete,
                child: ListTile(
                  leading: Icon(Icons.delete_outline),
                  title: Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return AppBar(
      title: Text(currentFolder?.name ?? 'Notes'),
      centerTitle: true,
      shape: const Border(bottom: BorderSide(color: Colors.black, width: 2)),
      leading: widget.folderId == null
          ? null
          : IconButton(
              tooltip: 'Back to notes',
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
      actions: currentFolder == null
          ? null
          : [
              PopupMenuButton<_FolderAction>(
                tooltip: 'Folder actions',
                onSelected: (action) =>
                    _handleFolderAction(context, currentFolder, action),
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _FolderAction.rename,
                    child: ListTile(
                      leading: Icon(Icons.drive_file_rename_outline),
                      title: Text('Rename folder'),
                    ),
                  ),
                  PopupMenuItem(
                    value: _FolderAction.delete,
                    child: ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text('Delete folder'),
                    ),
                  ),
                ],
              ),
            ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    TaskProvider taskProvider,
    NoteFolder? currentFolder,
    List<Task> notes,
  ) {
    if (taskProvider.isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (taskProvider.error != null) {
      return Center(child: Text('Could not load notes: ${taskProvider.error}'));
    }

    if (widget.folderId != null && currentFolder == null) {
      return const Center(child: Text('This folder no longer exists.'));
    }

    return CustomScrollView(
      slivers: [
        if (widget.folderId == null) ...[
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Folders',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: taskProvider.folders.length,
              itemBuilder: (context, index) =>
                  _buildFolderTile(context, taskProvider.folders[index]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Text(
                'All notes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 4)),
        ],
        if (notes.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  widget.folderId == null
                      ? 'No notes yet. Tap + to create one.'
                      : 'This folder is empty.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  _buildTaskItem(context, taskProvider, notes[index]),
              childCount: notes.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildFolderTile(BuildContext context, NoteFolder folder) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/notebook/folder/${folder.id}'),
        onLongPress: () => _showFolderActions(context, folder),
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 4),
          child: Row(
            children: [
              Icon(Icons.folder_rounded, color: colorScheme.onPrimaryContainer),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  folder.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Folder actions',
                icon: const Icon(Icons.more_vert_rounded),
                color: colorScheme.onPrimaryContainer,
                onPressed: () => _showFolderActions(context, folder),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskItem(
    BuildContext context,
    TaskProvider taskProvider,
    Task task,
  ) {
    final isSelected = _selectedTaskIds.contains(task.id);
    final folder = taskProvider.folderById(task.folderId);
    final colorScheme = Theme.of(context).colorScheme;
    final subtitle = task.preview.isEmpty ? 'Empty note' : task.preview;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(
        selected: isSelected,
        selectedTileColor: colorScheme.secondaryContainer,
        tileColor: colorScheme.surfaceContainerLow,
        title: Text(task.displayTitle, style: const TextStyle(fontSize: 18)),
        subtitle: Text(
          folder == null ? subtitle : '$subtitle · ${folder.name}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        leading: _isSelecting
            ? Checkbox(
                value: isSelected,
                onChanged: (_) => _toggleTaskSelection(task.id),
              )
            : Icon(
                task.isPinned
                    ? Icons.push_pin_rounded
                    : Icons.description_outlined,
              ),
        trailing: _isSelecting
            ? null
            : PopupMenuButton<_NoteAction>(
                tooltip: 'Note actions',
                onSelected: (action) =>
                    _handleNoteAction(taskProvider, task, action),
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _NoteAction.select,
                    child: ListTile(
                      leading: Icon(Icons.checklist_rounded),
                      title: Text('Select'),
                    ),
                  ),
                  PopupMenuItem(
                    value: _NoteAction.move,
                    child: ListTile(
                      leading: Icon(Icons.drive_file_move_outline),
                      title: Text('Move'),
                    ),
                  ),
                  PopupMenuItem(
                    value: _NoteAction.copy,
                    child: ListTile(
                      leading: Icon(Icons.copy_outlined),
                      title: Text('Copy'),
                    ),
                  ),
                  PopupMenuItem(
                    value: _NoteAction.delete,
                    child: ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text('Delete'),
                    ),
                  ),
                ],
              ),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        onTap: () {
          if (_isSelecting) {
            _toggleTaskSelection(task.id);
          } else {
            _openNote(context, task);
          }
        },
        onLongPress: () => _toggleTaskSelection(task.id),
      ),
    );
  }

  void _openNewNote(BuildContext context) {
    final folderQuery = widget.folderId == null
        ? ''
        : '?folderId=${widget.folderId}';
    context.push('/notebook/note$folderQuery');
  }

  void _openNote(BuildContext context, Task task) {
    context.push('/notebook/note?id=${task.id}');
  }

  void _toggleTaskSelection(int taskId) {
    setState(() {
      if (!_selectedTaskIds.add(taskId)) {
        _selectedTaskIds.remove(taskId);
      }
    });
  }

  void _clearSelection() => setState(_selectedTaskIds.clear);

  Future<void> _handleNoteAction(
    TaskProvider taskProvider,
    Task task,
    _NoteAction action,
  ) async {
    switch (action) {
      case _NoteAction.select:
        _toggleTaskSelection(task.id);
        return;
      case _NoteAction.move:
        await _moveTasks(taskProvider, [task.id]);
        return;
      case _NoteAction.copy:
        await _copyTasks(taskProvider, [task.id]);
        return;
      case _NoteAction.delete:
        await _deleteTasks(taskProvider, [task.id]);
        return;
    }
  }

  Future<void> _handleBulkAction(
    _BulkAction action,
    TaskProvider taskProvider,
    List<Task> notes,
  ) async {
    switch (action) {
      case _BulkAction.selectAll:
        setState(() {
          _selectedTaskIds
            ..clear()
            ..addAll(notes.map((task) => task.id));
        });
        return;
      case _BulkAction.move:
        await _moveTasks(taskProvider, _selectedTaskIds);
        return;
      case _BulkAction.copy:
        await _copyTasks(taskProvider, _selectedTaskIds);
        return;
      case _BulkAction.delete:
        await _deleteTasks(taskProvider, _selectedTaskIds);
        return;
    }
  }

  Future<void> _moveTasks(
    TaskProvider taskProvider,
    Iterable<int> taskIds,
  ) async {
    final ids = taskIds.toSet();
    final destination = await _pickDestinationFolder(
      context,
      taskProvider.folders,
      title: 'Move to folder',
    );
    if (destination == null || ids.isEmpty || !mounted) return;

    try {
      final movedRows = await taskProvider.moveTasks(ids, destination.folderId);
      if (!mounted) return;
      _clearSelection();
      _showMessage(
        movedRows == 0
            ? 'No notes were moved.'
            : 'Moved ${_noteCountLabel(movedRows)}.',
      );
    } catch (_) {
      if (mounted) _showMessage('Could not move the selected notes.');
    }
  }

  Future<void> _copyTasks(
    TaskProvider taskProvider,
    Iterable<int> taskIds,
  ) async {
    final ids = taskIds.toSet();
    final destination = await _pickDestinationFolder(
      context,
      taskProvider.folders,
      title: 'Copy to folder',
    );
    if (destination == null || ids.isEmpty || !mounted) return;

    try {
      final copiedRows = await taskProvider.copyTasks(
        ids,
        destination.folderId,
      );
      if (!mounted) return;
      _clearSelection();
      _showMessage(
        copiedRows == 0
            ? 'No notes were copied.'
            : 'Copied ${_noteCountLabel(copiedRows)}.',
      );
    } catch (_) {
      if (mounted) _showMessage('Could not copy the selected notes.');
    }
  }

  Future<void> _deleteTasks(
    TaskProvider taskProvider,
    Iterable<int> taskIds,
  ) async {
    final ids = taskIds.toSet();
    if (ids.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${_noteCountLabel(ids.length)}?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final deletedRows = await taskProvider.deleteTasks(ids);
      if (!mounted) return;
      _clearSelection();
      _showMessage(
        deletedRows == 0
            ? 'No notes were deleted.'
            : 'Deleted ${_noteCountLabel(deletedRows)}.',
      );
    } catch (_) {
      if (mounted) _showMessage('Could not delete the selected notes.');
    }
  }

  Future<_FolderDestination?> _pickDestinationFolder(
    BuildContext context,
    List<NoteFolder> folders, {
    required String title,
  }) async {
    return showModalBottomSheet<_FolderDestination>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(title: Text(title)),
            ListTile(
              leading: const Icon(Icons.folder_off_outlined),
              title: const Text('Unfiled'),
              onTap: () =>
                  Navigator.of(context).pop(const _FolderDestination(null)),
            ),
            for (final folder in folders)
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(folder.name),
                onTap: () =>
                    Navigator.of(context).pop(_FolderDestination(folder.id)),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showFolderActions(
    BuildContext context,
    NoteFolder folder,
  ) async {
    final action = await showModalBottomSheet<_FolderAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(title: Text(folder.name)),
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline),
              title: const Text('Rename folder'),
              onTap: () => Navigator.of(context).pop(_FolderAction.rename),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete folder'),
              onTap: () => Navigator.of(context).pop(_FolderAction.delete),
            ),
          ],
        ),
      ),
    );

    if (action != null && mounted) {
      await _handleFolderAction(context, folder, action);
    }
  }

  Future<void> _handleFolderAction(
    BuildContext context,
    NoteFolder folder,
    _FolderAction action,
  ) async {
    switch (action) {
      case _FolderAction.rename:
        await _showFolderDialog(context, folder: folder);
        return;
      case _FolderAction.delete:
        await _deleteFolder(context, folder);
        return;
    }
  }

  Future<void> _showFolderDialog(
    BuildContext context, {
    NoteFolder? folder,
  }) async {
    final controller = TextEditingController(text: folder?.name ?? '');
    final pageContext = context;

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(folder == null ? 'New folder' : 'Rename folder'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Folder name',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _saveFolder(
              pageContext,
              dialogContext,
              controller.text,
              folder,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => _saveFolder(
                pageContext,
                dialogContext,
                controller.text,
                folder,
              ),
              child: Text(folder == null ? 'Create' : 'Save'),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  Future<void> _saveFolder(
    BuildContext pageContext,
    BuildContext dialogContext,
    String name,
    NoteFolder? folder,
  ) async {
    try {
      final taskProvider = pageContext.read<TaskProvider>();
      if (folder == null) {
        await taskProvider.createFolder(name);
      } else {
        await taskProvider.renameFolder(folder.id, name);
      }
      if (!mounted) return;
      Navigator.of(dialogContext).pop();
      _showMessage(folder == null ? 'Folder created.' : 'Folder renamed.');
    } catch (_) {
      if (mounted) _showMessage('Choose a unique folder name.');
    }
  }

  Future<void> _deleteFolder(BuildContext context, NoteFolder folder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${folder.name}?'),
        content: const Text(
          'Notes in this folder will be kept as unfiled notes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await context.read<TaskProvider>().deleteFolder(folder.id);
      if (!mounted) return;
      if (widget.folderId == folder.id) {
        Navigator.of(context).maybePop();
      } else {
        _showMessage('Folder deleted. Notes were kept.');
      }
    } catch (_) {
      if (mounted) _showMessage('Could not delete this folder.');
    }
  }

  void _showSharePlaceholder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Share is ready to connect when you add a share service.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showFeatureComingSoon(BuildContext context, String feature) {
    _showMessage('$feature will be available soon.');
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  String _noteCountLabel(int count) => count == 1 ? '1 note' : '$count notes';
}
