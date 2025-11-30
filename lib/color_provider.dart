import 'package:flutter/material.dart';

class ColorProvider extends ChangeNotifier {
  Color _selectedColor = Colors.black;
  List<Color?> _filledColors = [null, null, null];
  int _score = 0;

  Color get selectedColor => _selectedColor;
  int get score => _score;

  void selectColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  void fillCircle(int partIndex) {
    if (_filledColors[partIndex] == null) {
      _filledColors[partIndex] = _selectedColor;
      _score += 5;
      notifyListeners();
      
      if (_score == 15) {
        // Notify that the score has reached 15
        notifyScoreReached();
      }
    }
  }

  void notifyScoreReached() {
    // This can be a callback or some other method to inform listeners
    notifyListeners();
  }

  Color? getColorPart(int index) {
    return _filledColors[index];
  }
}
