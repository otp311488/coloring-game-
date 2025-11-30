import 'package:coloring_game/quilt.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => PencilColorProvider(),
      child: MaterialApp(
        home: PencilPage(),
      ),
    ),
  );
}

class PencilPage extends StatefulWidget {
  @override
  _PencilPageState createState() => _PencilPageState();
}

class _PencilPageState extends State<PencilPage> {
  bool _showAnimation = false;

  @override
  void initState() {
    super.initState();
    Provider.of<PencilColorProvider>(context, listen: false).addListener(_onColorProviderChange);
  }

  void _onColorProviderChange() {
    if (Provider.of<PencilColorProvider>(context, listen: false).isCompleted) {
      setState(() {
        _showAnimation = true;
      });

      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          _showAnimation = false;
        });

        
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuiltPage()),
        );
      });
    }
  }

  @override
  void dispose() {
    Provider.of<PencilColorProvider>(context, listen: false).removeListener(_onColorProviderChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Untitled design (13).png'),
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
                  Consumer<PencilColorProvider>(
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
                      top: 195,
                      right: 0,
                      child: Column(
                        children: [
                          Text(
                            'P',
                            style: TextStyle(
                              fontSize: 52,
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
                            '= Pencil',
                            style: TextStyle(
                              fontSize: 30,
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
                    Consumer<PencilColorProvider>(
                      builder: (context, provider, child) {
                        return GestureDetector(
                          onTapDown: (details) {
                            _handleTap(details.localPosition, provider, context);
                          },
                          child: CustomPaint(
                            painter: PencilPainter(provider),
                            child: Container(
                              width: 300,
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

  void _handleTap(Offset position, PencilColorProvider provider, BuildContext context) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;
    double dx = position.dx / size.width;
    double dy = position.dy / size.height;

    int partIndex = -1;

    
    Path leadPath = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width / 3, size.height / 4)
      ..lineTo(2 * size.width / 3, size.height / 4)
      ..close();
    Path bodyPath = Path()
      ..moveTo(size.width / 3, size.height / 4)
      ..lineTo(size.width / 3, 3 * size.height / 4)
      ..lineTo(2 * size.width / 3, 3 * size.height / 4)
      ..lineTo(2 * size.width / 3, size.height / 4)
      ..close();
    Path eraserPath = Path()
      ..moveTo(size.width / 3, 3 * size.height / 4)
      ..lineTo(size.width / 3, size.height)
      ..lineTo(2 * size.width / 3, size.height)
      ..lineTo(2 * size.width / 3, 3 * size.height / 4)
      ..close();

    
    if (leadPath.contains(position)) {
      partIndex = 0;
    } else if (bodyPath.contains(position)) {
      partIndex = 1;
    } else if (eraserPath.contains(position)) {
      partIndex = 2;
    }

    if (partIndex != -1) {
      provider.fillPart(partIndex);
    }
  }
}

class PencilPainter extends CustomPainter {
  final PencilColorProvider colorProvider;

  PencilPainter(this.colorProvider);

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

    
    Path leadPath = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width / 3, size.height / 4)
      ..lineTo(2 * size.width / 3, size.height / 4)
      ..close();
    Path bodyPath = Path()
      ..moveTo(size.width / 3, size.height / 4)
      ..lineTo(size.width / 3, 3 * size.height / 4)
      ..lineTo(2 * size.width / 3, 3 * size.height / 4)
      ..lineTo(2 * size.width / 3, size.height / 4)
      ..close();
    Path eraserPath = Path()
      ..moveTo(size.width / 3, 3 * size.height / 4)
      ..lineTo(size.width / 3, size.height)
      ..lineTo(2 * size.width / 3, size.height)
      ..lineTo(2 * size.width / 3, 3 * size.height / 4)
      ..close();

    _drawPencilPart(canvas, leadPath, 0, fillPaint, strokePaint);
    _drawPencilPart(canvas, bodyPath, 1, fillPaint, strokePaint);
    _drawPencilPart(canvas, eraserPath, 2, fillPaint, strokePaint);

    
    final linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1
      ..isAntiAlias = true;

    double startY = size.height / 4;
    double endY = 3 * size.height / 4;
    double intervalX = size.width / 6;

    for (int i = 1; i <= 3; i++) {
      double startX = (i + 1) * intervalX;
      canvas.drawLine(Offset(startX, startY), Offset(startX, endY), linePaint);
    }
  }

  void _drawPencilPart(Canvas canvas, Path path, int partIndex, Paint fillPaint, Paint strokePaint) {
    fillPaint.color = colorProvider.parts[partIndex];
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ColorPalette extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    final selectedColor = Provider.of<PencilColorProvider>(context).selectedColor;

    final List<Color> colors = [Colors.red, Colors.green, Colors.blue, Colors.yellow, Colors.orange];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: colors.map((color) {
        return GestureDetector(
          onTap: () {
            Provider.of<PencilColorProvider>(context, listen: false).selectedColor = color;
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 5),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: color == selectedColor ? Colors.black : Colors.transparent, // Highlight the selected color
                width: 3,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}


class PencilColorProvider extends ChangeNotifier {
  List<Color> parts = [Colors.white, Colors.white, Colors.white];
  Color _selectedColor = Colors.red;

  Color get selectedColor => _selectedColor;
  set selectedColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  void fillPart(int partIndex) {
    parts[partIndex] = selectedColor;
    notifyListeners();

    if (parts.every((part) => part != Colors.white)) {
      _isCompleted = true;
      notifyListeners();
    }
  }

  bool _isCompleted = false;
  bool get isCompleted => _isCompleted;

  int get score => parts.where((part) => part != Colors.white).length;
}


