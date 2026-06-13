import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// ── Shape data ────────────────────────────────────────────────────────────────
class _Shape {
  final String name;
  final String emoji;
  final Color color;
  final Widget Function(double size, Color color) painter;

  const _Shape({
    required this.name,
    required this.emoji,
    required this.color,
    required this.painter,
  });
}

Widget _circlePainter(double size, Color color) => Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color,
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))]),
    );

Widget _squarePainter(double size, Color color) => Container(
      width: size, height: size,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))]),
    );

Widget _trianglePainter(double size, Color color) => CustomPaint(
      size: Size(size, size),
      painter: _TrianglePainter(color),
    );

Widget _rectanglePainter(double size, Color color) => Container(
      width: size, height: size * 0.6,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))]),
    );

Widget _ovalPainter(double size, Color color) => Container(
      width: size, height: size * 0.65,
      decoration: BoxDecoration(shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(size),
          color: color,
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))]),
    );

Widget _starPainter(double size, Color color) => CustomPaint(
      size: Size(size, size),
      painter: _StarPainter(color),
    );

Widget _heartPainter(double size, Color color) => CustomPaint(
      size: Size(size, size),
      painter: _HeartPainter(color),
    );

Widget _diamondPainter(double size, Color color) => CustomPaint(
      size: Size(size, size * 0.85),
      painter: _DiamondPainter(color),
    );

// ── Custom painters ───────────────────────────────────────────────────────────
class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final shadow = Paint()..color = color.withOpacity(0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    final path = Path()
      ..moveTo(size.width / 2, 4)
      ..lineTo(size.width - 4, size.height - 4)
      ..lineTo(4, size.height - 4)
      ..close();
    canvas.drawPath(path, shadow);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(_) => false;
}

class _StarPainter extends CustomPainter {
  final Color color;
  _StarPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final shadow = Paint()..color = color.withOpacity(0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    final cx = size.width / 2, cy = size.height / 2;
    final outer = size.width / 2 - 4, inner = outer * 0.42;
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final r = i.isEven ? outer : inner;
      final angle = (i * pi / 5) - pi / 2;
      final x = cx + r * cos(angle), y = cy + r * sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, shadow);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(_) => false;
}

class _HeartPainter extends CustomPainter {
  final Color color;
  _HeartPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final shadow = Paint()..color = color.withOpacity(0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    final w = size.width, h = size.height;
    final path = Path()
      ..moveTo(w / 2, h * 0.85)
      ..cubicTo(0, h * 0.5, 0, h * 0.1, w / 4, h * 0.1)
      ..cubicTo(w * 0.38, h * 0.1, w / 2, h * 0.25, w / 2, h * 0.25)
      ..cubicTo(w / 2, h * 0.25, w * 0.62, h * 0.1, w * 0.75, h * 0.1)
      ..cubicTo(w, h * 0.1, w, h * 0.5, w / 2, h * 0.85)
      ..close();
    canvas.drawPath(path, shadow);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(_) => false;
}

class _DiamondPainter extends CustomPainter {
  final Color color;
  _DiamondPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final shadow = Paint()..color = color.withOpacity(0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    final path = Path()
      ..moveTo(size.width / 2, 4)
      ..lineTo(size.width - 4, size.height / 2)
      ..lineTo(size.width / 2, size.height - 4)
      ..lineTo(4, size.height / 2)
      ..close();
    canvas.drawPath(path, shadow);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(_) => false;
}

// ── All shapes ────────────────────────────────────────────────────────────────
final List<_Shape> _allShapes = [
  _Shape(name: 'Circle',    emoji: '⭕', color: const Color(0xFFFF6B6B), painter: _circlePainter),
  _Shape(name: 'Square',    emoji: '🟦', color: const Color(0xFF4ECDC4), painter: _squarePainter),
  _Shape(name: 'Triangle',  emoji: '🔺', color: const Color(0xFFFFE66D), painter: _trianglePainter),
  _Shape(name: 'Rectangle', emoji: '▬',  color: const Color(0xFFA8E6CF), painter: _rectanglePainter),
  _Shape(name: 'Oval',      emoji: '🥚', color: const Color(0xFFFFAA85), painter: _ovalPainter),
  _Shape(name: 'Star',      emoji: '⭐', color: const Color(0xFFFFD93D), painter: _starPainter),
  _Shape(name: 'Heart',     emoji: '❤️', color: const Color(0xFFFF6B9D), painter: _heartPainter),
  _Shape(name: 'Diamond',   emoji: '💎', color: const Color(0xFF88D8B0), painter: _diamondPainter),
];

List<_Shape> _shapesForDifficulty(String diff) {
  if (diff == 'EASY')   return _allShapes.sublist(0, 3);
  if (diff == 'MEDIUM') return _allShapes.sublist(0, 5);
  return _allShapes;
}

// ── Main page ─────────────────────────────────────────────────────────────────
class ShapesGamePage extends StatefulWidget {
  const ShapesGamePage({super.key});
  @override
  State<ShapesGamePage> createState() => _ShapesGamePageState();
}

class _ShapesGamePageState extends State<ShapesGamePage>
    with TickerProviderStateMixin {
  final _rand = Random();

  int _redScore = 0;
  int _blueScore = 0;
  bool _gameStarted = false;
  bool _redTurn = true; // true = red, false = blue
  String _difficulty = 'EASY';
  static const int _winScore = 10;

  late _Shape _currentShape;
  List<String> _options = [];
  bool _answered = false;
  String _feedback = '';
  bool _feedbackCorrect = false;
  bool _showFeedback = false;

  final List<_Star> _stars = [];
  final List<String> _starEmojis = ['⭐', '🌟', '✨', '🎉', '🎊', '🎈', '💫', '🌈'];

  late AnimationController _celebAnim;
  late AnimationController _shapeAnim;
  late AnimationController _pulseAnim;
  late AnimationController _shakeAnim;
  late AnimationController _turnAnim;
  late Animation<double> _shapeScale;
  late Animation<double> _pulse;
  late Animation<double> _shake;
  late Animation<double> _turnSlide;

  final List<Color> _optColors = [
    const Color(0xFFFF6B9D),
    const Color(0xFF4ECDC4),
    const Color(0xFFFFB347),
    const Color(0xFF9B59B6),
    const Color(0xFF3498DB),
  ];

  @override
  void initState() {
    super.initState();

    _celebAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _celebAnim.addStatusListener((s) {
      if (s == AnimationStatus.completed) setState(() => _stars.clear());
    });

    _shapeAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _shapeScale = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _shapeAnim, curve: Curves.elasticOut));

