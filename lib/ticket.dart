import 'package:coloring_game/uranus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => TicketColorProvider(),
      child: MaterialApp(
        home: TicketPage(),
      ),
    ),
  );
}

class TicketPage extends StatefulWidget {
  @override
  _TicketPageState createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  bool _showAnimation = false;

  @override
  void initState() {
    super.initState();
    Provider.of<TicketColorProvider>(context, listen: false).addListener(_onColorProviderChange);
  }

  void _onColorProviderChange() {
    if (Provider.of<TicketColorProvider>(context, listen: false).isCompleted) {
      setState(() {
        _showAnimation = true;
      });

      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          _showAnimation = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UranusPage()),
        );
      });
    }
  }

  @override
  void dispose() {
    Provider.of<TicketColorProvider>(context, listen: false).removeListener(_onColorProviderChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Untitled design (18).png'),
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
                  Consumer<TicketColorProvider>(
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
                    Consumer<TicketColorProvider>(
                      builder: (context, provider, child) {
                        return GestureDetector(
                          onTapDown: (details) {
                            _handleTap(details.localPosition, provider, context);
                          },
                          child: SizedBox(
                            width: 300,
                            height: 300,
                            child: CustomPaint(
                              painter: TicketPainter(provider),
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
                        'T=Ticket',
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

  void _handleTap(Offset position, TicketColorProvider provider, BuildContext context) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset localPosition = renderBox.globalToLocal(position);

    double ticketWidth = 300;
    double ticketHeight = 300;

    if (_isPointWithinTicket(localPosition, ticketWidth, ticketHeight)) {
      provider.fillTicket();
      setState(() {});
    }
  }

  bool _isPointWithinTicket(Offset point, double width, double height) {
    return point.dx >= 0 && point.dx <= width && point.dy >= 0 && point.dy <= height;
  }
}

class TicketPainter extends CustomPainter {
  final TicketColorProvider colorProvider;

  TicketPainter(this.colorProvider);

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

    final double width = size.width;
    final double height = size.height;
    final double curveHeight = 30;

    paint.color = colorProvider.ticketColor;

    Path path = Path()
      ..moveTo(0, curveHeight)
      ..quadraticBezierTo(width / 4, 0, width / 2, curveHeight)
      ..quadraticBezierTo(3 * width / 4, 2 * curveHeight, width, curveHeight)
      ..lineTo(width, height - curveHeight)
      ..quadraticBezierTo(3 * width / 4, height, width / 2, height - curveHeight)
      ..quadraticBezierTo(width / 4, height - 2 * curveHeight, 0, height - curveHeight)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, strokePaint);

    _drawStars(canvas, width, height);
  }

  void _drawStars(Canvas canvas, double width, double height) {
    final double starRadius = 10;
    final double starSpacing = 15;
    final Paint starPaint = Paint()..color = Colors.black;

    for (int i = 0; i < 3; i++) {
      double cx = width / 2 + (i - 1) * (2 * starRadius + starSpacing);
      double cy = height - 50;

      Path starPath = Path();
      for (int j = 0; j < 5; j++) {
        double angle = (j * 72) * (3.14159265358979323846 / 180);
        double dx = starRadius * cos(angle);
        double dy = starRadius * sin(angle);
        starPath.lineTo(cx + dx, cy + dy);
      }
      starPath.close();
      canvas.drawPath(starPath, starPaint);
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
    final selectedColor = Provider.of<TicketColorProvider>(context).selectedColor;

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
              Provider.of<TicketColorProvider>(context, listen: false).selectedColor = color;
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

class TicketColorProvider extends ChangeNotifier {
  Color _ticketColor = Colors.white;
  Color _selectedColor = Colors.red;
  bool _isCompleted = false;

  Color get selectedColor => _selectedColor;

  set selectedColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  Color get ticketColor => _ticketColor;

  bool get isCompleted => _isCompleted;

  int get score => _ticketColor != Colors.white ? 1 : 0;

  void fillTicket() {
    if (_ticketColor == Colors.white && !_isColorUsed(selectedColor)) {
      _ticketColor = selectedColor;
      if (_ticketColor != Colors.white) {
        _isCompleted = true;
      }
      notifyListeners();
    }
  }

  bool _isColorUsed(Color color) {
    return _ticketColor == color;
  }
}


