import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:groq/groq.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechToTextPage extends StatefulWidget {
  const SpeechToTextPage({Key? key}) : super(key: key);

  @override
  _SpeechToTextPage createState() => _SpeechToTextPage();
}

class _SpeechToTextPage extends State<SpeechToTextPage> {
  List<String> transcripts=[];
  // final TextEditingController _textController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();

  bool _speechEnabled = false;
  String _lastWords = "";
  String _selectedLocale = "en_US";

  final List<Map<String, String>> _locales = [
    {"id": "en_US", "name": "English (US)"},
    {"id": "en_IN", "name": "English (India)"},
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
    print('Listening: ${_speechToText.isListening}');
    print('Recognized Words: ${result.recognizedWords}');
    if (!_speechToText.isListening && _speechEnabled) {
      print("AGATIN");
      _startListening();
    }

    setState(() async {
      _lastWords = " ${result.recognizedWords} ";
      print("THIS IS FROM THE SPEECH" + _lastWords);
        final gemini = Gemini.instance;
        String pr="You are an AI language model tasked with reviewing a speech-to-text transcription for accuracy. Your job is to identify and correct only clear transcription errors, such as misspelled words, incorrect terms, or missing punctuation, while ensuring the text remains faithful to the original context and meaning. Do not alter the original wording, tone, or structure beyond correcting errors to maintain the integrity of the speaker's intent.";
        await gemini.text("$pr+:\"${_lastWords}\"")
            .then((value) => transcripts.add(value?.output??"")) /// or value?.content?.parts?.last.text
            .catchError((e) => print(e));
        setState(() {
        });
        print(transcripts[transcripts.length-1]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              decoration: InputDecoration(
                labelText: "Select Language",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Text Input and Listening Status
            Expanded(
              child: transcripts.length>0? ListView.builder(
                  itemCount: transcripts.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          selectedTileColor: Colors.deepPurple[50],
                          selected: true,
                          title: Text(transcripts[index])),
                    );
                  }): Text("Click on the Mic Button to start listening")
            ),
            const SizedBox(height: 20),
            // Listening Status and Microphone Button
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
                  // onPressed: (){ _lalaalaaa();},
                  onPressed: _speechToText.isNotListening
                      ? _startListening
                      : _stopListening,
                  tooltip: 'Listen',
                  backgroundColor: Colors.blueAccent,
                  child: Icon(
                    _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
                    color: Colors.white,
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
