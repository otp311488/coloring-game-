import 'package:coloring_game/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ZigzagColorProvider(),
      child: MaterialApp(
        home: ZigzagPage(),
      ),
    ),
  );
}

class ZigzagPage extends StatefulWidget {
  @override
  _ZigzagPageState createState() => _ZigzagPageState();
}

class _ZigzagPageState extends State<ZigzagPage> {
  bool _showAnimation = false;

  @override
  void initState() {
    super.initState();
    Provider.of<ZigzagColorProvider>(context, listen: false).addListener(_onColorProviderChange);
  }

  void _onColorProviderChange() {
    if (Provider.of<ZigzagColorProvider>(context, listen: false).isCompleted) {
      setState(() {
        _showAnimation = true;
      });

      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          _showAnimation = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NextPage()),
        );
      });
    }
  }

  @override
  void dispose() {
    Provider.of<ZigzagColorProvider>(context, listen: false).removeListener(_onColorProviderChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Untitled design (24).png'), // Your background image
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
                    'Zigzag Coloring',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(offset: Offset(2, 2), blurRadius: 5, color: Colors.black54),
                      ],
                    ),
                  ),
                  Consumer<ZigzagColorProvider>(
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
                    Consumer<ZigzagColorProvider>(
                      builder: (context, provider, child) {
                        return GestureDetector(
                          onTapDown: (details) {
                            _handleTap(details.localPosition, provider, context);
                          },
                          child: SizedBox(
                            width: 300,
                            height: 400, // Adjust size for the zigzag
                            child: CustomPaint(
                              painter: ZigzagPainter(provider),
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
                        ' Zigzag',
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

  void _handleTap(Offset position, ZigzagColorProvider provider, BuildContext context) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset localPosition = renderBox.globalToLocal(position);

    double canvasWidth = 100;
    double canvasHeight = 150; // Adjust height for the zigzag

    int section = _getZigzagSection(localPosition, canvasWidth, canvasHeight);
    if (section != -1) {
      provider.fillSection(section);
    }
  }

  int _getZigzagSection(Offset point, double width, double height) {
    // Assuming zigzag sections are divided vertically into equal parts
    double sectionHeight = height / 5; // Divide into 5 sections
    for (int i = 0; i < 5; i++) {
      if (point.dy >= i * sectionHeight && point.dy < (i + 1) * sectionHeight) {
        return i;
      }
    }
    return -1; // If point is outside of zigzag
  }
}

class ZigzagPainter extends CustomPainter {
  final ZigzagColorProvider colorProvider;

  ZigzagPainter(this.colorProvider);

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    _drawZigzag(canvas, width, height);
  }

  void _drawZigzag(Canvas canvas, double width, double height) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Draw zigzag
    double sectionHeight = height / 5;
    for (int i = 0; i < 5; i++) {
      Path zigzagPath = Path();
      zigzagPath.moveTo(0, i * sectionHeight);
      zigzagPath.lineTo(width / 2, (i + 1) * sectionHeight);
      zigzagPath.lineTo(width, i * sectionHeight);
      zigzagPath.lineTo(width / 2, (i - 1) * sectionHeight);
      zigzagPath.close();

      paint.color = colorProvider.getColorForSection(i);
      canvas.drawPath(zigzagPath, paint);
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
    final selectedColor = Provider.of<ZigzagColorProvider>(context).selectedColor;

    final List<Color> colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.yellow,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: colors.map((color) {
          return GestureDetector(
            onTap: () {
              Provider.of<ZigzagColorProvider>(context, listen: false).selectedColor = color;
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

class ZigzagColorProvider extends ChangeNotifier {
  List<Color> _sectionColors = List.filled(5, Colors.white); // 5 sections
  Color _selectedColor = Colors.red; // Default selected color
  bool _isCompleted = false;

  Color get selectedColor => _selectedColor;

  set selectedColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  bool get isCompleted => _isCompleted;

  int get score => _sectionColors.where((color) => color != Colors.white).length;

  void fillSection(int sectionIndex) {
    if (sectionIndex >= 0 && sectionIndex < _sectionColors.length) {
      _sectionColors[sectionIndex] = _selectedColor;
      notifyListeners();
      _checkCompletion();
    }
  }

  void _checkCompletion() {
    _isCompleted = _sectionColors.every((color) => color != Colors.white);
    notifyListeners();
  }

  Color getColorForSection(int index) {
    return _sectionColors[index];
  }
}


class NextPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pink, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Congratulations!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 4,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'You have completed the game.',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 3,
                          color: Colors.black38,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => MainPage(musicService: Provider.of<MusicService>(context, listen: false))),
                        (Route<dynamic> route) => false, // Remove all previous routes
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      elevation: 5,
                    ),
                    child: Text(
                      'Go Back',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.pink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
