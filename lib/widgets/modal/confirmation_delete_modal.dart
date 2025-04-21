import 'package:flutter/material.dart';

class ConfirmationDeleteModal extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const ConfirmationDeleteModal({
    super.key,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Confirm Delete"),
      content: const Text(
        "Are you sure you want to delete this item? This action cannot be undone directly from the main list.",
      ),
      actions: [
        TextButton(onPressed: onCancel, child: const Text("Cancel")),
        TextButton(onPressed: onConfirm, child: const Text("Delete")),
      ],
    );
  }
}
