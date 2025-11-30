import 'package:coloring_game/star.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => RainbowColorProvider(),
      child: MaterialApp(
        home: RainbowPage(),
      ),
    ),
  );
}

class RainbowPage extends StatefulWidget {
  @override
  _RainbowPageState createState() => _RainbowPageState();
}

class _RainbowPageState extends State<RainbowPage> {
  bool _showAnimation = false;

  @override
  void initState() {
    super.initState();
    Provider.of<RainbowColorProvider>(context, listen: false).addListener(_onColorProviderChange);
  }

  void _onColorProviderChange() {
    if (Provider.of<RainbowColorProvider>(context, listen: false).isCompleted) {
      setState(() {
        _showAnimation = true;
      });

      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          _showAnimation = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StarPage()),
        );
      });
    }
  }

  @override
  void dispose() {
    Provider.of<RainbowColorProvider>(context, listen: false).removeListener(_onColorProviderChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Untitled design (16).png'),
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
                  Consumer<RainbowColorProvider>(
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
                    Consumer<RainbowColorProvider>(
                      builder: (context, provider, child) {
                        return GestureDetector(
                          onTapDown: (details) {
                            _handleTap(details.localPosition, provider, context);
                          },
                          child: SizedBox(
                            width: 200, // reduced width
                            height: 300, // increased height
                            child: CustomPaint(
                              painter: RulerPainter(provider),
                            ),
                          ),
                        );
                      },
                    ),
                    if (_showAnimation)
                      Center(
                        child: SizedBox(
                          width: 200, // reduced width
                          height: 200, // reduced height
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
                      color: Colors.black,
                      shadows: [
                        Shadow(offset: Offset(2, 2), blurRadius: 3, color: Colors.grey),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(child: ColorPalette()), // Used Expanded to prevent overflow
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(Offset position, RainbowColorProvider provider, BuildContext context) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;
    double dy = position.dy / size.height;

    int segmentCount = 6; // 6 segments for the ruler
    int y = (dy * segmentCount).floor();

    if (y >= 0 && y < provider.tiles.length) {
      provider.fillTile(y);
    }
  }
}

class RulerPainter extends CustomPainter {
  final RainbowColorProvider colorProvider;

  RulerPainter(this.colorProvider);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final Paint strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 2
      ..isAntiAlias = true;

    final double segmentHeight = size.height / 6;
    final double width = size.width;

    // Draw the ruler background
    final Rect rulerRect = Rect.fromLTWH(0, 0, width, size.height);
    paint.color = Colors.grey[300]!;
    canvas.drawRect(rulerRect, paint);
    paint.color = Colors.black;
    canvas.drawRect(rulerRect, strokePaint);

    // Draw the segments with color
    for (int i = 0; i < 6; i++) {
      paint.color = colorProvider.tiles[i];
      double top = i * segmentHeight;
      double bottom = (i + 1) * segmentHeight;

      // Draw filled rectangle for each segment
      canvas.drawRect(
        Rect.fromLTRB(0, top, width, bottom),
        paint,
      );

      // Draw black border for each segment
      canvas.drawRect(
        Rect.fromLTRB(0, top, width, bottom),
        strokePaint,
      );
    }

    // Draw ruler markings
    drawMarkings(canvas, size);

    // Draw ruler label
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Ruler',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          shadows: [
            Shadow(offset: Offset(1, 1), blurRadius: 4, color: Colors.grey),
          ],
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )
      ..layout(maxWidth: size.width);

    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        size.height - textPainter.height - 10,
      ),
    );
  }

  void drawMarkings(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final double height = size.height;
    final double width = size.width;
    final double segmentHeight = height / 6;

    // Number styles
    final List<TextStyle> numberStyles = [
      TextStyle(fontSize: 12, color: Colors.black),
      TextStyle(fontSize: 12, color: Colors.black),
      TextStyle(fontSize: 12, color: Colors.black),
      TextStyle(fontSize: 12, color: Colors.black),
      TextStyle(fontSize: 12, color: Colors.black),
      TextStyle(fontSize: 12, color: Colors.black),
      TextStyle(fontSize: 12, color: Colors.black),
    ];

    // Millimeter markings
    for (int i = 0; i <= 5; i++) {
      double y = i * segmentHeight;
      canvas.drawLine(
        Offset(0, y),
        Offset(10, y),
        paint,
      );

      // Draw millimeter markings within each segment
      for (int j = 1; j <= 5; j++) {
        double millimeterY = y + (j * (segmentHeight / 5)) - (segmentHeight / 12);
        canvas.drawLine(
          Offset(10, millimeterY),
          Offset(15, millimeterY),
          paint,
        );

        // Draw millimeter numbers
        TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: '$j',
            style: numberStyles[i % numberStyles.length], // Use different styles
          ),
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(20, millimeterY - textPainter.height / 2),
        );
      }

      if (i % 1 == 0) {
        TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: '${i} cm',
            style: numberStyles[i % numberStyles.length], // Use different styles
          ),
          textAlign: TextAlign.right,
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(width - textPainter.width - 5, y - textPainter.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ColorPalette extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final selectedColor = Provider.of<RainbowColorProvider>(context).selectedColor;

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
              Provider.of<RainbowColorProvider>(context, listen: false).selectedColor = color;
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

class RainbowColorProvider extends ChangeNotifier {
  List<Color> tiles = List.generate(6, (_) => Colors.white);
  Color _selectedColor = Colors.red;

  Color get selectedColor => _selectedColor;
  set selectedColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  void fillTile(int tileIndex) {
    if (tiles[tileIndex] == Colors.white && !_isColorUsed(selectedColor)) {
      tiles[tileIndex] = selectedColor;
      notifyListeners();

      if (tiles.every((tile) => tile != Colors.white)) {
        _isCompleted = true;
        notifyListeners();
      }
    }
  }

  bool _isCompleted = false;
  bool get isCompleted => _isCompleted;

  int get score => tiles.where((tile) => tile != Colors.white).length;

  bool _isColorUsed(Color color) {
    return tiles.contains(color);
  }
}


