import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_continuous_none/provider/gpt_response_provider.dart';

import '../tts/my_flutter_tts.dart';

class GPTSummaryBar extends StatefulWidget {
  final bool textToSpeechEnabled;
  final Function toggleTextToSpeech;

  const GPTSummaryBar(this.textToSpeechEnabled, this.toggleTextToSpeech,
      {super.key});

  @override
  State<GPTSummaryBar> createState() => _GPTSummaryBarState();
}

class _GPTSummaryBarState extends State<GPTSummaryBar> {
  final MyFlutterTts myFlutterTts = MyFlutterTts();

  @override
  Widget build(BuildContext context) {
    final gptSummary =
        Provider.of<GptResponseProvider>(context, listen: true).gptSummary;

    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.all(8),
            child: const Text(
              'GPT Summary:',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
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
                      value: widget.textToSpeechEnabled,
                      activeColor: Colors.blue,
                      inactiveThumbColor: Colors.grey,
                      onChanged: (bool toggle) {
                        widget.toggleTextToSpeech(toggle);
                        if (toggle) myFlutterTts.speak(context);
                      })),
            ],
          ),
        ]),
        Container(
            height: 205,
            padding: const EdgeInsets.all(16),
            child: ListView(children: <Widget>[Text(gptSummary)])),
      ],
    );
  }
}
