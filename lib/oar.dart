import 'package:coloring_game/pencil.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => OarColorProvider(),
      child: MaterialApp(
        home: OarPage(),
      ),
    ),
  );
}

class OarPage extends StatefulWidget {
  @override
  _OarPageState createState() => _OarPageState();
}

class _OarPageState extends State<OarPage> {
  bool _showAnimation = false;

  @override
  void initState() {
    super.initState();
    Provider.of<OarColorProvider>(context, listen: false).addListener(_onColorProviderChange);
  }

  void _onColorProviderChange() {
    if (Provider.of<OarColorProvider>(context, listen: false).isCompleted) {
      setState(() {
        _showAnimation = true;
      });

      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          _showAnimation = false;
        });

        
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PencilPage()),
        );
      });
    }
  }

  @override
  void dispose() {
    Provider.of<OarColorProvider>(context, listen: false).removeListener(_onColorProviderChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Untitled design (12).png'),
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
                  Consumer<OarColorProvider>(
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
                      top:195,
                      right: 0,
                      child: Column(
                        children: [
                          Text(
                            'O',
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
                            '= Oar',
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
                    Consumer<OarColorProvider>(
                      builder: (context, provider, child) {
                        return GestureDetector(
                          onTapDown: (details) {
                            _handleTap(details.localPosition, provider, context);
                          },
                          child: CustomPaint(
                            painter: OarPainter(provider),
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

  void _handleTap(Offset position, OarColorProvider provider, BuildContext context) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;
    double dx = position.dx / size.width;
    double dy = position.dy / size.height;

    int partIndex = -1;
    double partWidth = size.width / 3;
    double partHeight = size.height / 3;

    List<Rect> parts = [
      Rect.fromLTWH(partWidth / 2, partHeight / 4, partWidth, partHeight / 2),
      Rect.fromLTWH(partWidth / 2, partHeight, partWidth, partHeight), 
      Rect.fromLTWH(partWidth * 2, partHeight / 4, partWidth, partHeight / 2), 
      Rect.fromLTWH(partWidth * 2, partHeight, partWidth, partHeight), 
    ];

    for (int i = 0; i < parts.length; i++) {
      if (parts[i].contains(position)) {
        partIndex = i;
        break;
      }
    }

    if (partIndex != -1) {
      provider.fillPart(partIndex);
    }
  }
}

class OarPainter extends CustomPainter {
  final OarColorProvider colorProvider;

  OarPainter(this.colorProvider);

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

    // Draw Oar 1
    final Rect oar1Top = Rect.fromLTWH(size.width / 3, size.height / 8, size.width / 6, size.height / 8);
    final Rect oar1Handle = Rect.fromLTWH(size.width / 3, size.height / 4, size.width / 6, size.height / 2);

    _drawOarPart(canvas, oar1Top, 0, fillPaint, strokePaint);
    _drawOarPart(canvas, oar1Handle, 1, fillPaint, strokePaint);

    // Draw Oar 2
    final Rect oar2Top = Rect.fromLTWH(size.width * 2 / 3, size.height / 8, size.width / 6, size.height / 8);
    final Rect oar2Handle = Rect.fromLTWH(size.width * 2 / 3, size.height / 4, size.width / 6, size.height / 2);

    _drawOarPart(canvas, oar2Top, 2, fillPaint, strokePaint);
    _drawOarPart(canvas, oar2Handle, 3, fillPaint, strokePaint);
  }

  void _drawOarPart(Canvas canvas, Rect rect, int partIndex, Paint fillPaint, Paint strokePaint) {
    fillPaint.color = colorProvider.parts[partIndex];
    canvas.drawRect(rect, fillPaint);
    canvas.drawRect(rect, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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
    final isSelected = Provider.of<OarColorProvider>(context).selectedColor == color;

    return GestureDetector(
      onTap: () {
        Provider.of<OarColorProvider>(context, listen: false).setColor(color);
      },
      child: Container(
        width: 50,
        height: 50,
        margin: EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
          boxShadow: [
            BoxShadow(
              offset: Offset(2, 2),
              blurRadius: 3,
              color: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}

class OarColorProvider extends ChangeNotifier {
  Color selectedColor = Colors.red;
  List<Color> parts = List.filled(4, Colors.white);

  void setColor(Color color) {
    selectedColor = color;
    notifyListeners();
  }

  void fillPart(int partIndex) {
    parts[partIndex] = selectedColor;
    notifyListeners();
  }

  int get score => parts.where((color) => color != Colors.white).length * 10;

  bool get isCompleted => parts.every((color) => color != Colors.white);
}


