import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:speech_continuous_none/provider/gpt_response_provider.dart';

class MyFlutterTts {
  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;

  late FlutterTts _flutterTts;

  MyFlutterTts() {
    _flutterTts = FlutterTts();

    _setAwaitOptions();

    if (isAndroid) {
      _getDefaultEngine();
      _getDefaultVoice();
    }
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

  Future<void> speak(context) async {

    final gptSummary =
        Provider.of<GptResponseProvider>(context, listen: false).gptSummary;

    double volume = 0.5;
    double pitch = 1.0;
    double rate = 0.4;

    await _flutterTts.setVolume(volume);
    await _flutterTts.setSpeechRate(rate);
    await _flutterTts.setPitch(pitch);

    if (gptSummary.isNotEmpty) {
      await _flutterTts.speak(gptSummary);
    }
  }
}
