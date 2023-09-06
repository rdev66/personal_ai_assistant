import 'package:flutter/material.dart';

class GPTBar extends StatefulWidget {
  
  final String gptResponse;  
  final bool textToSpeechEnabled;
  final Function toggleTextToSpeech;

  const GPTBar(this.gptResponse, this.textToSpeechEnabled, this.toggleTextToSpeech, {super.key});

  @override
  State<GPTBar> createState() => _GPTBarState();
}

class _GPTBarState extends State<GPTBar> {

  @override
  Widget build(BuildContext context) {
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
                    onChanged: (bool toggle) => widget.toggleTextToSpeech(toggle),
                  )),
            ],
          ),
        ]),
        Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            child: ListView(children: <Widget>[Text(widget.gptResponse)])),
      ],
    );
  }
}
