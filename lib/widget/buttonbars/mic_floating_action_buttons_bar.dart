import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../provider/functions/gpt_provider_functions.dart';

class MicFloatingActionButtonsBar extends StatelessWidget {
  final bool speechEnabled;
  final bool isSummarizing;
  final String totalWords;
  final SpeechToText speechToText;

  final Function startListening;
  final Function stopListening;

  const MicFloatingActionButtonsBar(
      this.isSummarizing,
      this.speechEnabled,
      this.totalWords,
      this.speechToText,
      this.startListening,
      this.stopListening,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        showClearButton(context),
        showSummarizeButton(context),
        const Divider(),
        //
        showStopRecordButton(),
        showStartRecordButton(),
      ],
    );
  }

  FloatingActionButton showStartRecordButton() {
    return FloatingActionButton(
      backgroundColor: !speechEnabled ? Colors.green : Colors.grey,
      onPressed: () => startListening(),
      tooltip: 'Start',
      child: const Icon(Icons.mic),
    );
  }

  FloatingActionButton showStopRecordButton() {
    return FloatingActionButton(
      backgroundColor: speechEnabled ? Colors.red : Colors.grey,
      onPressed: () => stopListening(),
      tooltip: 'Stop',
      child: const Icon(Icons.mic_off),
    );
  }

  FloatingActionButton showClearButton(context) {
    return FloatingActionButton(
      onPressed: () => clearGPTResponse(context),
      backgroundColor:
          totalWords.isNotEmpty && !speechEnabled ? Colors.blue : Colors.grey,
      tooltip: 'Clear',
      child: const Icon(Icons.clear),
    );
  }

  Widget showSummarizeButton(BuildContext context) {
    return isSummarizing
        ? const CircularProgressIndicator()
        : FloatingActionButton(
            onPressed: () => generateTranscriptSummary(context, totalWords),
            backgroundColor:
                (totalWords.isNotEmpty && speechToText.isNotListening)
                    ? Colors.blue
                    : Colors.grey,
            tooltip: "Summarize",
            child: Icon(totalWords.isNotEmpty
                ? Icons.summarize
                : Icons.comments_disabled),
          );
  }
}
