import 'package:flutter/material.dart';

class NewPositionField extends StatefulWidget {
  final ValueChanged<String> onPositionChanged;

  const NewPositionField({super.key, required this.onPositionChanged});

  @override
  NewPositionFieldState createState() => NewPositionFieldState();
}

class NewPositionFieldState extends State<NewPositionField> {
  final TextEditingController _positionController = TextEditingController();

  @override
  void dispose() {
    _positionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _positionController,
        textInputAction: TextInputAction.done,
        onSubmitted: (value) {
          widget.onPositionChanged(value);
          _positionController.clear();
          FocusScope.of(context).unfocus();
        },
        decoration: InputDecoration(
          labelText: 'New Position',
          hintText: 'Enter new position...',
          prefixIcon: Icon(Icons.location_on),
          suffixIcon: IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              widget.onPositionChanged(_positionController.text);
              _positionController.clear();
              FocusScope.of(context).unfocus();
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}
