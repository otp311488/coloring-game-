import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'ladder.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => KiteColorProvider(),
      child: MaterialApp(
        home: KitePage(),
      ),
    ),
  );
}

class KitePage extends StatefulWidget {
  @override
  _KitePageState createState() => _KitePageState();
}

class _KitePageState extends State<KitePage> {
  bool _showAnimation = false;

  @override
  void initState() {
    super.initState();
    context.read<KiteColorProvider>().addListener(_onColorProviderChange);
  }

  void _onColorProviderChange() {
    if (context.read<KiteColorProvider>().score == 4) {
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
          MaterialPageRoute(builder: (context) => ladderPage()), // Ensure `LadderPage` is correctly imported
        );
      });
    }
  }

  @override
  void dispose() {
    context.read<KiteColorProvider>().removeListener(_onColorProviderChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Untitled design (6).png'),
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
                  Consumer<KiteColorProvider>(
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
                            'K',
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
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
                            '= Kite',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
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
                          Consumer<KiteColorProvider>(
                            builder: (context, provider, child) {
                              return GestureDetector(
                                onTapDown: (details) {
                                  _handleTap(details.localPosition, provider, context);
                                },
                                child: CustomPaint(
                                  painter: KitePainter(provider),
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

  void _handleTap(Offset position, KiteColorProvider provider, BuildContext context) {
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

class KitePainter extends CustomPainter {
  final KiteColorProvider colorProvider;

  KitePainter(this.colorProvider);

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

    final List<Path> kitePaths = [
      Path()
        ..moveTo(size.width / 2, 0)
        ..lineTo(size.width, size.height / 2)
        ..lineTo(size.width / 2, size.height / 2)
        ..close(),
      Path()
        ..moveTo(size.width / 2, 0)
        ..lineTo(size.width / 2, size.height / 2)
        ..lineTo(0, size.height / 2)
        ..close(),
      Path()
        ..moveTo(size.width / 2, size.height / 2)
        ..lineTo(size.width, size.height / 2)
        ..lineTo(size.width / 2, size.height)
        ..close(),
      Path()
        ..moveTo(size.width / 2, size.height / 2)
        ..lineTo(0, size.height / 2)
        ..lineTo(size.width / 2, size.height)
        ..close(),
    ];

    for (int i = 0; i < kitePaths.length; i++) {
      fillPaint.color = colorProvider.getPartColor(i) ?? Colors.white;
      canvas.drawPath(kitePaths[i], fillPaint);
      canvas.drawPath(kitePaths[i], strokePaint);
    }

    Paint stringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.red
      ..strokeWidth = 4
      ..isAntiAlias = true;
    Path stringPath = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(size.width / 2, size.height + 70);
    canvas.drawPath(stringPath, stringPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class KiteColorProvider with ChangeNotifier {
  final List<Color?> _colors = List<Color?>.filled(4, null);
  Color? _selectedColor;
  int _score = 0;
  bool _isColorSelected = false;

  Color? get selectedColor => _selectedColor;
  int get score => _score;
  bool get isColorSelected => _isColorSelected;

  void selectColor(Color color) {
    _selectedColor = color;
    _isColorSelected = true;
    notifyListeners();
  }

  void fillPart(int partIndex) {
    if (_colors[partIndex] == null && _selectedColor != null && _isColorSelected) {
      _colors[partIndex] = _selectedColor;
      _score++;
      _isColorSelected = false;
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
    Colors.yellow,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: colors.map((color) {
        return ColorButton(color: color);
      }).toList(),
    );
  }
}

class ColorButton extends StatelessWidget {
  final Color color;

  ColorButton({required this.color});

  @override
  Widget build(BuildContext context) {
    bool isSelected = Provider.of<KiteColorProvider>(context).selectedColor == color;
    return GestureDetector(
      onTap: () {
        Provider.of<KiteColorProvider>(context, listen: false).selectColor(color);
      },
      child: Container(
        width: isSelected ? 50 : 50,
        height: isSelected ? 50 : 50,
        margin: EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.white,
            width: isSelected ? 2 : 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
          ],
        ),
      ),
    );
  }
}
