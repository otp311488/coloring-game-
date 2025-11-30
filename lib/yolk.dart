import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:coloring_game/zigzag.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Google Mobile Ads SDK
  MobileAds.instance.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) => EggColorProvider(),
      child: MaterialApp(
        home: EggPage(),
      ),
    ),
  );
}

class EggPage extends StatefulWidget {
  @override
  _EggPageState createState() => _EggPageState();
}

class _EggPageState extends State<EggPage> {
  bool _showAnimation = false;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    Provider.of<EggColorProvider>(context, listen: false).addListener(_onColorProviderChange);
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-1229063300907623/6924440615', // Replace with your own ad unit ID
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

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null; // Reset the ad to prevent multiple shows
      _loadInterstitialAd(); // Load another ad for the next time
    }
  }

  void _onColorProviderChange() {
    if (Provider.of<EggColorProvider>(context, listen: false).isCompleted) {
      setState(() {
        _showAnimation = true;
      });

      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          _showAnimation = false;
        });

        _showInterstitialAd(); // Show the interstitial ad before navigating

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ZigzagPage()),
        );
      });
    }
  }

  @override
  void dispose() {
    Provider.of<EggColorProvider>(context, listen: false).removeListener(_onColorProviderChange);
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Untitled design (24).png'), // Your background image
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
                    'Egg Learning',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(offset: Offset(2, 2), blurRadius: 5, color: Colors.black54),
                      ],
                    ),
                  ),
                  Consumer<EggColorProvider>(
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
                    Consumer<EggColorProvider>(
                      builder: (context, provider, child) {
                        return GestureDetector(
                          onTapDown: (details) {
                            _handleTap(details.localPosition, provider, context);
                          },
                          child: SizedBox(
                            width: 300,
                            height: 400, // Adjust size for the egg
                            child: CustomPaint(
                              painter: EggPainter(provider),
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
                        ' Yolk',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
              child: ColorPalette(), // ColorPalette widget
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(Offset position, EggColorProvider provider, BuildContext context) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset localPosition = renderBox.globalToLocal(position);

    double canvasWidth = 300;
    double canvasHeight = 400; // Adjust height for the egg

    if (_isPointWithinEgg(localPosition, canvasWidth, canvasHeight)) {
      provider.fillEgg();
    }
  }

  bool _isPointWithinEgg(Offset point, double width, double height) {
    Path eggPath = Path();
    eggPath.moveTo(width / 2, height / 5);
    eggPath.quadraticBezierTo(width / 4, height / 2, width / 2, height);
    eggPath.quadraticBezierTo(3 * width / 4, height / 2, width / 2, height / 5);
    eggPath.close();

    Path yolkPath = Path();
    yolkPath.addOval(Rect.fromCircle(center: Offset(width / 2, height / 2 + 50), radius: 50));

    return eggPath.contains(point) || yolkPath.contains(point);
  }
}

class EggPainter extends CustomPainter {
  final EggColorProvider colorProvider;

  EggPainter(this.colorProvider);

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    _drawEgg(canvas, width, height);
  }

  void _drawEgg(Canvas canvas, double width, double height) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Draw egg white (adjusting for a slightly larger size)
    Path eggPath = Path();
    eggPath.moveTo(width / 2, height / 6); // Start slightly higher
    eggPath.quadraticBezierTo(width / 6, height / 2, width / 2, height);
    eggPath.quadraticBezierTo(5 * width / 6, height / 2, width / 2, height / 6);
    eggPath.close();
    paint.color = colorProvider.eggWhiteColor;
    canvas.drawPath(eggPath, paint);

    // Draw yolk (adjust size and position if necessary)
    Path yolkPath = Path();
    yolkPath.addOval(Rect.fromCircle(center: Offset(width / 2, height / 2), radius: 50)); // Slightly larger yolk
    paint.color = colorProvider.yolkColor;
    canvas.drawPath(yolkPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ColorPalette extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final selectedColor = Provider.of<EggColorProvider>(context).selectedColor;

    final List<Color> colors = [
      Colors.brown,
      Colors.orange,
      Colors.yellow,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: colors.map((color) {
          return GestureDetector(
            onTap: () {
              Provider.of<EggColorProvider>(context, listen: false).selectedColor = color;
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

class EggColorProvider extends ChangeNotifier {
  Color _yolkColor = Colors.yellow; // Default color for yolk
  Color _eggWhiteColor = Colors.white; // Default color for egg white
  Color _selectedColor = Colors.red; // Default selected color

  bool _isCompleted = false;

  bool _isYolkFilled = false;
  bool _isEggWhiteFilled = false;

  Color get selectedColor => _selectedColor;

  set selectedColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  Color get yolkColor => _yolkColor;
  Color get eggWhiteColor => _eggWhiteColor;

  bool get isCompleted => _isCompleted;

  int get score {
    int score = 0;
    if (_isYolkFilled) score += 1;
    if (_isEggWhiteFilled) score += 1;
    return score;
  }

  void fillEgg() {
    if (_yolkColor == Colors.yellow && !_isYolkFilled) {
      _yolkColor = _selectedColor;
      _isYolkFilled = true;
    } else if (_eggWhiteColor == Colors.white && !_isEggWhiteFilled) {
      _eggWhiteColor = _selectedColor;
      _isEggWhiteFilled = true;
    }

    if (_isYolkFilled && _isEggWhiteFilled) {
      _isCompleted = true;
    }

    notifyListeners();
  }
}
