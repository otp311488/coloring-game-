import 'package:flutter/material.dart';

class CakeColorProvider with ChangeNotifier {
  List<Color?> _colors = List.filled(6, null); // Change to 6 parts
  Color? _selectedColor;
  int _score = 0;

  Color? get selectedColor => _selectedColor;
  int get score => _score;

  void selectColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  void fillCircle(int partIndex) {
    if (partIndex < 0 || partIndex >= _colors.length) return; // Validate index
    if (_colors[partIndex] == null && _selectedColor != null) {
      _colors[partIndex] = _selectedColor;
      _score += 5; // Increase score by 5 for each filled part
      notifyListeners();
    }
  }

  Color? getColorPart(int partIndex) {
    return _colors[partIndex];
  }
}
