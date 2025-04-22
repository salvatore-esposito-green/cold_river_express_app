import 'package:flutter/material.dart';

class ConfirmDeleteInventoryModal extends StatelessWidget {
  final VoidCallback onDelete;

  const ConfirmDeleteInventoryModal({super.key, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Cancellazione'),
      content: Text(
        'Sei sicuro di voler cancellare definitivamente questa inventory?',
      ),
      actions: [
        TextButton(
          child: Text('Annulla'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('Cancella'),
          onPressed: () {
            onDelete();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
