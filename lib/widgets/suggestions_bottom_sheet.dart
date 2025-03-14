import 'package:cold_river_express_app/controllers/suggestion_controller.dart';
import 'package:flutter/material.dart';

class SuggestionsBottomSheet extends StatefulWidget {
  final String labelText;
  final TextEditingController textController;
  final SuggestionController suggestionController;

  const SuggestionsBottomSheet({
    super.key,
    required this.labelText,
    required this.textController,
    required this.suggestionController,
  });

  @override
  SuggestionsBottomSheetState createState() => SuggestionsBottomSheetState();
}

class SuggestionsBottomSheetState extends State<SuggestionsBottomSheet> {
  late String query;

  @override
  void initState() {
    super.initState();
    query = widget.textController.text;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.suggestionController.filter(query);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: 250,
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
                onSubmitted: (value) => Navigator.pop(context, value),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        filtered
                            .map(
                              (suggestion) => ListTile(
                                title: Text(suggestion),
                                onTap: () => Navigator.pop(context, suggestion),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
