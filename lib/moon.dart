import 'package:coloring_game/necklace.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => moonColorProvider(),
      child: MaterialApp(
        home: moonPage(),
      ),
    ),
  );
}

class moonPage extends StatefulWidget {
  @override
  _moonPageState createState() => _moonPageState();
}

class _moonPageState extends State<moonPage> {
  bool _showAnimation = false;

  @override
  void initState() {
    super.initState();
    Provider.of<moonColorProvider>(context, listen: false).addListener(_onColorProviderChange);
  }

  void _onColorProviderChange() {
    if (Provider.of<moonColorProvider>(context, listen: false).score == 4) {
      setState(() {
        _showAnimation = true;
      });

      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          _showAnimation = false;
        });

        
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NecklacePage()),
        );
      });
    }
  }

  @override
  void dispose() {
    Provider.of<moonColorProvider>(context, listen: false).removeListener(_onColorProviderChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Untitled design (10).png'), 
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
                        Shadow(offset: Offset(2, 2), blurRadius: 5, color: Colors.black54),
                      ],
                    ),
                  ),
                  Consumer<moonColorProvider>(
                    builder: (context, provider, child) {
                      return Row(
                        children: [
                          Icon(Icons.emoji_events, color: Colors.amber),
                          SizedBox(width: 5),
                          Text(
                            'Score: ${provider.score}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(offset: Offset(1, 1), blurRadius: 4, color: Colors.black54),
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
                      top: 20,
                      right: 0,
                      child: Column(
                        children: [
                          Text(
                            'M',
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
                            '= Moon',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
                    Container(
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Consumer<moonColorProvider>(
                              builder: (context, provider, child) {
                                return GestureDetector(
                                  onTapDown: (details) {
                                    _handleTap(details.localPosition, provider, context);
                                  },
                                  child: CustomPaint(
                                    painter: CrescentMoonPainter(provider),
                                    child: Container(
                                      width: 200,
                                      height: 300,
                                    ),
                                  ),
                                );
                              },
                            ),
                            if (_showAnimation)
                              Center(
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
                      color: Colors.black,
                      shadows: [
                        Shadow(offset: Offset(2, 2), blurRadius: 3, color: Colors.grey),
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

  void _handleTap(Offset position, moonColorProvider provider, BuildContext context) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;
    double dx = position.dx / size.width;
    double dy = position.dy / size.height;

    int partIndex = -1;

    if (dx >= 0.5 && dy <= 0.5) {
      partIndex = 0;
    } else if (dx < 0.5 && dy <= 0.5) {
      partIndex = 1;
    } else if (dx >= 0.5 && dy > 0.5) {
      partIndex = 2;
    } else if (dx < 0.5 && dy > 0.5) {
      partIndex = 3;
    }

    if (partIndex != -1) {
      provider.fillPart(partIndex);
    }
  }
}

class CrescentMoonPainter extends CustomPainter {
  final moonColorProvider colorProvider;

  CrescentMoonPainter(this.colorProvider);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final Paint strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 2
      ..isAntiAlias = true;

    
    double moonRadius = size.width / 2;
    double moonCenterX = size.width / 2;
    double moonCenterY = size.height / 2;

    Path moonPath = Path();
    moonPath.moveTo(moonCenterX, moonCenterY);
    moonPath.arcTo(Rect.fromCircle(center: Offset(moonCenterX, moonCenterY), radius: moonRadius), -pi / 4, pi, false);
    moonPath.arcTo(Rect.fromCircle(center: Offset(moonCenterX + moonRadius / 3, moonCenterY), radius: moonRadius / 1.5), 3 * pi / 4, -pi, false);
    moonPath.close();

    
    for (int i = 0; i < 4; i++) {
      fillPaint.color = colorProvider.getPartColor(i) ?? Colors.white;
      canvas.drawPath(moonPath, fillPaint);
      canvas.drawPath(moonPath, strokePaint);
      moonPath = moonPath.shift(Offset(10, 10)); // 
    }

    
    Paint dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white
      ..isAntiAlias = true;

    for (int i = 0; i < 20; i++) {
      double dotX = moonCenterX + (moonRadius - 10) * cos(2 * pi * i / 20);
      double dotY = moonCenterY + (moonRadius - 10) * sin(2 * pi * i / 20);
      canvas.drawCircle(Offset(dotX, dotY), 5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class moonColorProvider with ChangeNotifier {
  Color? _selectedColor;
  List<Color?> _colors = List<Color?>.filled(4, null);
  int _score = 0;
  bool _isColorSelected = false;

  Color? get selectedColor => _selectedColor;
  int get score => _score;

  Color? getPartColor(int index) {
    return _colors[index];
  }

  void setColor(Color color) {
    _selectedColor = color;
    _isColorSelected = true; 
    notifyListeners();
  }

  void fillPart(int index) {
    if (_selectedColor != null && _colors[index] == null) {
      _colors[index] = _selectedColor;
      _score++;
      notifyListeners();
    }
  }
}

class ColorPalette extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<moonColorProvider>(
      builder: (context, provider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildColorCircle(context, provider, Colors.red),
            _buildColorCircle(context, provider, Colors.green),
            _buildColorCircle(context, provider, Colors.blue),
            _buildColorCircle(context, provider, Colors.yellow),
             _buildColorCircle(context, provider, Colors.orange),
            
          ],
        );
      },
    );
  }

  Widget _buildColorCircle(BuildContext context, moonColorProvider provider, Color color) {
    return GestureDetector(
      onTap: () {
        provider.setColor(color);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: provider.selectedColor == color ? Colors.black : Colors.transparent,
            width: 3,
          ),
        ),
      ),
    );
  }
}


