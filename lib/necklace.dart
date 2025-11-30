import 'package:coloring_game/oar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => NecklaceColorProvider(),
      child: MaterialApp(
        home: NecklacePage(),
      ),
    ),
  );
}

class NecklacePage extends StatefulWidget {
  @override
  _NecklacePageState createState() => _NecklacePageState();
}

class _NecklacePageState extends State<NecklacePage> {
  bool _showAnimation = false;

  @override
  void initState() {
    super.initState();
    Provider.of<NecklaceColorProvider>(context, listen: false).addListener(_onColorProviderChange);
  }

  void _onColorProviderChange() {
    if (Provider.of<NecklaceColorProvider>(context, listen: false).isCompleted) {
      setState(() {
        _showAnimation = true;
      });

      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          _showAnimation = false;
        });

        
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OarPage()),
        );
      });
    }
  }

  @override
  void dispose() {
    Provider.of<NecklaceColorProvider>(context, listen: false).removeListener(_onColorProviderChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Untitled design (11).png'),
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
                  Consumer<NecklaceColorProvider>(
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
                      top: 30,
                      right: 46,
                      child: Column(
                        children: [
                          Text(
                            'N',
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
                            '= Necklace',
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
                    Consumer<NecklaceColorProvider>(
                      builder: (context, provider, child) {
                        return GestureDetector(
                          onTapDown: (details) {
                            _handleTap(details.localPosition, provider, context);
                          },
                          child: CustomPaint(
                            painter: NecklacePainter(provider),
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

  void _handleTap(Offset position, NecklaceColorProvider provider, BuildContext context) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;
    double dx = position.dx / size.width;
    double dy = position.dy / size.height;

    int beadIndex = -1;
    double beadRadius = 20;
    double centerX = size.width / 2;
    double centerY = size.height / 2;

    for (int i = 0; i < 12; i++) {
      double angle = (i / 12) * 2 * pi;
      double beadX = centerX + (size.width / 2 - beadRadius) * cos(angle);
      double beadY = centerY + (size.width / 2 - beadRadius) * sin(angle);

      Rect beadRect = Rect.fromCenter(center: Offset(beadX, beadY), width: beadRadius * 2, height: beadRadius * 2);
      if (beadRect.contains(position)) {
        beadIndex = i;
        break;
      }
    }

    if (beadIndex != -1) {
      provider.fillPart(beadIndex);
    }
  }
}

class NecklacePainter extends CustomPainter {
  final NecklaceColorProvider colorProvider;

  NecklacePainter(this.colorProvider);

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

    
    final Paint stringPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..isAntiAlias = true;

    double beadRadius = 20;
    double centerX = size.width / 2;
    double centerY = size.height / 2;

    Path stringPath = Path();
    for (int i = 0; i < 12; i++) {
      double angle = (i / 12) * 2 * pi;
      double beadX = centerX + (size.width / 2 - beadRadius) * cos(angle);
      double beadY = centerY + (size.width / 2 - beadRadius) * sin(angle);
      if (i == 0) {
        stringPath.moveTo(beadX, beadY);
      } else {
        stringPath.lineTo(beadX, beadY);
      }
    }
    stringPath.close();
    canvas.drawPath(stringPath, stringPaint);

    
    for (int i = 0; i < 12; i++) {
      double angle = (i / 12) * 2 * pi;
      double beadX = centerX + (size.width / 2 - beadRadius) * cos(angle);
      double beadY = centerY + (size.width / 2 - beadRadius) * sin(angle);
      
      Paint beadPaint = Paint()
        ..shader = RadialGradient(
          colors: [Colors.white, colorProvider.getColor(i) ?? Colors.grey],
          stops: [0.3, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(beadX, beadY), radius: beadRadius))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(beadX, beadY), beadRadius, beadPaint);
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildColorButton(context, Colors.red),
        _buildColorButton(context, Colors.green),
        _buildColorButton(context, Colors.blue),
        _buildColorButton(context, Colors.yellow),
        _buildColorButton(context, Colors.purple),
      ],
    );
  }

  Widget _buildColorButton(BuildContext context, Color color) {
    return GestureDetector(
      onTap: () {
        Provider.of<NecklaceColorProvider>(context, listen: false).setColor(color);
      },
      child: Consumer<NecklaceColorProvider>(
        builder: (context, provider, child) {
          bool isSelected = provider.selectedColor == color;
          return Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black45,
                        offset: Offset(2, 2),
                        blurRadius: 6,
                      ),
                    ]
                  : [],
            ),
            width: 40,
            height: 40,
          );
        },
      ),
    );
  }
}

class NecklaceColorProvider with ChangeNotifier {
  List<Color?> _parts = List<Color?>.filled(12, null);
  Color? _selectedColor;
  int _score = 0;
  bool _isCompleted = false;

  List<Color?> get parts => _parts;
  Color? get selectedColor => _selectedColor;
  int get score => _score;
  bool get isCompleted => _isCompleted;

  void setColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  Color? getColor(int index) {
    return _parts[index];
  }

  void fillPart(int index) {
    if (_parts[index] == null && _selectedColor != null) {
      _parts[index] = _selectedColor;
      _score += 10; 
      if (_parts.every((part) => part != null)) {
        _isCompleted = true;
      }
      notifyListeners();
    }
  }
}


