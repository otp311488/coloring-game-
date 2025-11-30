
import 'package:coloring_game/axe.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coloring_game/cake.dart';
import 'package:coloring_game/cloudy_provider.dart';
import 'package:coloring_game/dish.dart';
import 'package:coloring_game/envelope.dart';
import 'package:coloring_game/fence.dart';
import 'package:coloring_game/grapes.dart';
import 'package:coloring_game/house.dart';
import 'package:coloring_game/icecream.dart';
import 'package:coloring_game/jelly.dart';
import 'package:coloring_game/kite.dart';
import 'package:coloring_game/ladder.dart';
import 'package:coloring_game/moon.dart';
import 'package:coloring_game/necklace.dart';
import 'package:coloring_game/oar.dart';
import 'package:coloring_game/pencil.dart';
import 'package:coloring_game/quilt.dart';
import 'package:coloring_game/rainbow.dart';
import 'package:coloring_game/star.dart';
import 'package:coloring_game/ticket.dart';
import 'package:coloring_game/uranus.dart';
import 'package:coloring_game/volcano.dart';
import 'package:coloring_game/wand.dart';
import 'package:coloring_game/xmastree.dart';
import 'package:coloring_game/yolk.dart';
import 'package:coloring_game/zigzag.dart';
import 'color_provider.dart';
import 'dart:math';
import 'package:lottie/lottie.dart';
import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:audioplayers/audioplayers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  // Initialize and play background music
  final MusicService musicService = MusicService();
  await musicService.playBackgroundMusic();
  runApp(
    MultiProvider(
      providers: [
         Provider<MusicService>.value(value: musicService),
         ChangeNotifierProvider(create: (_) => AxeColorProvider()),
        ChangeNotifierProvider(create: (_) => ColorProvider()),
        ChangeNotifierProvider(create: (_) => CakeColorProvider()),
        ChangeNotifierProvider(create: (_) => DoorColorProvider()),
        ChangeNotifierProvider(create: (_) => EnvelopeColorProvider()),
        ChangeNotifierProvider(create: (_) => FenceColorProvider()),
        ChangeNotifierProvider(create: (_) => GloveColorProvider()),
        ChangeNotifierProvider(create: (_) => HouseColorProvider()),
        ChangeNotifierProvider(create: (_) => IceCreamColorProvider()),
        ChangeNotifierProvider(create: (_) => JugColorProvider()),
        ChangeNotifierProvider(create: (_) => KiteColorProvider()),
        ChangeNotifierProvider(create: (_) => ladderColorProvider()),
        ChangeNotifierProvider(create: (_) => moonColorProvider()),
        ChangeNotifierProvider(create: (_) => NecklaceColorProvider()),
        ChangeNotifierProvider(create: (_) => OarColorProvider()),
        ChangeNotifierProvider(create: (_) => PencilColorProvider()),
        ChangeNotifierProvider(create: (_) => QuiltColorProvider()),
        ChangeNotifierProvider(create: (_) => RainbowColorProvider()),
        ChangeNotifierProvider(create: (_) => StarColorProvider()),
        ChangeNotifierProvider(create: (_) => TicketColorProvider()),
        ChangeNotifierProvider(create: (_) => UranusColorProvider()),
        ChangeNotifierProvider(create: (_) => VolcanoColorProvider()),
        ChangeNotifierProvider(create: (_) => WandColorProvider()),
        ChangeNotifierProvider(create: (_) => TreeColorProvider()),
        ChangeNotifierProvider(create: (_) => EggColorProvider()),
        ChangeNotifierProvider(create: (_) => ZigzagColorProvider()),
      ],
    child: ColoringGame(musicService: musicService),
    ),
  );
}

class ColoringGame extends StatelessWidget {
  final MusicService musicService;

  ColoringGame({required this.musicService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage(musicService: musicService),
      debugShowCheckedModeBanner: false,
    );
  }
}


class MainPage extends StatefulWidget {
  final MusicService musicService;

  MainPage({required this.musicService});

  @override
  _MainPageState createState() => _MainPageState();
}


class _MainPageState extends State<MainPage> {
  bool _isPressed = false;
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();

