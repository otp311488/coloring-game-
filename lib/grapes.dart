import 'package:coloring_game/house.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:lottie/lottie.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Google Mobile Ads SDK
  MobileAds.instance.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) => GloveColorProvider(),
      child: MaterialApp(
        home: GlovePage(),
      ),
    ),
  );
}

class GlovePage extends StatefulWidget {
  @override
  _GlovePageState createState() => _GlovePageState();
}

class _GlovePageState extends State<GlovePage> {
  bool _showAnimation = false;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    Provider.of<GloveColorProvider>(context, listen: false).addListener(_onColorProviderChange);
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-1229063300907623/6924440615',
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  void _onColorProviderChange() {
    if (Provider.of<GloveColorProvider>(context, listen: false).score == 6) {
      setState(() {
        _showAnimation = true;
      });

      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          _showAnimation = false;
        });

        if (_interstitialAd != null) {
          _interstitialAd!.show();
          _interstitialAd = null; // Reset the ad to prevent multiple shows
          _loadInterstitialAd(); // Load another ad for the next time
        }

        // Navigate to HousePage after animation
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HousePage()),
        );
      });
    }
  }

  @override
  void dispose() {
    Provider.of<GloveColorProvider>(context, listen: false).removeListener(_onColorProviderChange);
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Untitled design.png'),
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
                  Consumer<GloveColorProvider>(
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
                      top: 206,
                      right: 0,
                      child: Column(
                        children: [
                          Text(
                            'G',
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
                            '= GiftBox',
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
                    Consumer<GloveColorProvider>(
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
                              partIndex = 0; // Top-Left
                            } else if (angle < 2 * pi / 3) {
                              partIndex = 1; // Top-Center
                            } else if (angle < pi) {
                              partIndex = 2; // Top-Right
                            } else if (angle < 4 * pi / 3) {
                              partIndex = 3; // Bottom-Right
                            } else if (angle < 5 * pi / 3) {
                              partIndex = 4; // Bottom-Center
                            } else {
                              partIndex = 5; // Bottom-Left
                            }

                            provider.fillCircle(partIndex);
                          },
                          child: CustomPaint(
                            painter: DoorShapePainter(provider),
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

class DoorShapePainter extends CustomPainter {
  final GloveColorProvider colorProvider;

  DoorShapePainter(this.colorProvider);

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

    final doorRect = Rect.fromLTWH(size.width * 0.2, size.height * 0.2, size.width * 0.6, size.height * 0.6);

    // Draw the door parts
    for (int i = 0; i < 6; i++) {
      fillPaint.color = colorProvider.getColorPart(i) ?? Colors.pink;
      final path = Path();

      double left, top, width, height;

      if (i == 0 || i == 3) {
        left = doorRect.left;
      } else if (i == 1 || i == 4) {
        left = doorRect.left + doorRect.width / 2;
      } else {
        left = doorRect.left + doorRect.width;
      }

      if (i < 3) {
        top = doorRect.top;
      } else {
        top = doorRect.top + doorRect.height / 2;
      }

      width = doorRect.width / 2;
      height = doorRect.height / 2;

      path.addRect(Rect.fromLTWH(left, top, width, height));

      // Add shadow effect
      canvas.drawShadow(path, Colors.white, 5, true);

      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);
    }

    // Draw the door outline
    canvas.drawRect(doorRect, strokePaint);

    // Draw 3D effect
    final Paint shadowPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawRect(doorRect.inflate(4), shadowPaint); // Add shadow around the door
  }

  @override
  bool shouldRepaint(DoorShapePainter oldDelegate) => true;
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
    final isSelected = Provider.of<GloveColorProvider>(context).selectedColor == color;

    return GestureDetector(
      onTap: () {
        Provider.of<GloveColorProvider>(context, listen: false).selectColor(color);
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
            ),
          ],
        ),
      ),
    );
  }
}

class GloveColorProvider with ChangeNotifier {
  List<Color?> _colors = [null, null, null, null, null, null];
  Color? _selectedColor;
  int _score = 0;

  Color? getColorPart(int index) => _colors[index];
  Color? get selectedColor => _selectedColor;
  int get score => _score;

  void fillCircle(int index) {
    if (_colors[index] == null && _selectedColor != null) {
      _colors[index] = _selectedColor;
      _score++;
      notifyListeners();
    }
  }

  void selectColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }
}
