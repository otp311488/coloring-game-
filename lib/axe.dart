import 'package:coloring_game/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AxeColorProvider(),
      child: MaterialApp(
        home: AxePage(),
      ),
    ),
  );
}

class AxePage extends StatefulWidget {
  @override
  _AxePageState createState() => _AxePageState();
}

class _AxePageState extends State<AxePage> {
  bool _showAnimation = false;

  @override
  void initState() {
    super.initState();
    Provider.of<AxeColorProvider>(context, listen: false).addListener(_onColorProviderChange);
  }

  void _onColorProviderChange() {
    if (Provider.of<AxeColorProvider>(context, listen: false).score >= 10) {
      setState(() {
        _showAnimation = true;
      });

      Future.delayed(Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GameScreen()),
        );
      });
    }
  }

  @override
  void dispose() {
    Provider.of<AxeColorProvider>(context, listen: false).removeListener(_onColorProviderChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Untitled design (25).png'),
            fit: BoxFit.contain,
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
                  Consumer<AxeColorProvider>(
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
                      top: 19,
                      right: 1,
                      child: Column(
                        children: [
                          Text(
                            'A',
                            style: TextStyle(
                              fontSize: 49,
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
                            '= Axe',
                            style: TextStyle(
                              fontSize: 26,
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
                    GestureDetector(
                      onTapDown: (details) {
                        final dx = details.localPosition.dx;
                        final dy = details.localPosition.dy;

                        // Define the regions for the blade and handle
                        if (dx < 150 && dy < 150) {
                          Provider.of<AxeColorProvider>(context, listen: false).fillPart(0); // Blade
                        } else if (dx >= 150 && dy >= 150) {
                          Provider.of<AxeColorProvider>(context, listen: false).fillPart(1); // Handle
                        }
                      },
                      child: CustomPaint(
                        painter: AxeShapePainter(context.read<AxeColorProvider>()),
                        child: Container(
                          width: 300,
                          height: 300,
                        ),
                      ),
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

class AxeShapePainter extends CustomPainter {
  final AxeColorProvider colorProvider;

  AxeShapePainter(this.colorProvider);

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

    // Draw Axe Blade with upward curve
    final bladePath = Path()
      ..moveTo(size.width * 0.3, size.height * 0.25)
      ..arcToPoint(
        Offset(size.width * 0.7, size.height * 0.25),
        radius: Radius.circular(size.width * 0.4),
        clockwise: true, // Clockwise for upward curve
      )
      ..lineTo(size.width * 0.65, size.height * 0.5)
      ..lineTo(size.width * 0.35, size.height * 0.5)
      ..close();

    // Draw Axe Handle with slight curve
    final handlePath = Path()
      ..moveTo(size.width * 0.45, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.75, size.width * 0.45, size.height) // Curve
      ..lineTo(size.width * 0.55, size.height)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.75, size.width * 0.55, size.height * 0.5)
      ..close();

    final paths = [bladePath, handlePath];

    for (int i = 0; i < 2; i++) {
      fillPaint.color = colorProvider.getColorPart(i) ?? Colors.white;
      canvas.drawPath(paths[i], fillPaint);
      canvas.drawPath(paths[i], strokePaint);
    }
  }

  @override
  bool shouldRepaint(AxeShapePainter oldDelegate) => true;
}

class ColorPalette extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ColorButton(color: Colors.red),
        ColorButton(color: Colors.green),
        ColorButton(color: Colors.blue),
        ColorButton(color: Colors.yellow),
        ColorButton(color: Colors.orange),
        ColorButton(color: Colors.purple),
      ],
    );
  }
}

class ColorButton extends StatelessWidget {
  final Color color;

  ColorButton({required this.color});

  @override
  Widget build(BuildContext context) {
    final isSelected = Provider.of<AxeColorProvider>(context).selectedColor == color;

    return GestureDetector(
      onTap: () {
        Provider.of<AxeColorProvider>(context, listen: false).selectColor(color);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        width: isSelected ? 45 : 40,
        height: isSelected ? 45 : 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(2, 2),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }
}

class AxeColorProvider with ChangeNotifier {
  List<Color?> _colors = List.filled(2, null); // 0: Blade, 1: Handle
  Color? _selectedColor;
  int _score = 0;

  Color? get selectedColor => _selectedColor;
  int get score => _score;

  void selectColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  void fillPart(int partIndex) {
    if (partIndex < 0 || partIndex >= _colors.length) return;
    if (_colors[partIndex] == null && _selectedColor != null) {
      _colors[partIndex] = _selectedColor;
      _score += 5;
      notifyListeners();
    }
  }

  Color? getColorPart(int partIndex) {
    return _colors[partIndex];
  }
}


