import 'package:coloring_game/kite.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => JugColorProvider(),
      child: MaterialApp(
        home: JugPage(),
      ),
    ),
  );
}

class JugPage extends StatefulWidget {
  @override
  _JugPageState createState() => _JugPageState();
}

class _JugPageState extends State<JugPage> {
  bool _showAnimation = false;

  @override
  void initState() {
    super.initState();
    Provider.of<JugColorProvider>(context, listen: false).addListener(_onColorProviderChange);
  }

  void _onColorProviderChange() {
  if (Provider.of<JugColorProvider>(context, listen: false).score == 4) {
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
        MaterialPageRoute(builder: (context) => KitePage()),
      );
    });
  }
}


  @override
  void dispose() {
    Provider.of<JugColorProvider>(context, listen: false).removeListener(_onColorProviderChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Untitled design (5).png'),
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
                  Consumer<JugColorProvider>(
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
                      top: 206,
                      right: 0,
                      child: Column(
                        children: [
                          Text(
                            'J',
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
                            '= jelly beans',
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
                    Consumer<JugColorProvider>(
                      builder: (context, provider, child) {
                        return Stack(
                          children: List.generate(
                            4,
                            (index) {
                              double beanWidth = 30;
                              double beanHeight = 50;
                              double randomLeft = 100 + index * 20 + index * 10;
                              double randomTop = 100 + index * 10 + index * 20;

                              return Positioned(
                                left: randomLeft,
                                top: randomTop,
                                child: GestureDetector(
                                  onTap: () {
                                    provider.fillPart(index);
                                  },
                                  child: CustomPaint(
                                    painter: JugPainter(provider, index),
                                    child: Container(
                                      width: beanWidth,
                                      height: beanHeight,
                                    ),
                                  ),
                                ),
                              );
                            },
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
                      color: Colors.white,
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
}

class JugPainter extends CustomPainter {
  final JugColorProvider colorProvider;
  final int index;

  JugPainter(this.colorProvider, this.index);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final Paint strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white
      ..strokeWidth = 2
      ..isAntiAlias = true;

    fillPaint.color = colorProvider.getPartColor(index) ?? Colors.white; // Default color for jelly bean
    canvas.drawOval(Rect.fromLTWH(0, 0, size.width, size.height), fillPaint);
    canvas.drawOval(Rect.fromLTWH(0, 0, size.width, size.height), strokePaint); // White outline for jelly bean
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class JugColorProvider with ChangeNotifier {
  final List<Color?> _colors = List<Color?>.filled(4, null); // 4 jelly beans
  Color? _selectedColor;
  int _score = 0;
  bool _isColorSelected = false; // Track if a color is selected

  Color? get selectedColor => _selectedColor;
  int get score => _score;
  bool get isColorSelected => _isColorSelected; // Getter for color selection state

  void selectColor(Color color) {
    _selectedColor = color;
    _isColorSelected = true; // Set color selected state to true
    notifyListeners();
  }

  void fillPart(int partIndex) {
    if (_colors[partIndex] == null && _selectedColor != null && _isColorSelected) {
      _colors[partIndex] = _selectedColor;
      _score++;
      _isColorSelected = false; // Reset color selection state
      notifyListeners();
    }
  }

  Color? getPartColor(int partIndex) {
    return _colors[partIndex];
  }
}

class ColorPalette extends StatelessWidget {
  final List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.orange,
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<JugColorProvider>(
      builder: (context, provider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: colors.map((color) {
            bool isSelected = provider.selectedColor == color;
            return GestureDetector(
              onTap: () {
                provider.selectColor(color);
              },
              child: Container(
                width: 50,
                height: 50,
                margin: EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isSelected ? Colors.black : Colors.transparent, width: 2),
                ),
                child: isSelected ? Icon(Icons.check, color: Colors.white) : null,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
