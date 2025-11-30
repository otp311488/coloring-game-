import 'package:coloring_game/xmastree.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => WandColorProvider(),
      child: MaterialApp(
        home: WandPage(),
      ),
    ),
  );
}

class WandPage extends StatefulWidget {
  @override
  _WandPageState createState() => _WandPageState();
}

class _WandPageState extends State<WandPage> {
  bool _showAnimation = false;

  @override
  void initState() {
    super.initState();
    Provider.of<WandColorProvider>(context, listen: false).addListener(_onColorProviderChange);
  }

  void _onColorProviderChange() {
    if (Provider.of<WandColorProvider>(context, listen: false).isCompleted) {
      setState(() {
        _showAnimation = true;
      });

      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          _showAnimation = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TreePage()),
        );
      });
    }
  }

  @override
  void dispose() {
    Provider.of<WandColorProvider>(context, listen: false).removeListener(_onColorProviderChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Untitled design (22).png'),
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
                  Consumer<WandColorProvider>(
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
                    Consumer<WandColorProvider>(
                      builder: (context, provider, child) {
                        return GestureDetector(
                          onTapDown: (details) {
                            _handleTap(details.localPosition, provider, context);
                          },
                          child: SizedBox(
                            width: 300,
                            height: 400, // Increased height for a taller wand
                            child: CustomPaint(
                              painter: WandPainter(provider),
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
                        'Wand',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
              child: ColorPalette(), // ColorPalette widget
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(Offset position, WandColorProvider provider, BuildContext context) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset localPosition = renderBox.globalToLocal(position);

    double canvasWidth = 300;
    double canvasHeight = 400; // Match the new canvas height

    if (_isPointWithinWand(localPosition, canvasWidth, canvasHeight)) {
      provider.fillWand();
    }
  }

  bool _isPointWithinWand(Offset point, double width, double height) {
    double tolerance = 20.0; // Tolerance for detecting clicks near the line

    Path wandPath = Path();
    wandPath.moveTo(width / 2, height / 4);
    wandPath.cubicTo(width / 2 - 20, height / 2, width / 2 + 20, height / 2, width / 2, 3 * height / 4);
    wandPath.cubicTo(width / 2 - 20, height - 40, width / 2 + 20, height - 40, width / 2, height);
    wandPath.close();

    // Check if the point is within the tolerance distance from the path
    return wandPath.contains(point);
  }
}

class WandPainter extends CustomPainter {
  final WandColorProvider colorProvider;

  WandPainter(this.colorProvider);

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // Draw the simple, curly wand
    _drawCurlyWand(canvas, width, height);
  }

  void _drawCurlyWand(Canvas canvas, double width, double height) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..isAntiAlias = true;

    // Draw the wand body (curved)
    Path wandPath = Path();
    wandPath.moveTo(width / 2, height / 4);
    wandPath.cubicTo(width / 2 - 20, height / 2, width / 2 + 20, height / 2, width / 2, 3 * height / 4);

    paint.color = colorProvider.wandColor1;
    canvas.drawPath(wandPath, paint);

    // Draw the wand tip (also curved)
    Path wandTipPath = Path();
    wandTipPath.moveTo(width / 2, 3 * height / 4);
    wandTipPath.cubicTo(width / 2 - 20, height - 40, width / 2 + 20, height - 40, width / 2, height);

    paint.color = colorProvider.wandColor2;
    canvas.drawPath(wandTipPath, paint);

    // Draw the wand handle
    Path handlePath = Path();
    handlePath.moveTo(width / 2, 0);
    handlePath.lineTo(width / 2, height / 4);

    paint.color = Colors.brown; // Example handle color
    paint.strokeWidth = 12.0;
    canvas.drawPath(handlePath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ColorPalette extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final selectedColor = Provider.of<WandColorProvider>(context).selectedColor;

    final List<Color> colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: colors.map((color) {
          return GestureDetector(
            onTap: () {
              Provider.of<WandColorProvider>(context, listen: false).selectedColor = color;
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

class WandColorProvider extends ChangeNotifier {
  Color _wandColor1 = Colors.grey;
  Color _wandColor2 = Colors.grey;
  Color _selectedColor = Colors.red; // Only one selected color
  bool _isCompleted = false;

  Color get selectedColor => _selectedColor;

  set selectedColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  Color get wandColor1 => _wandColor1;

  Color get wandColor2 => _wandColor2;

  bool get isCompleted => _isCompleted;

  int get score => (_wandColor1 != Colors.grey && _wandColor2 != Colors.grey) ? 1 : 0;

  void fillWand() {
    if (_wandColor1 == Colors.grey) {
      _wandColor1 = _selectedColor;
    } else if (_wandColor2 == Colors.grey) {
      _wandColor2 = _selectedColor;
    }

    if (_wandColor1 != Colors.grey && _wandColor2 != Colors.grey) {
      _isCompleted = true;
    }

    notifyListeners();
  }
}

