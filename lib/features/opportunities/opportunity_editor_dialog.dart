import 'package:flutter/material.dart';

import '../../domain/opportunity.dart';

class OpportunityEditorDialog extends StatefulWidget {
  const OpportunityEditorDialog({super.key, this.initial});

  final Opportunity? initial;

  @override
  State<OpportunityEditorDialog> createState() =>
      _OpportunityEditorDialogState();
}

class _OpportunityEditorDialogState extends State<OpportunityEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _platformController;
  late final TextEditingController _budgetController;
  late final TextEditingController _urlController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final item = widget.initial;
    _titleController = TextEditingController(text: item?.title ?? '');
    _platformController = TextEditingController(text: item?.platform ?? 'Upwork');
    _budgetController = TextEditingController(text: item?.budget ?? '');
    _urlController = TextEditingController(text: item?.url ?? '');
    _notesController = TextEditingController(text: item?.notes ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _platformController.dispose();
    _budgetController.dispose();
    _urlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final old = widget.initial;
    Navigator.of(context).pop(
      Opportunity(
        id: old?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        platform: _platformController.text.trim(),
        createdAt: old?.createdAt ?? DateTime.now(),
        budget: _budgetController.text.trim(),
        url: _urlController.text.trim(),
        notes: _notesController.text.trim(),
        status: old?.status ?? OpportunityStatus.saved,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Add opportunity' : 'Edit opportunity'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Title'),
                  textInputAction: TextInputAction.next,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Enter a title.'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _platformController,
                  decoration: const InputDecoration(labelText: 'Platform'),
                  textInputAction: TextInputAction.next,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Enter a platform.'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _budgetController,
                  decoration: const InputDecoration(
                    labelText: 'Budget',
                    hintText: 'For example, USD 250 fixed',
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _urlController,
                  decoration: const InputDecoration(labelText: 'Listing URL'),
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return null;
                    final uri = Uri.tryParse(text);
                    if (uri == null ||
                        !{'http', 'https'}.contains(uri.scheme) ||
                        uri.host.isEmpty) {
                      return 'Use a complete HTTP or HTTPS URL.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (stored locally)',
                    alignLabelWithHint: true,
                  ),
                  minLines: 3,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(minimumSize: const Size(100, 48)),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

