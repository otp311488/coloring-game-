import 'package:coloring_game/icecream.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:lottie/lottie.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => HouseColorProvider(),
      child: MaterialApp(
        home: HousePage(),
      ),
    ),
  );
}

class HousePage extends StatefulWidget {
  @override
  _HousePageState createState() => _HousePageState();
}

class _HousePageState extends State<HousePage> {
  bool _showAnimation = false;
  bool _disableFilling = false;

  @override
  void initState() {
    super.initState();
    Provider.of<HouseColorProvider>(context, listen: false)
        .addListener(_onColorProviderChange);
  }

 void _onColorProviderChange() {
  if (Provider.of<HouseColorProvider>(context, listen: false).score == 5) {
    setState(() {
      _showAnimation = true;
      _disableFilling = true; // Disable further filling
    });

    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _showAnimation = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => IceCreamPage()),
      );
    });
  }
}


  @override
  void dispose() {
    Provider.of<HouseColorProvider>(context, listen: false)
        .removeListener(_onColorProviderChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Untitled design (1).png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ABC Learning',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 5,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                  Consumer<HouseColorProvider>(
                    builder: (context, provider, child) {
                      return Row(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Score: ${provider.score}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 4,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              elevation: 10,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
            ),
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 100,
                      right: 0,
                      child: Column(
                        children: [
                          Text(
                            'H',
                            style: TextStyle(
                              fontSize: 49,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              shadows: [
                                Shadow(
                                  offset: Offset(2, 2),
                                  blurRadius: 3,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '= house',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              shadows: [
                                Shadow(
                                  offset: Offset(2, 2),
                                  blurRadius: 3,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Consumer<HouseColorProvider>(
                      builder: (context, provider, child) {
                        return GestureDetector(
                          onTapDown: _disableFilling
                              ? null
                              : (details) {
                                  final center = Offset(150, 150);
                                  final dx = details.localPosition.dx - center.dx;
                                  final dy = details.localPosition.dy - center.dy;
                                  final angle = (dx != 0 || dy != 0)
                                      ? (atan2(dy, dx) + pi) % (2 * pi)
                                      : 0;

                                  int partIndex;
                                  if (angle < pi / 4) {
                                    partIndex = 0; // Roof
                                  } else if (angle < 3 * pi / 4) {
                                    partIndex = 1; // Left side
                                  } else if (angle < 5 * pi / 4) {
                                    partIndex = 2; // Bottom
                                  } else if (angle < 7 * pi / 4) {
                                    partIndex = 3; // Right side
                                  } else {
                                    partIndex = 4; // Inside
                                  }

                                  provider.fillPart(partIndex);
                                },
                          child: CustomPaint(
                            painter: HousePainter(provider),
                            child: Container(
                              width: 300,
                              height: 300,
                            ),
                          ),
                        );
                      },
                    ),
                    if (_showAnimation)
                      Positioned(
                        child: SizedBox(
                          width: 250,
                          height: 250,
                          child: Lottie.network(
                            'https://lottie.host/23918138-eee2-4870-a6ab-74cfbcc42005/OGaxjpcGyw.json',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              height: 150,
              child: Column(
                children: [
                  Text(
                    'Select Color Plate',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 3,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  ColorPalette(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HousePainter extends CustomPainter {
  final HouseColorProvider colorProvider;

  HousePainter(this.colorProvider);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final Paint strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white // Set stroke color to white
      ..strokeWidth = 2
      ..isAntiAlias = true;

    // Define the path for the house shape
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, size.height / 2);
    path.close();

    // Draw the house
    fillPaint.color = colorProvider.getPartColor(0) ?? Colors.grey;
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint); // White outline for the house

    // Draw roof
    final roofPath = Path();
    roofPath.moveTo(size.width / 2, 0);
    roofPath.lineTo(size.width, size.height / 2);
    roofPath.lineTo(size.width / 2, size.height / 2);
    roofPath.close();

    fillPaint.color = colorProvider.getPartColor(1) ?? Colors.red;
    canvas.drawPath(roofPath, fillPaint);
    canvas.drawPath(roofPath, strokePaint); // White outline for the roof

    // Draw other parts of the house (left, bottom, right, inside)
    for (int i = 2; i < 5; i++) {
      fillPaint.color = colorProvider.getPartColor(i) ?? Colors.brown;
      // Adjust the rectangle's position for each part
      Rect rect;
      switch (i) {
        case 2: // Left
          rect = Rect.fromLTWH(0, size.height / 4, size.width / 2, size.height / 2);
          break;
        case 3: // Bottom
          rect = Rect.fromLTWH(0, size.height / 2, size.width, size.height / 2);
          break;
        case 4: // Right
          rect = Rect.fromLTWH(size.width / 2, size.height / 4, size.width / 2, size.height / 2);
          break;
        default:
          rect = Rect.zero;
      }

      canvas.drawRect(rect, fillPaint);
      canvas.drawRect(rect, strokePaint); // White outline for each part
    }

    // Draw text on the shape
    final textSpan = TextSpan(
      text: 'H = house',
      style: TextStyle(
        color: Colors.black87,
        fontSize: 26,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            offset: Offset(2, 2),
            blurRadius: 3,
            color: Colors.grey,
          ),
        ],
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class HouseColorProvider extends ChangeNotifier {
  final List<Color?> _partColors = List<Color?>.filled(5, null);
  int score = 0;
  Color? _selectedColor;

  Color? get selectedColor => _selectedColor;  // Add this line

  Color? getPartColor(int partIndex) {
    return _partColors[partIndex];
  }

  void setSelectedColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  void fillPart(int partIndex) {
    if (_selectedColor != null && _partColors[partIndex] == null) {
      _partColors[partIndex] = _selectedColor;
      score++;
      notifyListeners();
    }
  }
}

class ColorPalette extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildColorButton(context, Colors.red),
        _buildColorButton(context, Colors.green),
        _buildColorButton(context, Colors.blue),
        _buildColorButton(context, Colors.yellow),
        _buildColorButton(context, Colors.purple),
      ],
    );
  }

  Widget _buildColorButton(BuildContext context, Color color) {
    final isSelected = Provider.of<HouseColorProvider>(context).selectedColor == color;

    return GestureDetector(
      onTap: () {
        Provider.of<HouseColorProvider>(context, listen: false).setSelectedColor(color);
      },
      child: Container(
        width: 50,
        height: 50,
        margin: EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              offset: Offset(2, 2),
              blurRadius: 5,
              color: Colors.black26,
            ),
          ],
          border: isSelected ? Border.all(color: Colors.black, width: 3) : null,  // Add border if selected
        ),
      ),
    );
  }
}
