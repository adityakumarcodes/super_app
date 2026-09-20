import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _task = TextEditingController();
  final FocusNode _taskFocus = FocusNode();
  final TextEditingController _description = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
        elevation: 2,
        centerTitle: true,
        shape: Border(bottom: BorderSide(color: Colors.black, width: 2)),
        actions: [
          IconButton(
            tooltip: 'Save',
            icon: const Icon(LucideIcons.save),
            onPressed: () {},
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
                    SizedBox(
                      height: 150,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter description here...',
                          hintStyle: TextStyle(
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
