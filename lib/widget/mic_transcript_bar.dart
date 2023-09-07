import 'package:flutter/material.dart';
import 'toggle_bar.dart';

class MicTranscriptBar extends StatelessWidget {
  const MicTranscriptBar(
      this.totalWords, this.speechAvailable, this.toggleselected, this.selected,
      {super.key});

  final bool speechAvailable;
  final String totalWords;

  final Function toggleselected;
  final List<bool> selected;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.all(8),
            child: const Text(
              'Transcript from Microphone',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ),
          ToggleBar(toggleselected, selected),
        ],
      ),
      SizedBox(
        height: 200,
        child: ListView(children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              totalWords.isNotEmpty
                  ? totalWords
                  : speechAvailable
                      ? 'Tap the microphone to start listening...'
                      : 'Speech not available',
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          )
        ]),
      ),
    ]);
  }
}