    _pulseAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.06).animate(
        CurvedAnimation(parent: _pulseAnim, curve: Curves.easeInOut));

    _shakeAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shake = Tween<double>(begin: 0, end: 1).animate(_shakeAnim);

    _turnAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _turnSlide = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _turnAnim, curve: Curves.easeOut));

    _generateQuestion();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showStartPopup());
  }

  @override
  void dispose() {
    _celebAnim.dispose();
    _shapeAnim.dispose();
    _pulseAnim.dispose();
    _shakeAnim.dispose();
    _turnAnim.dispose();
    super.dispose();
  }

  void _generateQuestion() {
    final shapes = _shapesForDifficulty(_difficulty);
    _currentShape = shapes[_rand.nextInt(shapes.length)];

    final wrongPool = _allShapes.where((s) => s.name != _currentShape.name).toList()..shuffle();
    final opts = <String>[_currentShape.name];
    for (final s in wrongPool) {
      if (opts.length >= 4) break;
      opts.add(s.name);
    }
    opts.shuffle();
    _options = opts;
    _answered = false;
    _feedback = '';
    _showFeedback = false;
    setState(() {});
    _shapeAnim.forward(from: 0);
  }

  void _onAnswer(String name) {
    if (_answered || !_gameStarted) return;
    setState(() => _answered = true);

    if (name == _currentShape.name) {
      setState(() {
        if (_redTurn) _redScore++; else _blueScore++;
        _feedbackCorrect = true;
        _feedback = _correctMsg();
        _showFeedback = true;
      });
      _spawnStars();
      _celebAnim.forward(from: 0);
      if ((_redTurn ? _redScore : _blueScore) >= _winScore) {
        Future.delayed(const Duration(milliseconds: 900), _showWinner);
        return;
      }
      Future.delayed(const Duration(milliseconds: 1300), () {
        if (!mounted) return;
        setState(() => _redTurn = !_redTurn);
        _turnAnim.forward(from: 0);
        _generateQuestion();
      });
    } else {
      setState(() {
        _feedbackCorrect = false;
        _feedback = _wrongMsg();
        _showFeedback = true;
        _answered = false;
      });
      _shakeAnim.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) setState(() => _showFeedback = false);
      });
    }
  }

  void _spawnStars() {
    final size = MediaQuery.of(context).size;
    _stars.clear();
    for (int i = 0; i < 20; i++) {
      _stars.add(_Star(
        x: _rand.nextDouble() * size.width,
        y: _rand.nextDouble() * size.height,
        emoji: _starEmojis[_rand.nextInt(_starEmojis.length)],
        size: 18 + _rand.nextDouble() * 26,
      ));
    }
  }

  String _correctMsg() {
    final l = ['🎉 Correct!', '⭐ Amazing!', '🌟 Great Job!', '🏆 Yes!', '🎊 Super!'];
    return l[_rand.nextInt(l.length)];
  }

  String _wrongMsg() {
    final l = ['💪 Try Again!', '🤔 Look Carefully!', '😊 Almost!'];
    return l[_rand.nextInt(l.length)];
  }

  // ── Popups ────────────────────────────────────────────────────────────────
  void _showStartPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B9D), Color(0xFFFF8E53)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.5), blurRadius: 24)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔷', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 4),
                const Text('Shapes Game!',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                const Text('Take turns identifying shapes!\n🔴 Red vs 🔵 Blue',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 12),
                const Text('Select Difficulty:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 6),
                Row(children: [
                  _diffBtn(setLocal, 'EASY',   '3 Shapes', const Color(0xFF4CAF50)),
                  const SizedBox(width: 6),
                  _diffBtn(setLocal, 'MEDIUM', '5 Shapes', const Color(0xFFFFD600)),
                  const SizedBox(width: 6),
                  _diffBtn(setLocal, 'HARD',   '8 Shapes', const Color(0xFFFF5252)),
                ]),
                const SizedBox(height: 8),
                const Text('First to 10 points wins 🏆',
                    style: TextStyle(color: Colors.white70, fontSize: 11)),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () { Navigator.pop(ctx); _startGame(); },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('🚀 ', style: TextStyle(fontSize: 18)),
                      Text('Start Game!',
                          style: TextStyle(color: Color(0xFFFF6B9D), fontSize: 17, fontWeight: FontWeight.w900)),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _diffBtn(StateSetter setLocal, String diff, String label, Color color) {
    final sel = _difficulty == diff;
    return Expanded(
      child: GestureDetector(
        onTap: () => setLocal(() => _difficulty = diff),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: sel ? color : color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: sel ? 2.5 : 1),
          ),
          child: Column(children: [
            Text(diff, style: TextStyle(color: sel ? Colors.white : color, fontSize: 11, fontWeight: FontWeight.w900)),
            Text(label, style: TextStyle(color: sel ? Colors.white70 : color.withOpacity(0.7), fontSize: 10)),
          ]),
        ),
      ),
    );
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _redScore = 0;
      _blueScore = 0;
      _redTurn = true;
    });
    _generateQuestion();
  }

  void _showWinner() {
    final isRed = _redScore >= _winScore;
    final c1 = isRed ? const Color(0xFFFF6B6B) : const Color(0xFF4ECDC4);
    final c2 = isRed ? const Color(0xFFFF3D00) : const Color(0xFF1E88E5);
    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [c1, c2], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: c1.withOpacity(0.5), blurRadius: 28)],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('🏆', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 8),
            const Text('Winner!', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
            Text(isRed ? '🔴 Red Team' : '🔵 Blue Team',
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('$_redScore 🔴  vs  🔵 $_blueScore',
                style: const TextStyle(color: Colors.white70, fontSize: 15)),
            const SizedBox(height: 6),
            const Text('🎊 🎈 🌟 🎉 🌟 🎈 🎊', style: TextStyle(fontSize: 22)),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(child: _dlgBtn('🏠 Home', Colors.white.withOpacity(0.3),
                  () { Navigator.pop(context); Navigator.pop(context); })),
              const SizedBox(width: 10),
              Expanded(child: _dlgBtn('🔄 Restart', Colors.white,
                  () { Navigator.pop(context); _showStartPopup(); }, textColor: c2)),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _dlgBtn(String label, Color color, VoidCallback onTap, {Color textColor = Colors.white}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: color.withOpacity(0.35), blurRadius: 8)]),
          child: Text(label, textAlign: TextAlign.center,
              style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w900)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final teamColor = _redTurn ? const Color(0xFFE53935) : const Color(0xFF1E88E5);
    final teamLabel = _redTurn ? '🔴 Red Team' : '🔵 Blue Team';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF0F5), Color(0xFFE8F4FD)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Celebration stars
              if (_stars.isNotEmpty)
                AnimatedBuilder(
                  animation: _celebAnim,
                  builder: (_, __) => Stack(
                    children: _stars.map((s) => Positioned(
                      left: s.x, top: s.y * _celebAnim.value * 1.4,
                      child: Opacity(
                        opacity: (1 - _celebAnim.value).clamp(0.0, 1.0),
                        child: Text(s.emoji, style: TextStyle(fontSize: s.size)),
                      ),
                    )).toList(),
                  ),
                ),

              // Back button — top right
              Positioned(
                top: 8, right: 10,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.grey),
                  ),
                ),
              ),

              Column(
                children: [
                  // ── Score bar ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedBuilder(
                              animation: _pulseAnim,
                              builder: (_, __) => Transform.scale(
                                scale: _redTurn ? _pulse.value : 1.0,
                                child: _ScoreCard(
                                  emoji: '🔴', label: 'Red Team', score: _redScore,
                                  color: const Color(0xFFE53935), active: _redTurn,
                                ),
                              ),
                            ),
                            Container(
                              width: 1, height: 36,
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              color: Colors.grey.shade300,
                            ),
                            AnimatedBuilder(
                              animation: _pulseAnim,
                              builder: (_, __) => Transform.scale(
                                scale: !_redTurn ? _pulse.value : 1.0,
                                child: _ScoreCard(
                                  emoji: '🔵', label: 'Blue Team', score: _blueScore,
                                  color: const Color(0xFF1E88E5), active: !_redTurn,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // ── Current turn banner ──
                  AnimatedBuilder(
                    animation: _turnAnim,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(0, (1 - _turnSlide.value) * -20),
                      child: Opacity(opacity: _turnSlide.value.clamp(0.0, 1.0), child: child),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                      decoration: BoxDecoration(
                        color: teamColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: teamColor.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Text('$teamLabel\'s Turn',
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Question section ──
                  Expanded(
                    flex: 5,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: _currentShape.color.withOpacity(0.35), width: 2.5),
                        boxShadow: [BoxShadow(color: _currentShape.color.withOpacity(0.15), blurRadius: 16)],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Question label bar
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _currentShape.color.withOpacity(0.15),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(26), topRight: Radius.circular(26)),
                            ),
                            child: Text('What shape is this? 🤔',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _currentShape.color)),
                          ),
                          // Shape display
                          Expanded(
                            child: Center(
                              child: ScaleTransition(
                                scale: _shapeScale,
                                child: AnimatedBuilder(
                                  animation: _shakeAnim,
                                  builder: (_, child) => Transform.translate(
                                    offset: Offset(
                                      _showFeedback && !_feedbackCorrect ? sin(_shake.value * pi * 5) * 8 : 0, 0),
                                    child: child,
                                  ),
                                  child: _currentShape.painter(size.width * 0.44, _currentShape.color),
                                ),
                              ),
                            ),
                          ),
                          // Feedback inside question box
                          AnimatedOpacity(
                            opacity: _showFeedback ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                              decoration: BoxDecoration(
                                color: _feedbackCorrect ? const Color(0xFF4CAF50) : const Color(0xFFFF5252),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [BoxShadow(
                                  color: (_feedbackCorrect ? Colors.green : Colors.red).withOpacity(0.3),
                                  blurRadius: 8,
                                )],
                              ),
                              child: Text(_feedback,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── Answer section ──
                  Container(
                    margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                    ),
                    child: Column(
                      children: [
                        // Section label
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text('Choose the Answer 👇',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.grey.shade600)),
                        ),
                        // Row 1 — 2 buttons
                        Row(
                          children: List.generate(2, (i) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: _AnsBtn(
                                label: _options[i],
                                color: _optColors[i],
                                onTap: () => _onAnswer(_options[i]),
                                locked: _answered,
                              ),
                            ),
                          )),
                        ),
                        const SizedBox(height: 4),
                        // Row 2 — 2 buttons
                        Row(
                          children: List.generate(2, (i) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: _AnsBtn(
                                label: _options[2 + i],
                                color: _optColors[2 + i],
                                onTap: () => _onAnswer(_options[2 + i]),
                                locked: _answered,
                              ),
                            ),
                          )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Score Card ────────────────────────────────────────────────────────────────
class _ScoreCard extends StatelessWidget {
  final String emoji, label;
  final int score;
  final Color color;
  final bool active;

  const _ScoreCard({
    required this.emoji, required this.label,
    required this.score, required this.color, required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? color.withOpacity(0.15) : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: active ? color : color.withOpacity(0.3), width: active ? 2 : 1.5),
        boxShadow: active
            ? [BoxShadow(color: color.withOpacity(0.25), blurRadius: 10)]
            : [],
      ),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 6),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
          Text('$score', style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900, height: 1)),
        ]),
      ]),
    );
  }
}

// ── Answer Button ─────────────────────────────────────────────────────────────
class _AnsBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool locked;

  const _AnsBtn({
    required this.label, required this.color,
    required this.onTap, required this.locked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: locked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 52,
        decoration: BoxDecoration(
          color: locked ? color.withOpacity(0.4) : color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: locked
              ? []
              : [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w900,
                color: locked ? Colors.white60 : Colors.white,
                shadows: const [Shadow(color: Colors.black26, blurRadius: 3, offset: Offset(1, 1))],
              )),
        ),
      ),
    );
  }
}

// ── Star particle ─────────────────────────────────────────────────────────────
class _Star {
  final double x, y, size;
  final String emoji;
  const _Star({required this.x, required this.y, required this.emoji, required this.size});
}
