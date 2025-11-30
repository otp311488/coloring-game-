import 'package:coloring_game/fence.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => EnvelopeColorProvider(),
      child: MaterialApp(
        home: EnvelopePage(),
      ),
    ),
  );
}

class EnvelopePage extends StatefulWidget {
  @override
  _EnvelopePageState createState() => _EnvelopePageState();
}

class _EnvelopePageState extends State<EnvelopePage> {
  bool _showAnimation = false;

  @override
  void initState() {
    super.initState();
    Provider.of<EnvelopeColorProvider>(context, listen: false).addListener(_onColorProviderChange);
  }

   void _onColorProviderChange() {
    if (Provider.of<EnvelopeColorProvider>(context, listen: false).score >= 15) {
      setState(() {
        _showAnimation = true;
      });

      Future.delayed(Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FencePage()),
        );
      });
    }
  }

  @override
  void dispose() {
    Provider.of<EnvelopeColorProvider>(context, listen: false).removeListener(_onColorProviderChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Untitled design (3).png'),
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
                  Consumer<EnvelopeColorProvider>(
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
                      top: -19,
                      right: -12,
                      child: Column(
                        children: [
                          Text(
                            'E',
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
                            '= Envelope',
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

                        if (dx < 150 && dy < 150) {
                          Provider.of<EnvelopeColorProvider>(context, listen: false).fillCircle(0);
                        } else if (dx < 150 && dy >= 150) {
                          Provider.of<EnvelopeColorProvider>(context, listen: false).fillCircle(1);
                        } else if (dx >= 150 && dy < 150) {
                          Provider.of<EnvelopeColorProvider>(context, listen: false).fillCircle(2);
                        }
                      },
                      child: CustomPaint(
                        painter: EnvelopeShapePainter(context.read<EnvelopeColorProvider>()),
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

class EnvelopeShapePainter extends CustomPainter {
  final EnvelopeColorProvider colorProvider;

  EnvelopeShapePainter(this.colorProvider);

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

    final envelopePath = Path()
      ..moveTo(size.width * 0.5, 0) // Top point
      ..lineTo(0, size.height * 0.6) // Bottom left
      ..lineTo(size.width, size.height * 0.6) // Bottom right
      ..close();

    canvas.drawPath(envelopePath, strokePaint);

    for (int i = 0; i < 3; i++) {
      fillPaint.color = colorProvider.getColorPart(i) ?? Colors.white;
      final partPath = Path();

      if (i == 0) {
        partPath.addPath(envelopePath, Offset.zero);
      } else if (i == 1) {
        partPath.addRect(Rect.fromLTRB(0, size.height * 0.6, size.width, size.height));
      } else if (i == 2) {
        partPath.addOval(Rect.fromCircle(center: Offset(size.width * 0.5, size.height * 0.6), radius: 50));
      }

      canvas.drawPath(partPath, fillPaint);
      canvas.drawPath(partPath, strokePaint);
    }

    final stampPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.6), 20, stampPaint);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.6), 20, strokePaint);
  }

  @override
  bool shouldRepaint(EnvelopeShapePainter oldDelegate) => true;
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
    final isSelected = Provider.of<EnvelopeColorProvider>(context).selectedColor == color;

    return GestureDetector(
      onTap: () {
        Provider.of<EnvelopeColorProvider>(context, listen: false).selectColor(color);
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

class EnvelopeColorProvider with ChangeNotifier {
  List<Color?> _colors = List.filled(3, null);
  Color? _selectedColor;
  int _score = 0;

  Color? get selectedColor => _selectedColor;
  int get score => _score;

  void selectColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  void fillCircle(int partIndex) {
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
