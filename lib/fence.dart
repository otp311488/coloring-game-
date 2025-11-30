import 'package:coloring_game/grapes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => FenceColorProvider(),
      child: MaterialApp(
        home: FencePage(),
      ),
    ),
  );
}

class FencePage extends StatefulWidget {
  @override
  _FencePageState createState() => _FencePageState();
}

class _FencePageState extends State<FencePage> {
  bool _showAnimation = false;

  @override
  void initState() {
    super.initState();
    Provider.of<FenceColorProvider>(context, listen: false)
        .addListener(_onColorProviderChange);
  }

   void _onColorProviderChange() {
    if (Provider.of<FenceColorProvider>(context, listen: false).isFenceFilled) {
      setState(() {
        _showAnimation = true;
      });

      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          _showAnimation = false;
        });

        // Navigate to GrapesPage after the animation is shown
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GlovePage()),
        );
      });
    }
  }

  @override
  void dispose() {
    Provider.of<FenceColorProvider>(context, listen: false)
        .removeListener(_onColorProviderChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/7a0da11c-bec1-4359-96fe-041e47f5230d.jpg',
            ),
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
                  Consumer<FenceColorProvider>(
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
                      right: 12,
                      child: Column(
                        children: [
                          Text(
                            'F',
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
                            '= Fence',
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
                      onTapUp: (details) {
                        // Handle tap on the fence
                        final RenderBox renderBox = context.findRenderObject() as RenderBox;
                        final localPosition = renderBox.globalToLocal(details.globalPosition);
                        final partIndex = (localPosition.dx / (renderBox.size.width / 5)).floor();
                        if (partIndex >= 0 && partIndex < 5) {
                          Provider.of<FenceColorProvider>(context, listen: false)
                              .setColorPart(Provider.of<FenceColorProvider>(context, listen: false).selectedColor, partIndex);
                        }
                      },
                      child: CustomPaint(
                        painter: FenceShapePainter(context.read<FenceColorProvider>()),
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

class FenceShapePainter extends CustomPainter {
  final FenceColorProvider colorProvider;

  FenceShapePainter(this.colorProvider);

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

    // Draw the fence parts
    for (int i = 0; i < 5; i++) {
      final selectedColor = colorProvider.getColorPart(i);
      if (selectedColor != null) {
        fillPaint.color = selectedColor;
        canvas.drawPath(_getFencePartPath(size, i), fillPaint);
      }
      canvas.drawPath(_getFencePartPath(size, i), strokePaint);
    }
  }

  Path _getFencePartPath(Size size, int partIndex) {
    final Path fencePath = Path();
    final double partWidth = size.width / 5; // Assuming 5 parts
    final double partHeight = size.height;

    fencePath.moveTo(partIndex * partWidth, partHeight);
    fencePath.lineTo((partIndex + 0.1) * partWidth, partHeight * 0.8);
    fencePath.lineTo((partIndex + 0.2) * partWidth, partHeight);
    fencePath.lineTo((partIndex + 0.3) * partWidth, partHeight * 0.8);
    fencePath.lineTo((partIndex + 0.4) * partWidth, partHeight);
    fencePath.lineTo((partIndex + 0.5) * partWidth, partHeight * 0.8);
    fencePath.lineTo((partIndex + 0.6) * partWidth, partHeight);
    fencePath.lineTo((partIndex + 0.7) * partWidth, partHeight * 0.8);
    fencePath.lineTo((partIndex + 0.8) * partWidth, partHeight);
    fencePath.lineTo((partIndex + 0.9) * partWidth, partHeight * 0.8);
    fencePath.lineTo((partIndex + 1.0) * partWidth, partHeight);

    return fencePath;
  }

  @override
  bool shouldRepaint(FenceShapePainter oldDelegate) => true;
}

class ColorPalette extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ColorButtons(color: Colors.red),
        ColorButtons(color: Colors.green),
        ColorButtons(color: Colors.blue),
        ColorButtons(color: Colors.yellow),
        ColorButtons(color: Colors.orange),
      ],
    );
  }
}

class ColorButtons extends StatelessWidget {
  final Color color;

  ColorButtons({required this.color});

  @override
  Widget build(BuildContext context) {
    return Consumer<FenceColorProvider>(
      builder: (context, provider, child) {
        final isSelected = provider.selectedColor == color;

        return GestureDetector(
          onTap: () {
            provider.selectedColor = color; // Set the selected color
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
      },
    );
  }
}

class FenceColorProvider with ChangeNotifier {
  List<Color?> _colors = List.filled(5, null); // 5 parts of the fence
  Color _selectedColor = Colors.red; // Default selected color
  int _score = 0;

  int get score => _score;

  Color get selectedColor => _selectedColor;

  set selectedColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  bool get isFenceFilled => _colors.every((color) => color != null);

  void setColorPart(Color color, int partIndex) {
    if (_colors[partIndex] == null) { // Only color uncolored parts
      _colors[partIndex] = color;
      notifyListeners();
      if (isFenceFilled) {
        _score += 5; // Add 5 points when all parts are filled
        notifyListeners();
      }
    }
  }

  Color? getColorPart(int partIndex) {
    return _colors[partIndex];
  }
}
