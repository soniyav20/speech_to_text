import 'package:flutter/material.dart';
import 'package:untitled/speech_to_text.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Gemini.init(apiKey:"API_KEY");
    return MaterialApp(
      title: 'Speech to Text',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SpeechToTextPage(),
    );
  }
}
