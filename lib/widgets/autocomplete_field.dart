import 'package:flutter/material.dart';

class AutocompleteFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final List<String> suggestions;

  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final InputDecoration? decoration;

  const AutocompleteFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.suggestions,
    this.validator,
    this.focusNode,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return suggestions.where((String option) {
          return option.toLowerCase().contains(
            textEditingValue.text.toLowerCase(),
          );
        });
      },
      onSelected: (String selection) {
        controller.text = selection;
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController fieldController,
        FocusNode fieldFocusNode,
        VoidCallback onFieldSubmitted,
      ) {
        if (fieldController.text.isEmpty) {
          fieldController.text = controller.text;
        }

        fieldController.addListener(() {
          controller.text = fieldController.text;
        });

        return TextFormField(
          controller: fieldController,
          focusNode: fieldFocusNode,
          decoration: (decoration ?? InputDecoration()).copyWith(
            labelText: labelText,
          ),
          validator: validator,
        );
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<String> onSelected,
        Iterable<String> options,
      ) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 200,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  return ListTile(
                    title: Text(option),
                    onTap: () {
                      onSelected(option);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
