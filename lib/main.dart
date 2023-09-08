import 'dart:io';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_continuous_none/widget/gpt_bar.dart';
import 'package:speech_continuous_none/widget/toggle_source_bar.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'firebase_options.dart';
import 'widget/floating_action_buttons_bar.dart';
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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal AI asistant',
      home: SpeechToSummary(),
    );
  }
}

class SpeechToSummary extends StatefulWidget {
  const SpeechToSummary({Key? key}) : super(key: key);

  @override
  SpeechToSummaryState createState() => SpeechToSummaryState();
}

class SpeechToSummaryState extends State<SpeechToSummary> {
  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;

  late FlutterTts _flutterTts;

  final openAI = OpenAI.instance.build(
      enableLog: true,
      token: "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",
//      token: "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",
      baseOption: HttpSetup(
        sendTimeout: const Duration(seconds: 50),
        receiveTimeout: const Duration(seconds: 50),
        connectTimeout: const Duration(seconds: 50),
      ));

  final SpeechToText speechToText = SpeechToText();

  bool speechEnabled = false;
  bool isSummarizing = false;
  bool speechAvailable = false;
  bool textToSpeechEnabled = false;
  List<bool> selected = [true, false];

  String totalWords = '';
  String currentWords = '';
  String gptResponse = '';

  List<LocaleName> availableLocales = [];
  String selectedLocaleId = '';

  @override
  void initState() {
    super.initState();
    initialization();
    _initSpeech();
    _initTTS();
  }

  void initialization() async {
    // This is where you can initialize the resources needed by your app while
    // the splash screen is displayed.  Remove the following example because
    // delaying the user experience is a bad design practice!
    // ignore_for_file: avoid_print
    print('ready in 3...');
    await Future.delayed(const Duration(seconds: 1));
    print('ready in 2...');
    await Future.delayed(const Duration(seconds: 1));
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
    //var p = await searchYoutubeVideos("query");
    //print(p);

    speechAvailable = await speechToText.initialize(
        onError: errorListener, onStatus: statusListener);

    final locales = await speechToText.locales();
    setState(() {
      availableLocales = locales;
      selectedLocaleId = locales.first.localeId;
    });
  }

  void _initTTS() {
    _flutterTts = FlutterTts();
    _setAwaitOptions();

    if (isAndroid) {
      _getDefaultEngine();
      _getDefaultVoice();
    }
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

  void chatComplete() async {
    if (gptResponse.isNotEmpty) {
      debugPrint("Already summarized");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Already summarized'),
        ),
      );
      return;
    }
    if (totalWords.isEmpty) {
      debugPrint("No transcript to summarize");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No transcript to summarize'),
        ),
      );
      return;
    }

    setState(() {
      isSummarizing = true;
    });

    //const gptPrompt = 'TLDR: ';
    const gptPromptBullet =
        'Using extractive summarization, condense this business report into key bullet points: ';

    final request = ChatCompleteText(messages: [
      Messages(role: Role.user, content: '$gptPromptBullet $totalWords'),
    ], maxToken: 200, model: Gpt4ChatModel());

    final response =
        await openAI.onChatCompletion(request: request).catchError((err) {
      setState(() {
        isSummarizing = false;
      });

      if (err is OpenAIAuthError) {
        if (kDebugMode) {
          print('OpenAIAuthError error ${err.data?.error.toMap()}');
        }
      }
      if (err is OpenAIRateLimitError) {
        if (kDebugMode) {
          print('OpenAIRateLimitError error ${err.data?.error.toMap()}');
        }
      }
      if (err is OpenAIServerError) {
        if (kDebugMode) {
          print('OpenAIServerError error $err');
          print('OpenAIServerError error ${err.data?.error.toMap()}');
        }
      }
      return null;
    });

    for (var element in response!.choices) {
      debugPrint("data -> ${element.message?.content}");
    }

    setState(() {
      gptResponse = response.choices.first.message!.content;
      isSummarizing = false;
    });

    if (textToSpeechEnabled) {
      speak(gptResponse);
    }
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
            GPTBar(gptResponse, textToSpeechEnabled, toggleTextToSpeech),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButtonsBar(
          speechEnabled,
          isSummarizing,
          totalWords,
          gptResponse,
          speechToText,
          startListening,
          stopListening,
          clearGPTResponse,
          chatComplete,
          speak),
    );
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

  Future<void> _setAwaitOptions() async {
    await _flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> _getDefaultEngine() async {
    var engine = await _flutterTts.getDefaultEngine;
    if (engine != null) {
      debugPrint(engine);
    }
  }

  Future<void> _getDefaultVoice() async {
    var voice = await _flutterTts.getDefaultVoice;
    if (voice != null) {
      debugPrint(voice.toString());
    }
  }

  Future<void> speak(String newVoiceText) async {
    double volume = 0.5;
    double pitch = 1.0;
    double rate = 0.4;

    await _flutterTts.setVolume(volume);
    await _flutterTts.setSpeechRate(rate);
    await _flutterTts.setPitch(pitch);

    if (newVoiceText.isNotEmpty) {
      await _flutterTts.speak(newVoiceText);
    }
  }
}
