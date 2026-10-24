import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:milo/atoms/my_app_bar.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:milo/atoms/note_format_bar.dart';
import 'package:milo/features/notes/task_cubit.dart';
import 'package:milo/core/task.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key, this.note});

  /// The note to edit, or null to create a new one.
  final Task? note;

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  late final TextEditingController _task = TextEditingController(
    text: widget.note?.title,
  );
  final FocusNode _taskFocus = FocusNode();
  // Null when the note has content that cannot be edited as text.
  late final String? _initialBody = widget.note == null
      ? ''
      : widget.note!.content;
  late final TextEditingController _description = TextEditingController(
    text: _initialBody,
  );
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _taskFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _task.dispose();
    _description.dispose();
    _taskFocus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _task.text.trim();
    final body = _description.text;
    if (title.isEmpty && body.trim().isEmpty) {
      _showMessage('Add a title or some text first.');
      return;
    }

    final tasks = context.read<TaskCubit>();
    final content = _initialBody == null ? null : body;
    final note = widget.note;
    setState(() => _isSaving = true);
    try {
      final saved = note == null
          ? await tasks.createTask(title: title, content: body)
          : await tasks.updateTask(note.id, title: title, content: content);
      if (mounted) context.pop(saved);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final canEditBody = _initialBody != null;

    return Scaffold(
      appBar: MyAppBar(
        title: widget.note == null ? 'Add Task' : 'Edit Task',
        actions: [
          IconButton(
            tooltip: 'Save',
            icon: const Icon(LucideIcons.save),
            onPressed: _isSaving ? null : _save,
          ),
        ],
      ),
      body: Form(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24.0),
                    TextFormField(
                      focusNode: _taskFocus,
                      decoration: const InputDecoration(
                        hintText: 'Title',
                        hintStyle: TextStyle(fontSize: 40, color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      controller: _task,
                      style: const TextStyle(fontSize: 40), //for cursor size
                      maxLines: null,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 30.0),
                    if(canEditBody)NoteFormatBar(controller: _description),
                    SizedBox(
                      height: 150,
                      child: TextFormField(
                        enabled: canEditBody,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: canEditBody
                              ? 'Enter description here...'
                              : 'This note has rich content. Edit it on the web.',
                          hintStyle: const TextStyle(
                            fontSize: 20,
                            color: Colors.grey,
                          ),
                        ),
                        controller: _description,
                        style: const TextStyle(fontSize: 20), //for cursor size
                        maxLines: null,
                        expands: true,
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    const SizedBox(height: 24.0),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      // body:Padding(
      // padding: const EdgeInsets.all(8.0),
      // child: TextField(
      //   controller: _task,
      //   maxLines: null,r
      //   expands: true,
      //   decoration: const InputDecoration(
      //     border: InputBorder.none,
      //     hintText: 'Enter description here...',
      //   ),
      //   style: const TextStyle(fontSize: 16),
      // ),
      // )
    );
  }
}
