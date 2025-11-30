import 'package:coloring_game/cloudy_provider.dart';
import 'package:coloring_game/dish.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import 'package:lottie/lottie.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CakeColorProvider(),
      child: MaterialApp(
        home: CloudPage(),
      ),
    ),
  );
}

class CloudPage extends StatefulWidget {
  @override
  _CloudPageState createState() => _CloudPageState();
}

class _CloudPageState extends State<CloudPage> {
  bool _showAnimation = false;

  @override
  void initState() {
    super.initState();
    // Listen to CakeColorProvider changes
    Provider.of<CakeColorProvider>(context, listen: false).addListener(_onColorProviderChange);
  }

  void _onColorProviderChange() {
    if (Provider.of<CakeColorProvider>(context, listen: false).score == 30) {
      setState(() {
        _showAnimation = true;
      });

      // Hide the animation after 3 seconds and navigate to DoorPage
      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          _showAnimation = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DoorPage()),
        );
      });
    }
  }

  @override
  void dispose() {
    Provider.of<CakeColorProvider>(context, listen: false).removeListener(_onColorProviderChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/cloud.jpeg'), // Background image
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
                  Consumer<CakeColorProvider>(
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
                      top: 200,
                      left: 3,
                      child: Column(
                        children: [
                          Text(
                            'C',
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
                            '= Cloud',
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
                    Consumer<CakeColorProvider>(
                      builder: (context, provider, child) {
                        return GestureDetector(
                          onTapDown: (details) {
                            final center = Offset(150, 150);
                            final dx = details.localPosition.dx - center.dx;
                            final dy = details.localPosition.dy - center.dy;
                            final angle = (dx != 0 || dy != 0)
                                ? (atan2(dy, dx) + pi) % (2 * pi)
                                : 0;

                            int partIndex;
                            if (angle < pi / 3) {
                              partIndex = 0; // Top
                            } else if (angle < 2 * pi / 3) {
                              partIndex = 1; // Top-Right
                            } else if (angle < pi) {
                              partIndex = 2; // Right
                            } else if (angle < 4 * pi / 3) {
                              partIndex = 3; // Bottom-Right
                            } else if (angle < 5 * pi / 3) {
                              partIndex = 4; // Bottom
                            } else {
                              partIndex = 5; // Bottom-Left
                            }

                            provider.fillCircle(partIndex);
                          },
                          child: CustomPaint(
                            painter: CloudShapePainter(provider),
                            child: Container(
                              width: 300,
                              height: 300,
                            ),
                          ),
                        );
                      },
                    ),
                    if (_showAnimation) // Show Lottie animation
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

class CloudShapePainter extends CustomPainter {
  final CakeColorProvider colorProvider;

  CloudShapePainter(this.colorProvider);

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

    final center = Offset(size.width * 0.5, size.height * 0.5);
    final radius = size.width * 0.4;

    // Draw the cloud parts
    for (int i = 0; i < 6; i++) {
      fillPaint.color = colorProvider.getColorPart(i) ?? Colors.white;
      final path = Path();

      // Create different circular paths for each part of the cloud
      if (i == 0) {
        path.addOval(Rect.fromCircle(center: Offset(center.dx, center.dy - 30), radius: radius * 0.4));
      } else if (i == 1) {
        path.addOval(Rect.fromCircle(center: Offset(center.dx + 30, center.dy - 10), radius: radius * 0.4));
      } else if (i == 2) {
        path.addOval(Rect.fromCircle(center: Offset(center.dx + 30, center.dy + 30), radius: radius * 0.4));
      } else if (i == 3) {
        path.addOval(Rect.fromCircle(center: Offset(center.dx, center.dy + 60), radius: radius * 0.4));
      } else if (i == 4) {
        path.addOval(Rect.fromCircle(center: Offset(center.dx - 30, center.dy + 30), radius: radius * 0.4));
      } else if (i == 5) {
        path.addOval(Rect.fromCircle(center: Offset(center.dx - 30, center.dy - 10), radius: radius * 0.4));
      }

      // Draw filled cloud part
      canvas.drawPath(path, fillPaint);
      // Draw the outline for each cloud part
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(CloudShapePainter oldDelegate) => true;
}

class ColorPalette extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ColorButton(color: Colors.red),
        ColorButton(color: Colors.green),
        ColorButton(color: Colors.blue),
        ColorButton(color: Colors.yellow),
        ColorButton(color: Colors.orange),
        ColorButton(color: Colors.purple),
      ],
    );
  }
}

class ColorButton extends StatelessWidget {
  final Color color;

  ColorButton({required this.color});

  @override
  Widget build(BuildContext context) {
    final isSelected = Provider.of<CakeColorProvider>(context).selectedColor == color;

    return GestureDetector(
      onTap: () {
        Provider.of<CakeColorProvider>(context, listen: false).selectColor(color);
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
  }
}

