import 'package:flutter/material.dart';

Future<String?> showTextEditDialog(
  BuildContext context, {
  required String title,
  required String initialValue,
  String? Function(String value)? validator,
  TextInputType keyboardType = TextInputType.text,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _TextEditDialog(
      title: title,
      initialValue: initialValue,
      validator: validator,
      keyboardType: keyboardType,
    ),
  );
}

class _TextEditDialog extends StatefulWidget {
  const _TextEditDialog({
    required this.title,
    required this.initialValue,
    required this.validator,
    required this.keyboardType,
  });

  final String title;
  final String initialValue;
  final String? Function(String value)? validator;
  final TextInputType keyboardType;

  @override
  State<_TextEditDialog> createState() => _TextEditDialogState();
}

class _TextEditDialogState extends State<_TextEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _controller = TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, _controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          keyboardType: widget.keyboardType,
          onFieldSubmitted: (_) => _save(),
          validator: (v) {
            final value = v?.trim() ?? '';
            if (value.isEmpty) return 'This field is required';
            return widget.validator?.call(value);
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}

Future<T?> showChoiceDialog<T>(
  BuildContext context, {
  required String title,
  required Map<T, String> options,
  required T current,
}) {
  return showDialog<T>(
    context: context,
    builder: (dialogContext) => SimpleDialog(
      title: Text(title),
      children: [
        for (final entry in options.entries)
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, entry.key),
            child: Row(
              children: [
                Expanded(child: Text(entry.value)),
                if (entry.key == current) const Icon(Icons.check_rounded),
              ],
            ),
          ),
      ],
    ),
  );
}

Future<({String current, String next})?> showChangePasswordDialog(
  BuildContext context,
) {
  return showDialog<({String current, String next})>(
    context: context,
    builder: (_) => const _ChangePasswordDialog(),
  );
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _repeat = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _repeat.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, (current: _current.text, next: _next.text));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change password'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _current,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current password'),
              validator: (v) =>
                  (v ?? '').isEmpty ? 'Enter your current password' : null,
            ),
            TextFormField(
              controller: _next,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New password'),
              validator: (v) =>
                  (v ?? '').length < 6 ? 'Minimum 6 characters' : null,
            ),
            TextFormField(
              controller: _repeat,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Repeat new password',
              ),
              validator: (v) =>
                  v != _next.text ? 'Passwords do not match' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Change')),
      ],
    );
  }
}
