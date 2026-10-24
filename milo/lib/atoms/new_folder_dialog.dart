import 'package:flutter/material.dart';

/// Asks for a folder name. Returns the trimmed name, or null when the dialog
/// is cancelled or the name is empty.
Future<String?> showNewFolderDialog(BuildContext context) async {
  final name = await showDialog<String>(
    context: context,
    builder: (_) => const _NewFolderDialog(),
  );
  final trimmed = name?.trim() ?? '';
  return trimmed.isEmpty ? null : trimmed;
}

class _NewFolderDialog extends StatefulWidget {
  const _NewFolderDialog();

  @override
  State<_NewFolderDialog> createState() => _NewFolderDialogState();
}

class _NewFolderDialogState extends State<_NewFolderDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = TextButton.styleFrom(
      textStyle: Theme.of(context).textTheme.labelLarge,
    );

    return AlertDialog(
      title: const Text('New folder'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Enter folder name',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          style: buttonStyle,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: buttonStyle,
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Create'),
        ),
      ],
    );
  }
}
