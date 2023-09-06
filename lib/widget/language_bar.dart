import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class LanguageBar extends StatelessWidget {
  final String _selectedLocaleId;
  final List<LocaleName> _availableLocales;

  const LanguageBar(this._selectedLocaleId, this._availableLocales,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        alignment: Alignment.topLeft,
        padding: const EdgeInsets.all(8),
        child: const Text(
          'Language:',
          style: TextStyle(fontSize: 20.0),
        ),
      ),
      Container(
        alignment: Alignment.topRight,
        padding: const EdgeInsets.all(8),
        child: DropdownButton<String>(
          value: _selectedLocaleId,
          items: _availableLocales.map((LocaleName locale) {
            return DropdownMenuItem<String>(
              value: locale.localeId,
              child: Text(locale.name),
            );
          }).toList(),
          onChanged: (_) {},
        ),
      ),
    ]);
  }
}
