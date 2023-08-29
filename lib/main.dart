import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
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
  final openAI = OpenAI.instance.build(
      token: "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",
      baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 5)),
      enableLog: true);

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _speechAvailable = false;
  String _totalWords = '';
  String _currentWords = '';
  String _gptResponse = '';

  List<LocaleName> _availableLocales = [];
  final String _selectedLocaleId = 'es_ES';

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
    //_initLocales();
    _initChatGPT();
  }

  void errorListener(SpeechRecognitionError error) {
    debugPrint(error.errorMsg.toString());
  }

  void statusListener(String status) async {
    debugPrint("status $status");
    if (status == "done" && _speechEnabled) {
      setState(() {
        _totalWords += " $_currentWords";
        _currentWords = "";
        _speechEnabled = false;
      });
      await _startListening();
    }
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechAvailable = await _speechToText.initialize(
        onError: errorListener, onStatus: statusListener);

    final locales = await _speechToText.locales();
    setState(() {
      _availableLocales = locales;
    });
  }

  /// Each time to start a speech recognition session
  Future _startListening() async {
    debugPrint("=================================================");
    await _stopListening();
    await Future.delayed(const Duration(milliseconds: 50));
    await _speechToText.listen(
        onResult: _onSpeechResult,
        localeId: _selectedLocaleId,
        cancelOnError: false,
        partialResults: true,
        listenMode: ListenMode.dictation);
    setState(() {
      _speechEnabled = true;
    });
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  Future _stopListening() async {
    await _speechToText.stop();

    setState(() {
      _speechEnabled = false;
    });

    if (_totalWords.isEmpty) {
      return;
    }

    //GPT Processing
    final request = CompleteText(
        prompt: 'TLDR: $_totalWords',
        model: TextDavinci3Model(),
        maxTokens: 200);

    await openAI.onCompletion(request: request).then((value) {
      setState(() {
        _gptResponse = value!.choices.first.text;
      });
    });
  }

  void _initChatGPT() async {
    debugPrint("=================================================");
    await _stopListening();
    await Future.delayed(const Duration(milliseconds: 50));
    await _speechToText.listen(
        onResult: _onSpeechResult,
        localeId: _selectedLocaleId,
        cancelOnError: false,
        partialResults: true,
        listenMode: ListenMode.dictation);
    setState(() {
      _speechEnabled = true;
    });
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
            Expanded(
              flex: 2,
              child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Text("RSP: $_gptResponse")),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          showSummarizeButton(),
          showRecordButton(),
        ],
      ),
    );
  }

  FloatingActionButton showRecordButton() {
    return FloatingActionButton(
      onPressed:
          _speechToText.isNotListening ? _startListening : _stopListening,
      tooltip: 'Listen',
      child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
    );
  }

  FloatingActionButton showSummarizeButton() {
    return FloatingActionButton(
      onPressed: () {},
      tooltip: "Summarize",
      child: Icon(
          _currentWords.isNotEmpty ? Icons.summarize : Icons.comments_disabled),
    );
  }
}
