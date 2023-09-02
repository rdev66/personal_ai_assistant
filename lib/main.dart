import 'dart:io';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

void main() {
  runApp(const MyApp());
}

//const gptPrompt = 'TLDR: ';
const gptPromptBullet = 'Using extractive summarization, condense this business report into key bullet points: ';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Another boring meeting? Let\'s TLDR it!',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;

  late FlutterTts _flutterTts;

  final openAI = OpenAI.instance.build(
      enableLog: true,
      token: "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",
      baseOption: HttpSetup(
        sendTimeout: const Duration(seconds: 50),
        receiveTimeout: const Duration(seconds: 50),
        connectTimeout: const Duration(seconds: 50),
      ));

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _speechAvailable = false;
  bool isSummarizing = false;
  bool _textToSpeechEnabled = false;

  String _totalWords = '';
  String _currentWords = '';
  String _gptResponse = '';

  List<LocaleName> _availableLocales = [];
  String _selectedLocaleId = '';

  printLocales() async {
    var locales = await _speechToText.locales();
    for (var local in locales) {
      debugPrint(local.name);
      debugPrint(local.localeId);
    }
  }

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTTS();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechAvailable = await _speechToText.initialize(
        onError: errorListener, onStatus: statusListener);

    final locales = await _speechToText.locales();
    setState(() {
      _availableLocales = locales;
      _selectedLocaleId = locales.first.localeId;
    });
  }

  void statusListener(String status) async {
    debugPrint("status $status");

    setState(() {
      _totalWords += _currentWords;
      _currentWords = "";
    });

    if (status == "done") {
      await _speechToText.stop();
      //Autorestart..
      if (_speechEnabled) {
        await Future.delayed(const Duration(milliseconds: 50));
        await _startListening();
      }
    }
  }

  /// Each time to start a speech recognition session
  Future _startListening() async {
    await _speechToText.listen(
        onResult: _onSpeechResult,
        localeId: _selectedLocaleId,
        cancelOnError: false,
        partialResults: true,
        listenMode: ListenMode.dictation);
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  Future _stopListening() async {
    await _speechToText.stop();
    _speechEnabled = false;
  }

  void errorListener(SpeechRecognitionError error) {
    debugPrint(error.errorMsg.toString());
  }

  /**
   * TODO old, buggy, remove.
   */
  Future<void> _summarize() async {
    if (_totalWords.isEmpty) {
      debugPrint("No transcript to summarize");
      return;
    }
    //GPT Processing
    final request = CompleteText(
        prompt: '$gptPromptBullet $_totalWords',
        model: TextDavinci3Model(),
        maxTokens: 2000);

    await openAI.onCompletion(request: request).then((value) {
      setState(() {
        _gptResponse = value!.choices.first.text;
      });
    });
  }

  void chatComplete() async {
    if (_gptResponse.isNotEmpty) {
      debugPrint("Already summarized");
      return;
    }
    if (_totalWords.isEmpty) {
      debugPrint("No transcript to summarize");
      return;
    }

    setState(() {
      isSummarizing = true;
    });

    final request = ChatCompleteText(messages: [
      Messages(role: Role.user, content: '$gptPromptBullet $_totalWords'),
    ], maxToken: 200, model: Gpt4ChatModel());

    final response = await openAI.onChatCompletion(request: request);

    for (var element in response!.choices) {
      debugPrint("data -> ${element.message?.content}");
    }

    setState(() {
      _gptResponse = response.choices.first.message!.content;
      isSummarizing = false;
    });

    if (_textToSpeechEnabled) {
      _speak(_gptResponse);
    }
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _currentWords = result.recognizedWords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Another boring meeting?'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(children: [
              Container(
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.all(8),
                child: const Text(
                  'Language:',
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
              Container(
                alignment: Alignment.topRight,
                padding: const EdgeInsets.all(8),
                child: DropdownButton<String>(
                  value: _selectedLocaleId,
                  items: _availableLocales.map((LocaleName locale) {
                    return DropdownMenuItem<String>(
                      value: locale.localeId,
                      child: Text(locale.name),
                    );
                  }).toList(),
                  onChanged: (_) {},
                ),
              ),
            ]),
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.all(5),
              child: const Text(
                'Transcript:',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _totalWords.isNotEmpty
                      ? '$_totalWords $_currentWords'
                      : _speechAvailable
                          ? 'Tap the microphone to start listening...'
                          : 'Speech not available',
                ),
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Container(
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.all(5),
                child: const Text(
                  'GPT Summary:',
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
              Row(
                children: [
                  const Text("Speak?", style: TextStyle(fontSize: 20.0)),
                  Container(
                      alignment: Alignment.topRight,
                      padding: const EdgeInsets.all(2),
                      child: Switch(
                        // This bool value toggles the switch.
                        value: _textToSpeechEnabled,
                        activeColor: Colors.blue,
                        inactiveThumbColor: Colors.grey,
                        onChanged: (bool value) {
                          // This is called when the user toggles the switch.
                          setState(() {
                            _textToSpeechEnabled = value;
                          });
                        },
                      )),
                ],
              ),
            ]),
            Expanded(
              flex: 2,
              child: Container(
                  padding: const EdgeInsets.all(16), child: Text(_gptResponse)),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          showSummarizeButton(),
          showClearButton(),
          showStopRecordButton(),
          showStartRecordButton(),
        ],
      ),
    );
  }

  FloatingActionButton showStartRecordButton() {
    return FloatingActionButton(
      backgroundColor: !_speechEnabled ? Colors.green : Colors.grey,
      onPressed: _speechToText.isNotListening
          ? () {
              _speechEnabled = true;
              _startListening();
            }
          : null,
      tooltip: 'Start',
      child: const Icon(Icons.mic),
    );
  }

  FloatingActionButton showStopRecordButton() {
    return FloatingActionButton(
      backgroundColor: _speechEnabled ? Colors.red : Colors.grey,
      onPressed: () => _stopListening(),
      tooltip: 'Stop',
      child: const Icon(Icons.mic_off),
    );
  }

  FloatingActionButton showClearButton() {
    return FloatingActionButton(
      onPressed: () {
        if (_totalWords.isEmpty || _speechEnabled) return;

        setState(() {
          _totalWords = '';
          _gptResponse = '';
        });
      },
      backgroundColor:
          _totalWords.isNotEmpty && !_speechEnabled ? Colors.blue : Colors.grey,
      tooltip: 'Clear',
      child: const Icon(Icons.clear),
    );
  }

  Widget showSummarizeButton() {
    return isSummarizing
        ? const CircularProgressIndicator()
        : FloatingActionButton(
            onPressed: () async {
              chatComplete();

              if (_textToSpeechEnabled) {
                _speak(_gptResponse);
              }
            },
            backgroundColor:
                (_totalWords.isNotEmpty && _speechToText.isNotListening)
                    ? Colors.blue
                    : Colors.grey,
            tooltip: "Summarize",
            child: Icon(_totalWords.isNotEmpty
                ? Icons.summarize
                : Icons.comments_disabled),
          );
  }

  void _initTTS() {
    _flutterTts = FlutterTts();
    _setAwaitOptions();

    if (isAndroid) {
      _getDefaultEngine();
      _getDefaultVoice();
    }
  }

  Future _setAwaitOptions() async {
    await _flutterTts.awaitSpeakCompletion(true);
  }

  Future _getDefaultEngine() async {
    var engine = await _flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future _getDefaultVoice() async {
    var voice = await _flutterTts.getDefaultVoice;
    if (voice != null) {
      print(voice);
    }
  }

  Future _speak(String _newVoiceText) async {
    double volume = 0.5;
    double pitch = 1.0;
    double rate = 0.4;

    await _flutterTts.setVolume(volume);
    await _flutterTts.setSpeechRate(rate);
    await _flutterTts.setPitch(pitch);

    if (_newVoiceText.isNotEmpty) {
      await _flutterTts.speak(_newVoiceText);
    }
  }
}
