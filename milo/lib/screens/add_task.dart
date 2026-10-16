// import 'package:flutter/material.dart';
// import 'package:milo/atoms/my_app_bar.dart';
// import 'package:lucide_icons_flutter/lucide_icons.dart';

// class AddTaskScreen extends StatefulWidget {
//   const AddTaskScreen({super.key});

//   @override
//   State<AddTaskScreen> createState() => _AddTaskScreenState();
// }

// class _AddTaskScreenState extends State<AddTaskScreen> {
//   final TextEditingController _task = TextEditingController();
//   final FocusNode _taskFocus = FocusNode();
//   final TextEditingController _description = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _taskFocus.requestFocus();
//     });
//   }

//   @override
//   void dispose() {
//     _task.dispose();
//     _description.dispose();
//     _taskFocus.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: MyAppBar(
//         title: 'Add Task',
//         actions: [
//           IconButton(
//             tooltip: 'Save',
//             icon: const Icon(LucideIcons.save),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: Form(
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 24.0),
//                     TextFormField(
//                       focusNode: _taskFocus,
//                       decoration: const InputDecoration(
//                         hintText: 'Title',
//                         hintStyle: TextStyle(fontSize: 40, color: Colors.grey),
//                         border: InputBorder.none,
//                       ),
//                       controller: _task,
//                       style: const TextStyle(fontSize: 40), //for cursor size
//                       maxLines: null,
//                       textInputAction: TextInputAction.next,
//                       keyboardType: TextInputType.name,
//                       textCapitalization: TextCapitalization.sentences,
//                     ),
//                     const SizedBox(height: 30.0),
//                     SizedBox(
//                       height: 150,
//                       child: TextFormField(
//                         decoration: const InputDecoration(
//                           border: InputBorder.none,
//                           hintText: 'Enter description here...',
//                           hintStyle: TextStyle(
//                             fontSize: 20,
//                             color: Colors.grey,
//                           ),
//                         ),
//                         controller: _description,
//                         style: const TextStyle(fontSize: 20), //for cursor size
//                         maxLines: null,
//                         expands: true,
//                         textInputAction: TextInputAction.newline,
//                         keyboardType: TextInputType.multiline,
//                         textCapitalization: TextCapitalization.sentences,
//                       ),
//                     ),
//                     const SizedBox(height: 24.0),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       // body:Padding(
//       // padding: const EdgeInsets.all(8.0),
//       // child: TextField(
//       //   controller: _task,
//       //   maxLines: null,r
//       //   expands: true,
//       //   decoration: const InputDecoration(
//       //     border: InputBorder.none,
//       //     hintText: 'Enter description here...',
//       //   ),
//       //   style: const TextStyle(fontSize: 16),
//       // ),
//       // )
//     );
//   }
// }

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:milo/services/task_database.dart';

const Color _ink = Color(0xFF2F2D2D);
const Color _paper = Color(0xFFF8F6F2);
const Color _surface = Color(0xFFF2F0ED);
const Color _muted = Color(0xFF77716C);
const Color _accent = Color(0xFFFF8A00);

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();

  bool _isEditingTitle = false;
  final QuillController _controller = QuillController.basic(
    config: QuillControllerConfig(
      clipboardConfig: QuillClipboardConfig(enableExternalRichPaste: true),
    ),
  );

  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  bool _isPinned = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _editorFocusNode.addListener(_onEditorFocusChanged);
  }

  void _onEditorFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  bool _shouldShowToolbar(BuildContext context) {
    final keyboardIsOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    // return keyboardIsOpen && _editorFocusNode.hasFocus;
    return true;
  }

  Future<void> _saveTask() async {
    if (_isSaving) return;

    final title = _titleController.text.trim();
    final description = _controller.document.toPlainText().trim();

    if (title.isEmpty && description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a task title or description first.')),
      );
      return;
    }

    // Preserve formatting, lists, links, and other supported Delta data.
    final deltaJson = jsonEncode(_controller.document.toDelta().toJson());

    setState(() => _isSaving = true);

    try {
      final taskId = await TaskDatabase.instance.insertTask(
        title: title,
        description: description,
        deltaJson: deltaJson,
        isPinned: _isPinned,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task saved locally (ID: $taskId)'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Optionally return the inserted ID to the previous screen:
      // Navigator.of(context).pop(taskId);
    } catch (error, stackTrace) {
      debugPrint('Failed to save task: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save task. Please try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildToolbar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      decoration: BoxDecoration(
        color: _surface,
        border: Border.all(color: _ink, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
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
    );
  }

  void _startEditingTitle() {
    setState(() {
      _isEditingTitle = true;
    });

    _titleFocusNode.requestFocus();
    _titleController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _titleController.text.length,
    );
  }

  void _finishEditingTitle() {
    _titleFocusNode.unfocus();

    setState(() {
      _isEditingTitle = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final showToolbar = _shouldShowToolbar(context);

    return Scaffold(
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
          onPressed: () {
            if (_isEditingTitle) {
              _finishEditingTitle();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),

        title: GestureDetector(
          onTap: () {
            if (!_isEditingTitle) {
              _startEditingTitle();
            }
          },
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
                        ? 'Title'
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
            tooltip: _isPinned ? 'Unpin task' : 'Pin task',
            onPressed: () {
              setState(() => _isPinned = !_isPinned);
            },
            icon: Icon(
              _isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
              color: _isPinned ? _accent : _ink,
            ),
          ),

          IconButton(
            tooltip: 'Save task',
            onPressed: _isSaving ? null : _saveTask,
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

      body: SafeArea(
        child: Column(
          children: [
            // Rich-text toolbar directly below the AppBar.
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: _paper,
                border: Border(bottom: BorderSide(color: _ink, width: 1.5)),
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

            // Full-screen rich-text editor.
            Expanded(
              child: QuillEditor(
                focusNode: _editorFocusNode,
                scrollController: _editorScrollController,
                controller: _controller,
                config: QuillEditorConfig(
                  placeholder: 'Write your task details...',
                  padding: const EdgeInsets.all(20),
                  expands: true,
                  embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                ),
              ),
            ),
          ],
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
