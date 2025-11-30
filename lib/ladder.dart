import 'package:coloring_game/moon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ladderColorProvider(),
      child: MaterialApp(
        home: ladderPage(),
      ),
    ),
  );
}

class ladderPage extends StatefulWidget {
  @override
  _ladderPageState createState() => _ladderPageState();
}

class _ladderPageState extends State<ladderPage> {
  bool _showAnimation = false;

  @override
  void initState() {
    super.initState();
    Provider.of<ladderColorProvider>(context, listen: false).addListener(_onColorProviderChange);
  }

  void _onColorProviderChange() {
    if (Provider.of<ladderColorProvider>(context, listen: false).score == 4) {
      setState(() {
        _showAnimation = true;
      });

      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          _showAnimation = false;
        });

        // Navigate to the next page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => moonPage()),
        );
      });
    }
  }

  @override
  void dispose() {
    Provider.of<ladderColorProvider>(context, listen: false).removeListener(_onColorProviderChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Untitled design (9).png'),
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
                  Consumer<ladderColorProvider>(
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
                            'L',
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
                            '= Lollipop',
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
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Consumer<ladderColorProvider>(
                            builder: (context, provider, child) {
                              return GestureDetector(
                                onTapDown: (details) {
                                  _handleTap(details.localPosition, provider, context);
                                },
                                child: CustomPaint(
                                  painter: LollipopPainter(provider),
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

  void _handleTap(Offset position, ladderColorProvider provider, BuildContext context) {
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

class LollipopPainter extends CustomPainter {
  final ladderColorProvider colorProvider;

  LollipopPainter(this.colorProvider);

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

    double lollipopRadius = size.width / 2;
    double lollipopCenterX = size.width / 2;
    double lollipopCenterY = size.height / 2;

    Path swirlPath = Path();
    double radiusIncrement = 5;
    double angleIncrement = 0.8;

    for (double t = 0; t < 2 * 3.14 * 5; t += angleIncrement) {
      double radius = radiusIncrement * t;
      double x = lollipopCenterX + radius * cos(t);
      double y = lollipopCenterY + radius * sin(t);

      if (t == 0) {
        swirlPath.moveTo(x, y);
      } else {
        swirlPath.lineTo(x, y);
      }
    }

    for (int i = 0; i < 4; i++) {
      fillPaint.color = colorProvider.getPartColor(i) ?? Colors.white;
      canvas.drawPath(swirlPath, fillPaint);
      canvas.drawPath(swirlPath, strokePaint);
      swirlPath = swirlPath.shift(Offset(10, 10));
    }

    Paint stickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.red
      ..strokeWidth = 8
      ..isAntiAlias = true;
    Path stickPath = Path()
      ..moveTo(lollipopCenterX, size.height)
      ..lineTo(lollipopCenterX, size.height + 100);
    canvas.drawPath(stickPath, stickPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class ladderColorProvider with ChangeNotifier {
  final List<Color?> _colors = List<Color?>.filled(4, null);
  Color? _selectedColor;
  int _score = 0;
  bool _isColorSelected = false;

  Color? getPartColor(int index) => _colors[index];

  Color? get selectedColor => _selectedColor;
  int get score => _score;

  void setColor(Color color) {
    _selectedColor = color;
    _isColorSelected = true;
    notifyListeners();
  }

  void fillPart(int index) {
    if (_isColorSelected && _colors[index] == null) {
      _colors[index] = _selectedColor;
      _score++;
      _isColorSelected = false;
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
        _buildColorButton(context, Colors.blue),
        _buildColorButton(context, Colors.green),
        _buildColorButton(context, Colors.yellow),
      ],
    );
  }

  Widget _buildColorButton(BuildContext context, Color color) {
    return GestureDetector(
      onTap: () {
        Provider.of<ladderColorProvider>(context, listen: false).setColor(color);
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Provider.of<ladderColorProvider>(context).selectedColor == color
                ? Colors.black
                : Colors.transparent,
            width: 3,
          ),
        ),
        margin: EdgeInsets.symmetric(horizontal: 5),
      ),
    );
  }
}
