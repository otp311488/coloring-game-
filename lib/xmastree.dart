import 'package:coloring_game/yolk.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => TreeColorProvider(),
      child: MaterialApp(
        home: TreePage(),
      ),
    ),
  );
}

class TreePage extends StatefulWidget {
  @override
  _TreePageState createState() => _TreePageState();
}

class _TreePageState extends State<TreePage> {
  bool _showAnimation = false;

  @override
  void initState() {
    super.initState();
    Provider.of<TreeColorProvider>(context, listen: false).addListener(_onColorProviderChange);
  }

  void _onColorProviderChange() {
    if (Provider.of<TreeColorProvider>(context, listen: false).isCompleted) {
      setState(() {
        _showAnimation = true;
      });

      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          _showAnimation = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EggPage()),
        );
      });
    }
  }

  @override
  void dispose() {
    Provider.of<TreeColorProvider>(context, listen: false).removeListener(_onColorProviderChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Untitled design (23).png'),
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
                  Consumer<TreeColorProvider>(
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
                    Consumer<TreeColorProvider>(
                      builder: (context, provider, child) {
                        return GestureDetector(
                          onTapDown: (details) {
                            _handleTap(details.localPosition, provider, context);
                          },
                          child: SizedBox(
                            width: 300,
                            height: 400, // Adjust size for the tree
                            child: CustomPaint(
                              painter: TreePainter(provider),
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
                        'Xmas Tree',
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

  void _handleTap(Offset position, TreeColorProvider provider, BuildContext context) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset localPosition = renderBox.globalToLocal(position);

    double canvasWidth = 300;
    double canvasHeight = 400; // Adjust height for the tree

    if (_isPointWithinTree(localPosition, canvasWidth, canvasHeight)) {
      provider.fillTree();
    }
  }

  bool _isPointWithinTree(Offset point, double width, double height) {
    Path bottomConePath = Path();
    bottomConePath.moveTo(width / 2, height / 4 * 2.5);
    bottomConePath.lineTo(width / 4, height);
    bottomConePath.lineTo(width / 4 * 3, height);
    bottomConePath.close();

    Path middleConePath = Path();
    middleConePath.moveTo(width / 2, height / 4 * 1.5);
    middleConePath.lineTo(width / 4 + 30, height / 4 * 2.5);
    middleConePath.lineTo(width / 4 * 3 - 30, height / 4 * 2.5);
    middleConePath.close();

    Path topConePath = Path();
    topConePath.moveTo(width / 2, height / 4);
    topConePath.lineTo(width / 2 - 30, height / 4 * 1.5);
    topConePath.lineTo(width / 2 + 30, height / 4 * 1.5);
    topConePath.close();

    Path trunkPath = Path();
    trunkPath.moveTo(width / 2 - 10, height / 4 * 2.7);
    trunkPath.lineTo(width / 2 + 10, height / 4 * 2.7);
    trunkPath.lineTo(width / 2 + 10, height);
    trunkPath.lineTo(width / 2 - 10, height);
    trunkPath.close();

    // Check if point is within any part of the tree
    if (bottomConePath.contains(point)) return true;
    if (middleConePath.contains(point)) return true;
    if (topConePath.contains(point)) return true;
    if (trunkPath.contains(point)) return true;

    return false;
  }
}

class TreePainter extends CustomPainter {
  final TreeColorProvider colorProvider;

  TreePainter(this.colorProvider);

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // Draw the Christmas tree with three cones and a trunk
    _drawTree(canvas, width, height);
  }

  void _drawTree(Canvas canvas, double width, double height) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Draw bottom cone
    Path bottomConePath = Path();
    bottomConePath.moveTo(width / 2, height / 4 * 2.5);
    bottomConePath.lineTo(width / 4, height);
    bottomConePath.lineTo(width / 4 * 3, height);
    bottomConePath.close();
    paint.color = colorProvider.treeColor1;
    canvas.drawPath(bottomConePath, paint);

    // Draw middle cone
    Path middleConePath = Path();
    middleConePath.moveTo(width / 2, height / 4 * 1.5);
    middleConePath.lineTo(width / 4 + 30, height / 4 * 2.5);
    middleConePath.lineTo(width / 4 * 3 - 30, height / 4 * 2.5);
    middleConePath.close();
    paint.color = colorProvider.treeColor2;
    canvas.drawPath(middleConePath, paint);

    // Draw top cone
    Path topConePath = Path();
    topConePath.moveTo(width / 2, height / 4);
    topConePath.lineTo(width / 2 - 30, height / 4 * 1.5);
    topConePath.lineTo(width / 2 + 30, height / 4 * 1.5);
    topConePath.close();
    paint.color = colorProvider.treeColor3;
    canvas.drawPath(topConePath, paint);

    // Draw the trunk
    Path trunkPath = Path();
    trunkPath.moveTo(width / 2 - 10, height / 2 * 2.7);
    trunkPath.lineTo(width / 2 + 10, height / 2 * 2.7);
    trunkPath.lineTo(width / 2 + 10, height);
    trunkPath.lineTo(width / 2 - 10, height);
    trunkPath.close();
    paint.color = colorProvider.trunkColor;
    canvas.drawPath(trunkPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ColorPalette extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final selectedColor = Provider.of<TreeColorProvider>(context).selectedColor;

    final List<Color> colors = [
      Colors.red,
      Colors.green,
      Colors.brown,
      Colors.purple,
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
              Provider.of<TreeColorProvider>(context, listen: false).selectedColor = color;
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

class TreeColorProvider extends ChangeNotifier {
  Color _treeColor1 = Colors.white; // Bottom cone
  Color _treeColor2 = Colors.white; // Middle cone
  Color _treeColor3 = Colors.white; // Top cone
  Color _trunkColor = Colors.brown;
  Color _selectedColor = Colors.red; // Default selected color
  
  bool _isCompleted = false;

  bool _isTreeColor1Filled = false;
  bool _isTreeColor2Filled = false;
  bool _isTreeColor3Filled = false;
  bool _isTrunkColorFilled = false;

  Color get selectedColor => _selectedColor;

  set selectedColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  Color get treeColor1 => _treeColor1;
  Color get treeColor2 => _treeColor2;
  Color get treeColor3 => _treeColor3;
  Color get trunkColor => _trunkColor;

  bool get isCompleted => _isCompleted;

  int get score {
    int score = 0;
    if (_isTreeColor1Filled) score += 1;
    if (_isTreeColor2Filled) score += 1;
    if (_isTreeColor3Filled) score += 1;
    if (_isTrunkColorFilled) score += 1;
    return score;
  }

  void fillTree() {
    if (_treeColor1 == Colors.white && !_isTreeColor1Filled) {
      _treeColor1 = _selectedColor;
      _isTreeColor1Filled = true;
    } else if (_treeColor2 == Colors.white && !_isTreeColor2Filled) {
      _treeColor2 = _selectedColor;
      _isTreeColor2Filled = true;
    } else if (_treeColor3 == Colors.white && !_isTreeColor3Filled) {
      _treeColor3 = _selectedColor;
      _isTreeColor3Filled = true;
    } else if (_trunkColor == Colors.brown && !_isTrunkColorFilled) {
      _trunkColor = _selectedColor;
      _isTrunkColorFilled = true;
    }

    if (_isTreeColor1Filled && _isTreeColor2Filled && _isTreeColor3Filled && _isTrunkColorFilled) {
      _isCompleted = true;
    }

    notifyListeners();
  }
}


