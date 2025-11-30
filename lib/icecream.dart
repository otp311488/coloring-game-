import 'package:coloring_game/jelly.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => IceCreamColorProvider(),
      child: MaterialApp(
        home: IceCreamPage(),
      ),
    ),
  );
}

class IceCreamPage extends StatefulWidget {
  @override
  _IceCreamPageState createState() => _IceCreamPageState();
}

class _IceCreamPageState extends State<IceCreamPage> {
  bool _showAnimation = false;
  bool _disableFilling = false;

  @override
  void initState() {
    super.initState();
    Provider.of<IceCreamColorProvider>(context, listen: false)
        .addListener(_onColorProviderChange);
  }

  void _onColorProviderChange() {
    if (Provider.of<IceCreamColorProvider>(context, listen: false).score == 4) {
      setState(() {
        _showAnimation = true;
        _disableFilling = true; // Disable further filling
      });

      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          _showAnimation = false;
        });

        // Navigate to the next page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => JugPage()), // Replace with your next page
        );
      });
    }
  }

  @override
  void dispose() {
    Provider.of<IceCreamColorProvider>(context, listen: false)
        .removeListener(_onColorProviderChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Untitled design (2).png'),
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
                  Consumer<IceCreamColorProvider>(
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
                      top: 100,
                      right: 75,
                      child: Column(
                        children: [
                          Text(
                            'I',
                            style: TextStyle(
                              fontSize: 49,
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
                            '= ice cream',
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
                        ],
                      ),
                    ),
                    Consumer<IceCreamColorProvider>(
                      builder: (context, provider, child) {
                        return GestureDetector(
                          onTapDown: _disableFilling
                              ? null
                              : (details) {
                                  final topScoopRect = Rect.fromCircle(
                                    center: Offset(150, 75),
                                    radius: 75,
                                  );
                                  final middleScoopRect = Rect.fromCircle(
                                    center: Offset(150, 150),
                                    radius: 75,
                                  );
                                  final bottomScoopRect = Rect.fromCircle(
                                    center: Offset(150, 225),
                                    radius: 75,
                                  );
                                  final coneRect = Rect.fromLTRB(
                                    0,
                                    225,
                                    300,
                                    300,
                                  );

                                  int partIndex;
                                  if (topScoopRect.contains(details.localPosition)) {
                                    partIndex = 0; // Top scoop
                                  } else if (middleScoopRect.contains(details.localPosition)) {
                                    partIndex = 1; // Middle scoop
                                  } else if (bottomScoopRect.contains(details.localPosition)) {
                                    partIndex = 2; // Bottom scoop
                                  } else if (coneRect.contains(details.localPosition)) {
                                    partIndex = 3; // Cone
                                  } else {
                                    partIndex = 4; // Background (not used)
                                  }

                                  provider.fillPart(partIndex);
                                },
                          child: CustomPaint(
                            painter: IceCreamPainter(provider),
                            child: Container(
                              width: 300,
                              height: 300,
                            ),
                          ),
                        );
                      },
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

class IceCreamPainter extends CustomPainter {
  final IceCreamColorProvider colorProvider;

  IceCreamPainter(this.colorProvider);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final Paint strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white // Set stroke color to white
      ..strokeWidth = 2
      ..isAntiAlias = true;

    // Define the path for the ice cream shape (cone and scoops)
    final conePath = Path();
    conePath.moveTo(size.width / 2, size.height);
    conePath.lineTo(size.width, size.height * 0.75);
    conePath.lineTo(0, size.height * 0.75);
    conePath.close();

    final topScoopPath = Path();
    topScoopPath.addOval(Rect.fromCircle(
      center: Offset(size.width / 2, size.height * 0.25),
      radius: size.width * 0.25,
    ));

    final middleScoopPath = Path();
    middleScoopPath.addOval(Rect.fromCircle(
      center: Offset(size.width / 2, size.height * 0.5),
      radius: size.width * 0.25,
    ));

    final bottomScoopPath = Path();
    bottomScoopPath.addOval(Rect.fromCircle(
      center: Offset(size.width / 2, size.height * 0.75),
      radius: size.width * 0.25,
    ));

    // Draw the ice cream scoops
    fillPaint.color = colorProvider.getPartColor(0) ?? Colors.white;
    canvas.drawPath(topScoopPath, fillPaint);
    canvas.drawPath(topScoopPath, strokePaint); // White outline for the top scoop

    fillPaint.color = colorProvider.getPartColor(1) ?? Colors.white;
    canvas.drawPath(middleScoopPath, fillPaint);
    canvas.drawPath(middleScoopPath, strokePaint); // White outline for the middle scoop

    fillPaint.color = colorProvider.getPartColor(2) ?? Colors.white;
    canvas.drawPath(bottomScoopPath, fillPaint);
    canvas.drawPath(bottomScoopPath, strokePaint); // White outline for the bottom scoop

    // Draw the cone
    fillPaint.color = colorProvider.getPartColor(3) ?? Colors.white;
    canvas.drawPath(conePath, fillPaint);
    canvas.drawPath(conePath, strokePaint); // White outline for the cone

    // Draw text on the shape
    final textSpan = TextSpan(
      text: 'I = ice cream',
      style: TextStyle(
        color: Colors.black87,
        fontSize: 26,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            offset: Offset(2, 2),
            blurRadius: 3,
            color: Colors.grey,
          ),
        ],
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    textPainter.paint(
      canvas,
      Offset((size.width - textPainter.width) / 2,
          (size.height - textPainter.height) / 2),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class IceCreamColorProvider with ChangeNotifier {
  final List<Color?> _colors = List<Color?>.filled(4, null);
  Color? _selectedColor;
  int _score = 0;

  Color? get selectedColor => _selectedColor;
  int get score => _score;

  void selectColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  void fillPart(int partIndex) {
    if (_colors[partIndex] == null && _selectedColor != null) {
      _colors[partIndex] = _selectedColor;
      _score++;
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
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
    bool isSelected = Provider.of<IceCreamColorProvider>(context).selectedColor == color;
    return GestureDetector(
      onTap: () {
        Provider.of<IceCreamColorProvider>(context, listen: false).selectColor(color);
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
