import 'package:cold_river_express_app/controllers/suggestion_controller.dart';
import 'package:cold_river_express_app/services/suggestions_sheet_service.dart';
import 'package:flutter/material.dart';

class AutocompleteFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final SuggestionController suggestionController;
  final String? Function(String?)? validator;
  final InputDecoration? decoration;

  const AutocompleteFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.suggestionController,
    this.validator,
    this.decoration,
  });

  Future<void> _openSheet(BuildContext context) async {
    final selected = await openSuggestionsBottomSheet(
      context: context,
      labelText: labelText,
      controller: controller,
      suggestionController: suggestionController,
    );
    if (selected != null) {
      controller.text = selected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: (decoration ?? const InputDecoration()).copyWith(
        labelText: labelText,
      ),
      validator: validator,
      onTap: () => _openSheet(context),
    );
  }
}
