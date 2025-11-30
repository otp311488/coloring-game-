import 'package:coloring_game/wand.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => VolcanoColorProvider(),
      child: MaterialApp(
        home: VolcanoPage(),
      ),
    ),
  );
}

class VolcanoPage extends StatefulWidget {
  @override
  _VolcanoPageState createState() => _VolcanoPageState();
}

class _VolcanoPageState extends State<VolcanoPage> {
  bool _showAnimation = false;

  @override
  void initState() {
    super.initState();
    Provider.of<VolcanoColorProvider>(context, listen: false).addListener(_onColorProviderChange);
  }

  void _onColorProviderChange() {
    if (Provider.of<VolcanoColorProvider>(context, listen: false).isCompleted) {
      setState(() {
        _showAnimation = true;
      });

      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          _showAnimation = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WandPage()),
        );
      });
    }
  }

  @override
  void dispose() {
    Provider.of<VolcanoColorProvider>(context, listen: false).removeListener(_onColorProviderChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Untitled design (21).png'),
            fit: BoxFit.fill,
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
                  Consumer<VolcanoColorProvider>(
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
                    Consumer<VolcanoColorProvider>(
                      builder: (context, provider, child) {
                        return GestureDetector(
                          onTapDown: (details) {
                            _handleTap(details.localPosition, provider, context);
                          },
                          child: SizedBox(
                            width: 300,
                            height: 300,
                            child: CustomPaint(
                              painter: VolcanoPainter(provider),
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
                        'Volcano',
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

  void _handleTap(Offset position, VolcanoColorProvider provider, BuildContext context) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset localPosition = renderBox.globalToLocal(position);

    double canvasWidth = 300;
    double canvasHeight = 300;

    if (_isPointWithinVolcano(localPosition, canvasWidth, canvasHeight)) {
      provider.fillVolcano();
      setState(() {});
    }
  }

  bool _isPointWithinVolcano(Offset point, double width, double height) {
    return point.dx >= 0 && point.dx <= width && point.dy >= 0 && point.dy <= height;
  }
}

class VolcanoPainter extends CustomPainter {
  final VolcanoColorProvider colorProvider;

  VolcanoPainter(this.colorProvider);

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // Draw the 3D volcano
    _draw3DVolcano(canvas, width, height);
  }

  void _draw3DVolcano(Canvas canvas, double width, double height) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final Path volcanoPath = Path()
      ..moveTo(width / 2, 0)
      ..lineTo(0, height)
      ..lineTo(width, height)
      ..close();

    paint.color = colorProvider.volcanoColor.withOpacity(0.8);
    canvas.drawPath(volcanoPath, paint);

    // Draw the shading to give a 3D effect
    final Gradient gradient = LinearGradient(
      colors: [Colors.transparent, Colors.black.withOpacity(1)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    paint.shader = gradient.createShader(Rect.fromLTWH(0, 0, width, height));
    canvas.drawPath(volcanoPath, paint);

    // Draw lava (optional, for more detail)
    _drawLava(canvas, width, height);
  }

  void _drawLava(Canvas canvas, double width, double height) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.red.withOpacity(0.7)
      ..isAntiAlias = true;

    final Path lavaPath = Path()
      ..moveTo(width / 2, 0) // Start at the top center of the volcano
      ..quadraticBezierTo(width / 2 - 20, height / 4, width / 2 + 30, height / 3) // Curly path segment
      ..quadraticBezierTo(width / 2 - 10, height / 2.5, width / 2 + 40, height / 2) // Another curly path segment
      ..lineTo(width / 2 + 20, height / 2) // End the lava flow

      // Close the path to avoid filling the bottom part of the volcano
      ..lineTo(width / 2, 0)
      ..close();

    canvas.drawPath(lavaPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}


class ColorPalette extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final selectedColor = Provider.of<VolcanoColorProvider>(context).selectedColor;

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
              Provider.of<VolcanoColorProvider>(context, listen: false).selectedColor = color;
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

class VolcanoColorProvider extends ChangeNotifier {
  Color _volcanoColor = Colors.grey;
  Color _selectedColor = Colors.red;
  bool _isCompleted = false;

  Color get selectedColor => _selectedColor;

  set selectedColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  Color get volcanoColor => _volcanoColor;

  bool get isCompleted => _isCompleted;

  int get score => _volcanoColor != Colors.grey ? 1 : 0;

  void fillVolcano() {
    if (_volcanoColor == Colors.grey && !_isColorUsed(selectedColor)) {
      _volcanoColor = selectedColor;
      if (_volcanoColor != Colors.grey) {
        _isCompleted = true;
      }
      notifyListeners();
    }
  }

  bool _isColorUsed(Color color) {
    return _volcanoColor == color;
  }
}


