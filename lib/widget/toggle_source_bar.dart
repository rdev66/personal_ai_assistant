import 'package:flutter/material.dart';

import 'transcript_bar.dart';
import 'youtube_bar.dart';

class ToggleSourceBar extends StatefulWidget {
  const ToggleSourceBar(this.totalWords, this.speechAvailable,
      this.toggleSelected, this.selected,
      {super.key});

  final String totalWords;
  final bool speechAvailable;
  final Function toggleSelected;
  final List<bool> selected;
  @override
  State<ToggleSourceBar> createState() => _ToggleSourceBarState();
}

class _ToggleSourceBarState extends State<ToggleSourceBar> {
  @override
  Widget build(BuildContext context) {
    return widget.selected[0]
        ? TranscriptBar(widget.totalWords, 
        widget.speechAvailable, 
        widget.toggleSelected, 
        widget.selected)
        : YoutubeBar(widget.toggleSelected, widget.selected);
  }
}
