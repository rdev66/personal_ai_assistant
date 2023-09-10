import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:speech_continuous_none/provider/google_speech_provider.dart';
import 'package:speech_continuous_none/provider/gpt_response_provider.dart';
import 'package:speech_continuous_none/widget/gpt_summary_bar.dart';
import 'package:speech_continuous_none/widget/toggle_source_bar.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'firebase_options.dart';
import 'widget/buttonbars/mic_floating_action_buttons_bar.dart';
import 'widget/buttonbars/youtube_floating_action_buttons_bar.dart';
import 'widget/language_bar.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const SpeechToSummaryApp());
}

class SpeechToSummaryApp extends StatelessWidget {
  const SpeechToSummaryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: GptResponseProvider(),
          ),
          ChangeNotifierProvider.value(
            value: GoogleSpeechProvider(),
          ),
        ],
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Personal AI asistant',
          home: SpeechToSummary(),
        ));
  }
}

class SpeechToSummary extends StatefulWidget {
  const SpeechToSummary({Key? key}) : super(key: key);

  @override
  SpeechToSummaryState createState() => SpeechToSummaryState();
}

class SpeechToSummaryState extends State<SpeechToSummary> {
  final SpeechToText speechToText = SpeechToText();

  bool speechEnabled = false;
  bool isSummarizing = false;
  bool speechAvailable = false;
  bool textToSpeechEnabled = false;
  List<bool> selected = [true, false];

  String totalWords = '';
  String transcribedText = '';
  //
  String currentWords = '';
  String gptResponse = '';

  List<LocaleName> availableLocales = [];
  String selectedLocaleId = '';

  @override
  void initState() {
    super.initState();
    initialization();
    _initSpeech();
  }

  void initialization() async {
    // This is where you can initialize the resources needed by your app while
    // the splash screen is displayed.  Remove the following example because
    // delaying the user experience is a bad design practice!
    // ignore_for_file: avoid_print
    print('ready in 1...');
    await Future.delayed(const Duration(seconds: 1));
    print('go!');
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    FlutterNativeSplash.remove();
  }

  /// This has to happen only once per app init.
  void _initSpeech() async {
    speechAvailable = await speechToText.initialize(
        onError: errorListener, onStatus: statusListener);

    final locales = await speechToText.locales();
    setState(() {
      availableLocales = locales;
      selectedLocaleId = locales.first.localeId;
    });
  }

  /// Each time to start a speech recognition session
  Future<void> startListening() async {
    if (speechToText.isListening) return;

    await speechToText.listen(
        onResult: _onSpeechResult,
        localeId: selectedLocaleId,
        cancelOnError: false,
        partialResults: true,
        listenMode: ListenMode.dictation);

    setState(() {
      speechEnabled = true;
    });
  }

  void statusListener(String status) async {
    debugPrint("status $status");

    setState(() {
      totalWords += currentWords;
      currentWords = "";
    });

    if (status == "done") {
      await speechToText.stop();

      //Autorestart..
      if (speechEnabled) {
        await Future.delayed(const Duration(milliseconds: 25));
        await startListening();
      }
    }
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {
      speechEnabled = false;
    });
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      currentWords = result.recognizedWords;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    debugPrint(error.errorMsg.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Personal AI meeting assistant'),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              LanguageBar(selectedLocaleId, availableLocales),
              ToggleSourceBar(
                  totalWords, speechAvailable, toggleSelected, selected),
              GPTSummaryBar(textToSpeechEnabled, toggleTextToSpeech),
            ],
          ),
        ),
        floatingActionButton: selected[0]
            ? MicFloatingActionButtonsBar(isSummarizing, speechEnabled,
                totalWords, speechToText, startListening, stopListening)
            : YoutubeFloatingActionButtonsBar(
                isSummarizing, speechEnabled, speechToText.isListening));
  }

  void toggleSelected(int selectedIdx) {
    {
      setState(() {
        for (int buttonIndex = 0;
            buttonIndex < selected.length;
            buttonIndex++) {
          if (buttonIndex == selectedIdx) {
            selected[buttonIndex] = true;
          } else {
            selected[buttonIndex] = false;
          }
        }
      });
    }
  }

  void toggleTextToSpeech(bool toggle) {
    setState(() {
      textToSpeechEnabled = toggle;
    });
  }

  void clearGPTResponse() {
    if (totalWords.isEmpty || speechEnabled) return;

    setState(() {
      totalWords = '';
      gptResponse = '';
    });
  }
}
