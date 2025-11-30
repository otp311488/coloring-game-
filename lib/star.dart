import 'package:coloring_game/ticket.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => StarColorProvider(),
      child: MaterialApp(
        home: StarPage(),
      ),
    ),
  );
}

class StarPage extends StatefulWidget {
  @override
  _StarPageState createState() => _StarPageState();
}

class _StarPageState extends State<StarPage> {
  bool _showAnimation = false;

  @override
  void initState() {
    super.initState();
    Provider.of<StarColorProvider>(context, listen: false).addListener(_onColorProviderChange);
  }

  void _onColorProviderChange() {
    if (Provider.of<StarColorProvider>(context, listen: false).isCompleted) {
      setState(() {
        _showAnimation = true;
      });

      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          _showAnimation = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TicketPage()),
        );
      });
    }
  }

  @override
  void dispose() {
    Provider.of<StarColorProvider>(context, listen: false).removeListener(_onColorProviderChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Untitled design (17).png'),
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
                  Consumer<StarColorProvider>(
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
                    Consumer<StarColorProvider>(
                      builder: (context, provider, child) {
                        return GestureDetector(
                          onTapDown: (details) {
                            _handleTap(details.localPosition, provider, context);
                          },
                          child: SizedBox(
                            width: 300,
                            height: 300,
                            child: CustomPaint(
                              painter: StarPainter(provider),
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
                        'S=Star',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
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
                  Expanded(child: ColorPalette()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(Offset position, StarColorProvider provider, BuildContext context) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset localPosition = renderBox.globalToLocal(position);

    double starRadius = 150; // Adjusted for big star
    Offset starCenter = Offset(150, 150); // Center of the big star

    if (_isPointWithinStar(localPosition, starCenter, starRadius)) {
      provider.fillStar();
      setState(() {});
    }
  }

  bool _isPointWithinStar(Offset point, Offset starCenter, double starRadius) {
    double dx = point.dx - starCenter.dx;
    double dy = point.dy - starCenter.dy;

    double distance = sqrt(dx * dx + dy * dy);

    return distance < starRadius;
  }
}

class StarPainter extends CustomPainter {
  final StarColorProvider colorProvider;

  StarPainter(this.colorProvider);

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

    final double outerRadius = size.width / 2;
    final double innerRadius = outerRadius / 2.5;

    Offset center = Offset(size.width / 2, size.height / 2);

    final List<Offset> starPoints = [];
    final double angleIncrement = 2 * pi / 5;

    for (int j = 0; j < 5; j++) {
      double outerAngle = j * angleIncrement;
      double innerAngle = outerAngle + angleIncrement / 2;

      starPoints.add(Offset(
        center.dx + outerRadius * cos(outerAngle),
        center.dy + outerRadius * sin(outerAngle),
      ));
      starPoints.add(Offset(
        center.dx + innerRadius * cos(innerAngle),
        center.dy + innerRadius * sin(innerAngle),
      ));
    }

    paint.color = colorProvider.starColor;
    Path path = Path()..moveTo(starPoints[0].dx, starPoints[0].dy);

    for (int j = 1; j < starPoints.length; j++) {
      path.lineTo(starPoints[j].dx, starPoints[j].dy);
    }
    path.close();

    canvas.drawPath(path, paint);
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
    final selectedColor = Provider.of<StarColorProvider>(context).selectedColor;

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
              Provider.of<StarColorProvider>(context, listen: false).selectedColor = color;
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

class StarColorProvider extends ChangeNotifier {
  Color _starColor = Colors.white;
  Color _selectedColor = Colors.red;
  bool _isCompleted = false;

  Color get selectedColor => _selectedColor;

  set selectedColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  Color get starColor => _starColor;

  bool get isCompleted => _isCompleted;

  int get score => _starColor != Colors.white ? 1 : 0;

  void fillStar() {
    if (_starColor == Colors.white && !_isColorUsed(selectedColor)) {
      _starColor = selectedColor;
      if (_starColor != Colors.white) {
        _isCompleted = true;
      }
      notifyListeners();
    }
  }

  bool _isColorUsed(Color color) {
    return _starColor == color;
  }
}

