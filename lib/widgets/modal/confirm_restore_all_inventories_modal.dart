import 'package:flutter/material.dart';

class ConfirmRestoreAllInventoriesDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const ConfirmRestoreAllInventoriesDialog({
    super.key,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Conferma Ripristino'),
      content: const Text(
        'Sei sicuro di voler ripristinare tutte le inventory archiviate?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
          },
          child: const Text('Ripristina'),
        ),
      ],
    );
  }
}
