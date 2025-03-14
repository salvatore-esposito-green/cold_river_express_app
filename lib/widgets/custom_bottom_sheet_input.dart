import 'dart:math';

import 'package:cold_river_express_app/controllers/suggestion_controller.dart';
import 'package:flutter/material.dart';

class CustomBottomSheetInput extends StatefulWidget {
  final TextEditingController textController;
  final String labelText;
  final SuggestionController? suggestionController;
  final int? minHeight;
  final bool? showConfirmButton;
  final Function(String)? onConfirm;

  const CustomBottomSheetInput({
    super.key,
    required this.textController,
    required this.labelText,
    this.suggestionController,
    this.minHeight,
    this.showConfirmButton,
    this.onConfirm,
  });

  @override
  CustomBottomSheetInputState createState() => CustomBottomSheetInputState();
}

class CustomBottomSheetInputState extends State<CustomBottomSheetInput> {
  late String query;
  late int minHeight;

  @override
  void initState() {
    super.initState();
    query = widget.textController.text;

    minHeight = getComputedHeight(
      widget.suggestionController != null,
      widget.showConfirmButton ?? true,
      widget.minHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.suggestionController?.filter(query) ?? [];

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: minHeight.toDouble(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: widget.textController,
                autofocus: true,
                decoration: InputDecoration(labelText: widget.labelText),
                onChanged: (value) {
                  setState(() {
                    query = value;
                  });
                },
                onSubmitted: (value) {
                  if (widget.onConfirm != null) {
                    widget.onConfirm!(value);
                  }

                  Navigator.pop(context, value);
                },
              ),
              const SizedBox(height: 16),
              if (widget.suggestionController != null)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children:
                          filtered
                              .map(
                                (suggestion) => ListTile(
                                  title: Text(suggestion),
                                  onTap:
                                      () => Navigator.pop(context, suggestion),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ),
              if (widget.showConfirmButton ?? true)
                ElevatedButton(
                  onPressed: () {
                    if (widget.onConfirm != null) {
                      widget.onConfirm!(widget.textController.text);
                    }

                    Navigator.pop(context, widget.textController.text);
                  },
                  child: const Text('Save'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

getComputedHeight(
  bool isSuggestionSheet,
  bool showConfirmButton,
  int? minHeight,
) {
  int baseHeight = minHeight ?? 150;

  if (isSuggestionSheet) {
    baseHeight += 100;
  }
  if (showConfirmButton) {
    baseHeight += 60;
  }

  return max(minHeight ?? 150, baseHeight);
}
