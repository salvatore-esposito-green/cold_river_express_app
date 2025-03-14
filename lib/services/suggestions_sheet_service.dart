import 'package:cold_river_express_app/controllers/suggestion_controller.dart';
import 'package:cold_river_express_app/widgets/suggestions_bottom_sheet.dart';
import 'package:flutter/material.dart';

Future<String?> openSuggestionsBottomSheet({
  required BuildContext context,
  required String labelText,
  required TextEditingController controller,
  required SuggestionController suggestionController,
}) async {
  // Chiude la tastiera se aperta
  FocusScope.of(context).unfocus();

  return await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder:
        (context) => SuggestionsBottomSheet(
          labelText: labelText,
          textController: controller,
          suggestionController: suggestionController,
        ),
  );
}