    // Load a test banner ad
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-1229063300907623/4689159514', 
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {});
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner ad failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Untitled design (26).png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Foreground content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.lightBlueAccent.withOpacity(0.5),
                        Colors.blueAccent.withOpacity(0.5)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Welcome to the ABC Coloring Game!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                            begin: 1.0, end: _isPressed ? 0.9 : 1.0),
                        duration: Duration(milliseconds: 200),
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isPressed = true;
                                });
                                Future.delayed(Duration(milliseconds: 200), () {
                                  setState(() {
                                    _isPressed = false;
                                  });
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AxePage()),
                                  );
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.blue,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 5,
                                shadowColor: Colors.black54,
                              ),
                              child: Text(
                                'Start Game',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_bannerAd != null)
              Container(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _showAnimation = false;

  @override
  void initState() {
    super.initState();
    Provider.of<ColorProvider>(context, listen: false)
        .addListener(_onColorProviderChange);
  }

  void _onColorProviderChange() {
    if (Provider.of<ColorProvider>(context, listen: false).score == 15) {
      setState(() {
        _showAnimation = true;
      });

      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          _showAnimation = false;
        });

        Navigator.of(context).push(MaterialPageRoute(builder: (_) => CloudPage()));
      });
    }
  }

  @override
  void dispose() {
    Provider.of<ColorProvider>(context, listen: false)
        .removeListener(_onColorProviderChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/ball.jpeg'),
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
                  Consumer<ColorProvider>(
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
                            'B',
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
                            '= Ball',
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
                    Container(
                      width: 300,
                      height: 300,
                      child: GestureDetector(
                        onTapDown: (details) {
                          final center = Offset(150, 150);
                          final dx = details.localPosition.dx - center.dx;
                          final dy = details.localPosition.dy - center.dy;
                          final angle = (dx != 0 || dy != 0)
                              ? (atan2(dy, dx) + pi) % (2 * pi)
                              : 0;

                          int partIndex;
                          if (angle < 2 * pi / 3) {
                            partIndex = 0;
                          } else if (angle < 4 * pi / 3) {
                            partIndex = 1;
                          } else {
                            partIndex = 2;
                          }

                          Provider.of<ColorProvider>(context, listen: false)
                              .fillCircle(partIndex);
                        },
                        child: CustomPaint(
                          painter: CircularShapePainter(
                              Provider.of<ColorProvider>(context)),
                        ),
                      ),
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

class CircularShapePainter extends CustomPainter {
  final ColorProvider colorProvider;

  CircularShapePainter(this.colorProvider);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final Paint outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 3
      ..isAntiAlias = true;

    final center = Offset(size.width * 0.5, size.height * 0.5);
    final radius = size.width * 0.4;

    // Draw the shadow
    canvas.drawShadow(
        Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
        Colors.black.withOpacity(0.3),
        5,
        true);

    // Draw the three parts with color
    for (int i = 0; i < 3; i++) {
      paint.color = colorProvider.getColorPart(i) ?? Colors.white; // Set color for each part
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        (2 * pi / 3) * i,
        2 * pi / 3,
        true,
        paint,
      );

      // Draw the outline for each part
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        (2 * pi / 3) * i,
        2 * pi / 3,
        true,
        outlinePaint,
      );
    }

    // Draw the overall outline of the ball
    canvas.drawCircle(center, radius, outlinePaint);
  }

  @override
  bool shouldRepaint(CircularShapePainter oldDelegate) => true;
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

class ColorButton extends StatefulWidget {
  final Color color;

  ColorButton({required this.color});

  @override
  _ColorButtonState createState() => _ColorButtonState();
}

class _ColorButtonState extends State<ColorButton> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Provider.of<ColorProvider>(context, listen: false)
            .selectColor(widget.color);
        setState(() {
          _isTapped = !_isTapped;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        width: _isTapped ? 45 : 40,
        height: _isTapped ? 45 : 40,
        decoration: BoxDecoration(
          color: widget.color,
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
            color: Provider.of<ColorProvider>(context).selectedColor ==
                    widget.color
                ? Colors.black
                : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }
}
class MusicService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Method to play background music
  Future<void> playBackgroundMusic() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop); // Set the music to loop
      await _audioPlayer.setVolume(0.5); // Set the volume level
      await _audioPlayer.play(AssetSource('abc-song-male-vocals-195993.mp3')); // Play the music
    } catch (e) {
      print('Error playing music: $e');
    }
  }

  // Method to stop the music
  Future<void> stopMusic() async {
    try {
      await _audioPlayer.stop(); // Stop the music
    } catch (e) {
      print('Error stopping music: $e');
    }
  }

  // Method to pause the music
  Future<void> pauseMusic() async {
    try {
      await _audioPlayer.pause(); // Pause the music
    } catch (e) {
      print('Error pausing music: $e');
    }
  }

  // Method to resume the music
  Future<void> resumeMusic() async {
    try {
      await _audioPlayer.resume(); // Resume the music
    } catch (e) {
      print('Error resuming music: $e');
    }
  }

  // Method to dispose of the audio player
  void dispose() {
    _audioPlayer.dispose(); // Clean up resources when done
  }
}