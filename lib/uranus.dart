import 'package:coloring_game/volcano.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => UranusColorProvider(),
      child: MaterialApp(
        home: UranusPage(),
      ),
    ),
  );
}

class UranusPage extends StatefulWidget {
  @override
  _UranusPageState createState() => _UranusPageState();
}

class _UranusPageState extends State<UranusPage> {
  bool _showAnimation = false;

  @override
  void initState() {
    super.initState();
    Provider.of<UranusColorProvider>(context, listen: false).addListener(_onColorProviderChange);
  }

  void _onColorProviderChange() {
    if (Provider.of<UranusColorProvider>(context, listen: false).isCompleted) {
      setState(() {
        _showAnimation = true;
      });

      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          _showAnimation = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VolcanoPage()),
        );
      });
    }
  }

  @override
  void dispose() {
    Provider.of<UranusColorProvider>(context, listen: false).removeListener(_onColorProviderChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Untitled design (20).png'),
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
                  Consumer<UranusColorProvider>(
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
            SizedBox(height: 20),
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Consumer<UranusColorProvider>(
                      builder: (context, provider, child) {
                        return GestureDetector(
                          onTapDown: (details) {
                            _handleTap(details.localPosition, provider, context);
                          },
                          child: SizedBox(
                            width: 300,
                            height: 300,
                            child: CustomPaint(
                              painter: UranusPainter(provider),
                            ),
                          ),
                        );
                      },
                    ),
                    if (_showAnimation)
                      Center(
                        child: SizedBox(
                          width: 200,
                          height: 200,
                          child: Lottie.network(
                            'https://lottie.host/23918138-eee2-4870-a6ab-74cfbcc42005/OGaxjpcGyw.json',
                          ),
                        ),
                      ),
                    Center(
                      child: Text(
                        'Uranus',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          shadows: [
                            Shadow(offset: Offset(2, 2), blurRadius: 5, color: Colors.black54),
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
                      color: Colors.white,
                      shadows: [
                        Shadow(offset: Offset(2, 2), blurRadius: 3, color: Colors.grey),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(child: ColorPalette()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(Offset position, UranusColorProvider provider, BuildContext context) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset localPosition = renderBox.globalToLocal(position);

    double ticketWidth = 300;
    double ticketHeight = 300;

    if (_isPointWithinTicket(localPosition, ticketWidth, ticketHeight)) {
      provider.fillTicket();
      setState(() {});
    }
  }

  bool _isPointWithinTicket(Offset point, double width, double height) {
    return point.dx >= 0 && point.dx <= width && point.dy >= 0 && point.dy <= height;
  }
}

class UranusPainter extends CustomPainter {
  final UranusColorProvider colorProvider;

  UranusPainter(this.colorProvider);

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // Draw the 3D effect for Uranus
    _draw3DUranus(canvas, width, height);
  }

  void _draw3DUranus(Canvas canvas, double width, double height) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final double radius = min(width / 2, height / 2);
    final Offset center = Offset(width / 2, height / 2);

    // Draw the planet's main circle
    paint.color = colorProvider.ticketColor.withOpacity(0.8);
    canvas.drawCircle(center, radius, paint);

    // Draw the shading to give a 3D effect
    final Gradient gradient = RadialGradient(
      colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
      stops: [0.5, 1.0],
    );
    paint.shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);

    // Draw rings (optional, for more detail)
    _drawRings(canvas, center, radius);
  }

  void _drawRings(Canvas canvas, Offset center, double radius) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 4
      ..isAntiAlias = true;

    final double ringRadius = radius * 1.2;

    canvas.drawOval(
      Rect.fromCenter(center: center, width: ringRadius * 2, height: ringRadius),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ColorPalette extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final selectedColor = Provider.of<UranusColorProvider>(context).selectedColor;

    final List<Color> colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: colors.map((color) {
          return GestureDetector(
            onTap: () {
              Provider.of<UranusColorProvider>(context, listen: false).selectedColor = color;
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 5),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: color == selectedColor ? Colors.black : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class UranusColorProvider extends ChangeNotifier {
  Color _ticketColor = Colors.white;
  Color _selectedColor = Colors.red;
  bool _isCompleted = false;

  Color get selectedColor => _selectedColor;

  set selectedColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  Color get ticketColor => _ticketColor;

  bool get isCompleted => _isCompleted;

  int get score => _ticketColor != Colors.white ? 1 : 0;

  void fillTicket() {
    if (_ticketColor == Colors.white && !_isColorUsed(selectedColor)) {
      _ticketColor = selectedColor;
      if (_ticketColor != Colors.white) {
        _isCompleted = true;
      }
      notifyListeners();
    }
  }

  bool _isColorUsed(Color color) {
    return _ticketColor == color;
  }
}


