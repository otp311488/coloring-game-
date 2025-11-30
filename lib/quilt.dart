import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:coloring_game/rainbow.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Google Mobile Ads SDK
  MobileAds.instance.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) => QuiltColorProvider(),
      child: MaterialApp(
        home: QuiltPage(),
      ),
    ),
  );
}

class QuiltPage extends StatefulWidget {
  @override
  _QuiltPageState createState() => _QuiltPageState();
}

class _QuiltPageState extends State<QuiltPage> {
  bool _showAnimation = false;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    Provider.of<QuiltColorProvider>(context, listen: false).addListener(_onColorProviderChange);
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
    if (Provider.of<QuiltColorProvider>(context, listen: false).isCompleted) {
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
          MaterialPageRoute(builder: (context) => RainbowPage()),
        );
      });
    }
  }

  @override
  void dispose() {
    Provider.of<QuiltColorProvider>(context, listen: false).removeListener(_onColorProviderChange);
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Untitled design (14).png'),
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
                  Consumer<QuiltColorProvider>(
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
            SizedBox(height: 20), // Added spacing
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Consumer<QuiltColorProvider>(
                      builder: (context, provider, child) {
                        return GestureDetector(
                          onTapDown: (details) {
                            _handleTap(details.localPosition, provider, context);
                          },
                          child: CustomPaint(
                            painter: QuiltPainter(provider),
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

  void _handleTap(Offset position, QuiltColorProvider provider, BuildContext context) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;
    double dx = position.dx / size.width;
    double dy = position.dy / size.height;

    int gridSize = 3; 
    double tileWidth = size.width / gridSize;
    double tileHeight = size.height / gridSize;

    int x = (dx * gridSize).floor();
    int y = (dy * gridSize).floor();
    int tileIndex = y * gridSize + x;

    if (tileIndex >= 0 && tileIndex < provider.tiles.length) {
      provider.fillTile(tileIndex);
    }
  }
}

class QuiltPainter extends CustomPainter {
  final QuiltColorProvider colorProvider;

  QuiltPainter(this.colorProvider);

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

    final int gridSize = 3;
    final double tileWidth = size.width / gridSize;
    final double tileHeight = size.height / gridSize;

    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        int tileIndex = y * gridSize + x;
        paint.color = colorProvider.tiles[tileIndex];
        Rect rect = Rect.fromLTWH(x * tileWidth, y * tileHeight, tileWidth, tileHeight);
        canvas.drawRect(rect, paint);
        canvas.drawRect(rect, strokePaint);

        // Draw grid lines
        paint.color = Colors.black.withOpacity(0.5);
        canvas.drawLine(
          Offset(x * tileWidth, y * tileHeight),
          Offset(x * tileWidth + 5, y * tileHeight + 5),
          paint,
        );
        canvas.drawLine(
          Offset(x * tileWidth + tileWidth, y * tileHeight),
          Offset(x * tileWidth + tileWidth + 5, y * tileHeight + 5),
          paint,
        );
        canvas.drawLine(
          Offset(x * tileWidth, y * tileHeight + tileHeight),
          Offset(x * tileWidth + 5, y * tileHeight + tileHeight + 5),
          paint,
        );
        canvas.drawLine(
          Offset(x * tileWidth + tileWidth, y * tileHeight + tileHeight),
          Offset(x * tileWidth + tileWidth + 5, y * tileHeight + tileHeight + 5),
          paint,
        );
      }
    }

    // Draw text
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Q = Quilt',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          shadows: [
            Shadow(offset: Offset(1, 1), blurRadius: 4, color: Colors.grey),
          ],
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )
      ..layout(maxWidth: size.width);

    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ColorPalette extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final selectedColor = Provider.of<QuiltColorProvider>(context).selectedColor;
    final List<Color> colors = [Colors.red, Colors.green, Colors.blue, Colors.yellow, Colors.orange];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: colors.map((color) {
        return GestureDetector(
          onTap: () {
            Provider.of<QuiltColorProvider>(context, listen: false).selectedColor = color;
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
    );
  }
}

class QuiltColorProvider extends ChangeNotifier {
  List<Color> tiles = List.generate(9, (_) => Colors.white);
  Color _selectedColor = Colors.red;

  Color get selectedColor => _selectedColor;
  set selectedColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  void fillTile(int tileIndex) {
    tiles[tileIndex] = selectedColor;
    notifyListeners();

    if (tiles.every((tile) => tile != Colors.white)) {
      _isCompleted = true;
      notifyListeners();
    }
  }

  bool _isCompleted = false;
  bool get isCompleted => _isCompleted;

  int get score => tiles.where((tile) => tile != Colors.white).length;
}
