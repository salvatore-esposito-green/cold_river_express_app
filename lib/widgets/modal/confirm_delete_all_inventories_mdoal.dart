import 'package:flutter/material.dart';

class ConfirmDeleteAllInventoriesDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const ConfirmDeleteAllInventoriesDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Conferma'),
      content: const Text(
        'Sei sicuro di voler cancellare definitivamente tutte le inventory archiviate?',
      ),
      actions: [
        TextButton(
          child: const Text('Annulla'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('Cancella'),
          onPressed: () {
            onConfirm();
          },
        ),
      ],
    );
  }
}
