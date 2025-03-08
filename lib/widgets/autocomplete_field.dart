import 'package:flutter/material.dart';

class AutocompleteFormField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final List<String> suggestions;
  final String? Function(String?)? validator;
  final InputDecoration? decoration;

  const AutocompleteFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.suggestions,
    this.validator,
    this.decoration,
  });

  @override
  AutocompleteFormFieldState createState() => AutocompleteFormFieldState();
}

class AutocompleteFormFieldState extends State<AutocompleteFormField> {
  bool _isSheetOpen = false;

  Future<void> _openSuggestionsSheet() async {
    if (_isSheetOpen) return;
    _isSheetOpen = true;

    FocusScope.of(context).unfocus();

    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        String query = widget.controller.text;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SizedBox(
            height: 200,
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: widget.controller,
                        autofocus: true,
                        decoration: (widget.decoration ??
                                const InputDecoration())
                            .copyWith(labelText: widget.labelText),
                        onChanged: (value) {
                          setModalState(() {
                            query = value;
                          });
                        },
                        onSubmitted: (value) {
                          Navigator.pop(context, value);
                        },
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children:
                                widget.suggestions
                                    .where(
                                      (s) => s.toLowerCase().contains(
                                        query.toLowerCase(),
                                      ),
                                    )
                                    .map(
                                      (suggestion) => ListTile(
                                        title: Text(suggestion),
                                        onTap:
                                            () => Navigator.pop(
                                              context,
                                              suggestion,
                                            ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    if (selected != null) {
      widget.controller.text = selected;
    }
    _isSheetOpen = false;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      readOnly: true,
      decoration: (widget.decoration ?? const InputDecoration()).copyWith(
        labelText: widget.labelText,
      ),
      validator: widget.validator,
      onTap: _openSuggestionsSheet,
    );
  }
}
