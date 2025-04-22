import 'package:flutter/material.dart';

class ConfirmRestoreInventoryModal extends StatelessWidget {
  final String itemId;
  final VoidCallback onRestore;

  const ConfirmRestoreInventoryModal({
    super.key,
    required this.itemId,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Ripristina'),
      content: Text('Sei sicuro di voler ripristinare questa inventory?'),
      actions: [
        TextButton(
          child: Text('Annulla'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('Ripristina'),
          onPressed: () {
            onRestore();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
