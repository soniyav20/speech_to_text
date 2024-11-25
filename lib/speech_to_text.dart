import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechToTextPage extends StatefulWidget {
  const SpeechToTextPage({Key? key}) : super(key: key);

  @override
  _SpeechToTextPage createState() => _SpeechToTextPage();
}

class _SpeechToTextPage extends State<SpeechToTextPage> {
  final TextEditingController _textController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();

  bool _speechEnabled = false;
  String _lastWords = "";
  String _selectedLocale = "en_US";

  final List<Map<String, String>> _locales = [
    {"id": "en_US", "name": "English (US)"},
    {"id": "en_GB", "name": "English (UK)"},
    {"id": "ta_IN", "name": "Tamil (India)"},
    {"id": "hi_IN", "name": "Hindi (India)"},
  ];

  void listenForPermissions() async {
    final status = await Permission.microphone.status;
    if (status.isDenied) {
      requestForPermission();
    }
  }

  Future<void> requestForPermission() async {
    await Permission.microphone.request();
  }

  @override
  void initState() {
    super.initState();
    listenForPermissions();
    if (!_speechEnabled) {
      _initSpeech();
    }
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(seconds: 100),
      localeId: _selectedLocale,
      cancelOnError: false,
      partialResults: false,
      listenMode: ListenMode.confirmation,
    );
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = "$_lastWords${result.recognizedWords} ";
      _textController.text = _lastWords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Speech to Text"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedLocale,
              items: _locales.map((locale) {
                return DropdownMenuItem<String>(
                  value: locale['id'],
                  child: Text(locale['name']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLocale = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TextField(
                controller: _textController,
                minLines: 6,
                maxLines: 10,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _speechToText.isNotListening ? "Not Listening" : "Listening",
                  style: TextStyle(
                    color: _speechToText.isNotListening
                        ? Colors.red
                        : Colors.green,
                    fontSize: 16,
                  ),
                ),
                FloatingActionButton(
                  onPressed: _speechToText.isNotListening
                      ? _startListening
                      : _stopListening,
                  tooltip: 'Listen',
                  child: Icon(
                    _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
