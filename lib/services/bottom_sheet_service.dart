import 'package:cold_river_express_app/controllers/suggestion_controller.dart';
import 'package:cold_river_express_app/widgets/custom_bottom_sheet_input.dart';
import 'package:flutter/material.dart';

Future<String?> openCustomBottomSheet({
  required BuildContext context,
  required String labelText,
  required TextEditingController controller,
  required SuggestionController? suggestionController,
  required Function(String)? onConfirm,
  required bool? showConfirmButton,
}) async {
  FocusScope.of(context).unfocus();

  return await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder:
        (context) => CustomBottomSheetInput(
          textController: controller,
          labelText: labelText,
          suggestionController: suggestionController,
          showConfirmButton: showConfirmButton,
          onConfirm: onConfirm,
        ),
  );
}
