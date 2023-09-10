import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class MicFloatingActionButtonsBar extends StatelessWidget {
  final bool speechEnabled;
  final bool isSummarizing;
  final String totalWords;
  final String gptResponse;
  final SpeechToText speechToText;

  final Function startListening;
  final Function stopListening;
  final Function clearGPTResponse;
  final Function chatComplete;
  final Function speak;

  const MicFloatingActionButtonsBar(
      this.speechEnabled,
      this.isSummarizing,
      this.totalWords,
      this.gptResponse,
      this.speechToText,
      this.startListening,
      this.stopListening,
      this.clearGPTResponse,
      this.chatComplete,
      this.speak,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        showSummarizeButton(),
        showClearButton(),
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

  FloatingActionButton showClearButton() {
    return FloatingActionButton(
      onPressed: () => clearGPTResponse(),
      backgroundColor:
          totalWords.isNotEmpty && !speechEnabled ? Colors.blue : Colors.grey,
      tooltip: 'Clear',
      child: const Icon(Icons.clear),
    );
  }

  Widget showSummarizeButton() {
    return isSummarizing
        ? const CircularProgressIndicator()
        : FloatingActionButton(
            onPressed: () async {
              chatComplete(totalWords);

              if (speechEnabled) {
                speak(gptResponse);
              }
            },
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
