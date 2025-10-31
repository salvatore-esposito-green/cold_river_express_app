import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechToTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final String localeId;

  const SpeechToTextField({
    super.key,
    required this.controller,
    this.labelText = 'Contents',
    this.hintText = 'Enter items separated by commas...',
    this.localeId = 'it_IT',
  });

  @override
  SpeechToTextFieldState createState() => SpeechToTextFieldState();
}

class SpeechToTextFieldState extends State<SpeechToTextField> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    if (!_isInitialized) {
      bool available = await _speech.initialize();
      setState(() => _isInitialized = available);
    }
  }

  Future<void> _startListening() async {
    FocusScope.of(context).unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    final options = stt.SpeechListenOptions(
      listenMode: stt.ListenMode.dictation,
      cancelOnError: true,
      partialResults: true,
      autoPunctuation: true,
      enableHapticFeedback: true,
    );

    if (_isInitialized) {
      setState(() => _isListening = true);

      _speech.listen(
        onResult: (val) {
          setState(() {
            widget.controller.text = val.recognizedWords.trim();
          });
        },
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 5),
        localeId: widget.localeId,
        listenOptions: options,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Speech recognition not available')),
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  void dispose() {
    if (_isListening) {
      _speech.stop();
    }
    _speech.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (value) {
        FocusScope.of(context).nextFocus();
      },
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        suffixIcon: IconButton(
          icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
          onPressed: () {
            if (_isListening) {
              _stopListening();
            } else {
              _startListening();
            }
          },
        ),
      ),
      validator:
          (value) =>
              value == null || value.isEmpty ? 'Please enter contents' : null,
    );
  }
}
