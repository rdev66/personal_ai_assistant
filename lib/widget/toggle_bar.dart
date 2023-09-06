import 'package:flutter/material.dart';

class ToggleBar extends StatefulWidget {
  final Function toggleSelected;
  final List<bool> selected;

  const ToggleBar(this.toggleSelected, this.selected, {super.key});

  @override
  State<ToggleBar> createState() => _ToggleBarState();
}

class _ToggleBarState extends State<ToggleBar> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          child: ToggleButtons(
            onPressed: (selectedIdx) => widget.toggleSelected(selectedIdx),
            direction: Axis.horizontal,
            isSelected: widget.selected,
            children: const [
              Icon(
                Icons.mic_external_on,
                size: 25,
              ),
              Icon(
                Icons.videocam,
                size: 25,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
