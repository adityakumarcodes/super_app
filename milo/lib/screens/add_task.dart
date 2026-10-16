import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:milo/providers/task_provider.dart';
import 'package:milo/services/task_database.dart';
import 'package:provider/provider.dart';

const Color _ink = Color(0xFF2F2D2D);
const Color _paper = Color(0xFFF8F6F2);
const int _unfiledFolderId = -1;

class AddTaskScreen extends StatefulWidget {
  final int? noteId;
  final int? folderId;

  const AddTaskScreen({super.key, this.noteId, this.folderId});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  late QuillController _controller;
  int? _folderId;
  bool _isEditingTitle = false;
  bool _isPinned = false;
  bool _isSaving = false;
  bool _isLoading = false;
  bool _hasInvalidDelta = false;

  String _initialTitle = '';
  String _initialDeltaJson = '';
  int? _initialFolderId;
  bool _initialPinned = false;

  bool get _isEditingExistingNote => widget.noteId != null;

  @override
  void initState() {
    super.initState();
    _folderId = widget.folderId;
    _controller = _newController();
    _captureInitialValues();

    if (_isEditingExistingNote) {
      _loadNote();
    }
  }

  QuillController _newController([Document? document]) {
    final config = QuillControllerConfig(
      clipboardConfig: QuillClipboardConfig(enableExternalRichPaste: true),
    );
    if (document == null) {
      return QuillController.basic(config: config);
    }
    return QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
      config: config,
    );
  }

  Future<void> _loadNote() async {
    setState(() => _isLoading = true);

    try {
      final row = await TaskDatabase.instance.getTask(widget.noteId!);
      if (row == null) {
        throw StateError('This note no longer exists.');
      }

      _hasInvalidDelta = false;
      final nextController = _newController(
        _documentFromDelta(row['delta_json'] as String? ?? '[]'),
      );
      nextController.readOnly = _hasInvalidDelta;

      if (!mounted) {
        nextController.dispose();
        return;
      }

      _controller.dispose();
      _controller = nextController;
      _titleController.text = row['title'] as String? ?? '';
      _folderId = row['folder_id'] as int?;
      _isPinned = (row['is_pinned'] as int? ?? 0) == 1;
      _captureInitialValues();
    } catch (error, stackTrace) {
      debugPrint('Failed to load note: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open this note.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Document _documentFromDelta(String deltaJson) {
    try {
      final decoded = jsonDecode(deltaJson);
      if (decoded is List) {
        return Document.fromJson(decoded);
      }
      _hasInvalidDelta = true;
    } catch (_) {
      _hasInvalidDelta = true;
    }
    return Document();
  }

  void _captureInitialValues() {
    _initialTitle = _titleController.text.trim();
    _initialDeltaJson = jsonEncode(_controller.document.toDelta().toJson());
    _initialFolderId = _folderId;
    _initialPinned = _isPinned;
  }

  bool get _hasUnsavedChanges {
    if (_isLoading) return false;
    return _titleController.text.trim() != _initialTitle ||
        jsonEncode(_controller.document.toDelta().toJson()) !=
            _initialDeltaJson ||
        _folderId != _initialFolderId ||
        _isPinned != _initialPinned;
  }

  Future<bool> _confirmDiscard() async {
    if (!_hasUnsavedChanges) return true;

    return (await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard changes?'),
            content: const Text('Your unsaved note changes will be lost.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Keep editing'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Discard'),
              ),
            ],
          ),
        )) ??
        false;
  }

  Future<void> _saveTask() async {
    if (_isSaving || _isLoading || _hasInvalidDelta) return;

    final title = _titleController.text.trim();
    final description = _controller.document.toPlainText().trim();
    if (title.isEmpty && description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a note title or details first.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await context.read<TaskProvider>().saveTask(
        id: widget.noteId,
        title: title,
        description: description,
        deltaJson: jsonEncode(_controller.document.toDelta().toJson()),
        folderId: _folderId,
        isPinned: _isPinned,
      );

      if (!mounted) return;
      _captureInitialValues();
      Navigator.of(context).pop(true);
    } catch (error, stackTrace) {
      debugPrint('Failed to save note: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save this note. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _chooseFolder() async {
    final taskProvider = context.read<TaskProvider>();
    await taskProvider.fetchTasks();
    if (!mounted) return;

    final folders = taskProvider.folders;
    final folderSelection = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(title: Text('Save note in folder')),
            ListTile(
              leading: Icon(
                _folderId == null
                    ? Icons.folder_off_rounded
                    : Icons.folder_off_outlined,
              ),
              title: const Text('Unfiled'),
              trailing: _folderId == null
                  ? const Icon(Icons.check_rounded)
                  : null,
              onTap: () => Navigator.of(context).pop(_unfiledFolderId),
            ),
            for (final folder in folders)
              ListTile(
                leading: Icon(
                  folder.id == _folderId
                      ? Icons.folder_rounded
                      : Icons.folder_outlined,
                ),
                title: Text(folder.name),
                trailing: folder.id == _folderId
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.of(context).pop(folder.id),
              ),
          ],
        ),
      ),
    );

    if (folderSelection != null && mounted) {
      setState(() {
        _folderId = folderSelection == _unfiledFolderId
            ? null
            : folderSelection;
      });
    }
  }

  void _startEditingTitle() {
    setState(() => _isEditingTitle = true);
    _titleFocusNode.requestFocus();
    _titleController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _titleController.text.length,
    );
  }

  void _finishEditingTitle() {
    _titleFocusNode.unfocus();
    setState(() => _isEditingTitle = false);
  }

  @override
  Widget build(BuildContext context) {
    final currentFolder = context.read<TaskProvider>().folderById(_folderId);
    final title = _isEditingExistingNote ? 'Edit note' : 'New note';

    return WillPopScope(
      onWillPop: _confirmDiscard,
      child: Scaffold(
        backgroundColor: _paper,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: _paper,
          foregroundColor: _ink,
          elevation: 0,
          centerTitle: true,
          toolbarHeight: _isEditingTitle ? 110 : 64,
          leading: IconButton(
            tooltip: 'Go back',
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () async {
              if (await _confirmDiscard() && mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: GestureDetector(
            onTap: _isLoading || _hasInvalidDelta || _isEditingTitle
                ? null
                : _startEditingTitle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: _isEditingTitle ? 12 : 0,
                vertical: _isEditingTitle ? 8 : 0,
              ),
              decoration: BoxDecoration(
                color: _isEditingTitle ? Colors.white : Colors.transparent,
                border: Border.all(
                  color: _isEditingTitle ? _ink : Colors.transparent,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _isEditingTitle
                  ? TextField(
                      controller: _titleController,
                      focusNode: _titleFocusNode,
                      autofocus: true,
                      textAlign: TextAlign.center,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 2,
                      minLines: 1,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Title',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (_) => _finishEditingTitle(),
                    )
                  : Text(
                      _titleController.text.trim().isEmpty
                          ? title
                          : _titleController.text.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          actions: [
            if (_isEditingTitle)
              IconButton(
                tooltip: 'Done editing title',
                onPressed: _finishEditingTitle,
                icon: const Icon(Icons.check_rounded),
              ),
            IconButton(
              tooltip: currentFolder == null
                  ? 'Choose folder'
                  : 'Folder: ${currentFolder.name}',
              onPressed: _isLoading || _hasInvalidDelta ? null : _chooseFolder,
              icon: Icon(
                currentFolder == null
                    ? Icons.folder_outlined
                    : Icons.folder_rounded,
              ),
            ),
            IconButton(
              tooltip: _isPinned ? 'Unpin note' : 'Pin note',
              onPressed: _isLoading || _hasInvalidDelta
                  ? null
                  : () => setState(() => _isPinned = !_isPinned),
              icon: Icon(
                _isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
              ),
            ),
            IconButton(
              tooltip: 'Save note',
              onPressed: _isSaving || _isLoading || _hasInvalidDelta
                  ? null
                  : _saveTask,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator.adaptive())
            : SafeArea(
                child: Column(
                  children: [
                    if (_hasInvalidDelta)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        color: Theme.of(context).colorScheme.errorContainer,
                        child: Text(
                          'This note uses unsupported rich-text data and is '
                          'read-only to protect its saved content.',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onErrorContainer,
                          ),
                        ),
                      ),
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: _paper,
                        border: Border(
                          bottom: BorderSide(color: _ink, width: 1.5),
                        ),
                      ),
                      child: QuillSimpleToolbar(
                        controller: _controller,
                        config: QuillSimpleToolbarConfig(
                          embedButtons: FlutterQuillEmbeds.toolbarButtons(),
                          multiRowsDisplay: false,
                          showClipboardPaste: true,
                          showDirection: false,
                          showFontFamily: false,
                          showFontSize: false,
                          showColorButton: false,
                          showBackgroundColorButton: false,
                          showSearchButton: false,
                          showSubscript: false,
                          showSuperscript: false,
                          buttonOptions: QuillSimpleToolbarButtonOptions(
                            base: QuillToolbarBaseButtonOptions(
                              afterButtonPressed: () {
                                _editorFocusNode.requestFocus();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: QuillEditor(
                        focusNode: _editorFocusNode,
                        scrollController: _editorScrollController,
                        controller: _controller,
                        config: QuillEditorConfig(
                          placeholder: 'Write your note details...',
                          padding: const EdgeInsets.all(20),
                          expands: true,
                          embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocusNode.dispose();
    _controller.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }
}
