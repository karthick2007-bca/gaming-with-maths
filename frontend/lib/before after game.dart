import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

enum QType { before, after, both }

const Map<int, String> _numWords = {
  1:'One',2:'Two',3:'Three',4:'Four',5:'Five',6:'Six',7:'Seven',8:'Eight',9:'Nine',10:'Ten',
  11:'Eleven',12:'Twelve',13:'Thirteen',14:'Fourteen',15:'Fifteen',16:'Sixteen',
  17:'Seventeen',18:'Eighteen',19:'Nineteen',20:'Twenty',
};

class BeforeAfterGame extends StatefulWidget {
  const BeforeAfterGame({super.key});
  @override
  State<BeforeAfterGame> createState() => _BeforeAfterGameState();
}

class _BeforeAfterGameState extends State<BeforeAfterGame>
    with TickerProviderStateMixin {
  final _rand = Random();

  int _redScore = 0;
  int _blueScore = 0;
  bool _gameStarted = false;
  String _difficulty = 'EASY';
  static const int _winScore = 10;

  // Red team question
  int _redNum = 0;
  QType _redQType = QType.before;
  List<int> _redOpts = [];
  int? _redSel1; // before selected
  int? _redSel2; // after selected
  bool _redAnswered = false;
  bool _redCorrect = false;
  String _redMsg = '';
  bool _redShowMsg = false;

  // Blue team question
  int _blueNum = 0;
  QType _blueQType = QType.before;
  List<int> _blueOpts = [];
  int? _blueSel1;
  int? _blueSel2;
  bool _blueAnswered = false;
  bool _blueCorrect = false;
  String _blueMsg = '';
  bool _blueShowMsg = false;

  int _seconds = 60;
  Timer? _timer;

  late AnimationController _celebAnim;
  late AnimationController _pulseAnim;
  late AnimationController _timerPulse;
  late AnimationController _redShakeAnim;
  late AnimationController _blueShakeAnim;
  // Snake eat animations
  late AnimationController _redFlashAnim;
  late AnimationController _blueFlashAnim;
  late AnimationController _redScoreFloatAnim;
  late AnimationController _blueScoreFloatAnim;
  late AnimationController _redSnakeGrowAnim;
  late AnimationController _blueSnakeGrowAnim;
  late Animation<double> _pulse;
  late Animation<double> _timerScale;
  late Animation<double> _redShake;
  late Animation<double> _blueShake;
  late Animation<double> _redFlash;
  late Animation<double> _blueFlash;
  late Animation<double> _redScoreFloat;
  late Animation<double> _redScoreOpacity;
  late Animation<double> _blueScoreFloat;
  late Animation<double> _blueScoreOpacity;
  late Animation<double> _redSnakeGrow;
  late Animation<double> _blueSnakeGrow;

  bool _showRedFloat = false;
  bool _showBlueFloat = false;
  int _redSnakeLen = 3;
  int _blueSnakeLen = 3;

  final List<_Star> _stars = [];
  final List<String> _starEmojis = ['⭐','🌟','✨','🎉','🎊','🎈','💫'];

  final List<Color> _redBtnColors = [
    Color(0xFFFF6B9D), Color(0xFFFF8C94), Color(0xFFFFB347),
    Color(0xFFFF6B6B), Color(0xFFE91E63),
  ];
  final List<Color> _blueBtnColors = [
    Color(0xFF4ECDC4), Color(0xFF64B5F6), Color(0xFFA8E6CF),
    Color(0xFF4DB6AC), Color(0xFF42A5F5),
  ];

  @override
  void initState() {
    super.initState();

    _celebAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _celebAnim.addStatusListener(
        (s) { if (s == AnimationStatus.completed) setState(() => _stars.clear()); });

    _pulseAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.06).animate(
        CurvedAnimation(parent: _pulseAnim, curve: Curves.easeInOut));

    _timerPulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..repeat(reverse: true);
    _timerScale = Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: _timerPulse, curve: Curves.easeInOut));

    _redShakeAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _redShake = Tween<double>(begin: 0, end: 1).animate(_redShakeAnim);

    _blueShakeAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _blueShake = Tween<double>(begin: 0, end: 1).animate(_blueShakeAnim);

    // Red flash
    _redFlashAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _redFlash = Tween<double>(begin: 0.35, end: 0.0).animate(_redFlashAnim);

    // Blue flash
    _blueFlashAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _blueFlash = Tween<double>(begin: 0.35, end: 0.0).animate(_blueFlashAnim);

    // Red score float
    _redScoreFloatAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _redScoreFloat = Tween<double>(begin: 0, end: -30).animate(
        CurvedAnimation(parent: _redScoreFloatAnim, curve: Curves.easeOut));
    _redScoreOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _redScoreFloatAnim, curve: Curves.easeIn));

    // Blue score float
    _blueScoreFloatAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _blueScoreFloat = Tween<double>(begin: 0, end: -30).animate(
        CurvedAnimation(parent: _blueScoreFloatAnim, curve: Curves.easeOut));
    _blueScoreOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _blueScoreFloatAnim, curve: Curves.easeIn));

    // Snake grow (new segment bounce)
    _redSnakeGrowAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _redSnakeGrow = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _redSnakeGrowAnim, curve: Curves.bounceOut));

    _blueSnakeGrowAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _blueSnakeGrow = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _blueSnakeGrowAnim, curve: Curves.bounceOut));

    _generateBoth();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showStartPopup());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _celebAnim.dispose();
    _pulseAnim.dispose();
    _timerPulse.dispose();
    _redShakeAnim.dispose();
    _blueShakeAnim.dispose();
    _redFlashAnim.dispose();
    _blueFlashAnim.dispose();
    _redScoreFloatAnim.dispose();
    _blueScoreFloatAnim.dispose();
    _redSnakeGrowAnim.dispose();
    _blueSnakeGrowAnim.dispose();
    super.dispose();
  }

  int get _maxNum {
    if (_difficulty == 'EASY') return 20;
    if (_difficulty == 'MEDIUM') return 50;
    return 100;
  }

  void _generateBoth() {
    _generateRedQ();
    _generateBlueQ();
    setState(() {});
  }

  void _generateRedQ() {
    _redNum = 2 + _rand.nextInt(_maxNum - 2);
    _redQType = QType.values[_rand.nextInt(QType.values.length)];
    _redOpts = _makeOpts(_redNum);
    _redSel1 = null;
    _redSel2 = null;
    _redAnswered = false;
    _redCorrect = false;
    _redMsg = '';
    _redShowMsg = false;
  }

  void _generateBlueQ() {
    _blueNum = 2 + _rand.nextInt(_maxNum - 2);
    while (_blueNum == _redNum) _blueNum = 2 + _rand.nextInt(_maxNum - 2);
    _blueQType = QType.values[_rand.nextInt(QType.values.length)];
    _blueOpts = _makeOpts(_blueNum);
    _blueSel1 = null;
    _blueSel2 = null;
    _blueAnswered = false;
    _blueCorrect = false;
    _blueMsg = '';
    _blueShowMsg = false;
  }

  List<int> _makeOpts(int num) {
    // Include both before and after as possible correct answers + 3 wrongs
    final correct1 = num - 1;
    final correct2 = num + 1;
    final opts = <int>{correct1, correct2};
    while (opts.length < 5) {
      int w = max(1, num + _rand.nextInt(11) - 5);
      if (w != correct1 && w != correct2 && w != num) opts.add(w);
    }
    return opts.toList()..shuffle();
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _seconds = 60;
      _redScore = 0;
      _blueScore = 0;
    });
    _generateBoth();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_seconds <= 0) { t.cancel(); _showTimeUp(); }
      else setState(() => _seconds--);
    });
  }

  // ── Red tap ──
  void _onRedTap(int val) {
    if (!_gameStarted || _redAnswered) return;

    if (_redQType == QType.both) {
      if (_redSel1 == null) {
        setState(() => _redSel1 = val);
        return;
      } else if (_redSel2 == null && val != _redSel1) {
        setState(() => _redSel2 = val);
        final correct = (_redSel1 == _redNum - 1 && val == _redNum + 1) ||
            (_redSel1 == _redNum + 1 && val == _redNum - 1);
        _handleRed(correct);
      }
    } else {
      final correct = _redQType == QType.before
          ? val == _redNum - 1
          : val == _redNum + 1;
      setState(() => _redSel1 = val);
      _handleRed(correct);
    }
  }

  void _handleRed(bool correct) {
    setState(() {
      _redAnswered = true;
      _redCorrect = correct;
      _redMsg = correct ? _correctMsg() : _wrongMsg();
      _redShowMsg = true;
    });
    if (correct) {
      setState(() { _redScore++; _redSnakeLen++; });
      _spawnStars();
      _celebAnim.forward(from: 0);
      // Snake eat animations
      _redFlashAnim.forward(from: 0);
      _redSnakeGrowAnim.forward(from: 0);
      setState(() => _showRedFloat = true);
      _redScoreFloatAnim.forward(from: 0).then((_) {
        if (mounted) setState(() => _showRedFloat = false);
      });
      if (_redScore >= _winScore) { _timer?.cancel(); Future.delayed(const Duration(milliseconds: 800), _showWinner); return; }
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) { _generateRedQ(); setState(() {}); }
      });
    } else {
      _redShakeAnim.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) setState(() { _redAnswered = false; _redShowMsg = false; _redSel1 = null; _redSel2 = null; });
      });
    }
  }

  // ── Blue tap ──
  void _onBlueTap(int val) {
    if (!_gameStarted || _blueAnswered) return;

    if (_blueQType == QType.both) {
      if (_blueSel1 == null) {
        setState(() => _blueSel1 = val);
        return;
      } else if (_blueSel2 == null && val != _blueSel1) {
        setState(() => _blueSel2 = val);
        final correct = (_blueSel1 == _blueNum - 1 && val == _blueNum + 1) ||
            (_blueSel1 == _blueNum + 1 && val == _blueNum - 1);
        _handleBlue(correct);
      }
    } else {
      final correct = _blueQType == QType.before
          ? val == _blueNum - 1
          : val == _blueNum + 1;
      setState(() => _blueSel1 = val);
      _handleBlue(correct);
    }
  }

  void _handleBlue(bool correct) {
    setState(() {
      _blueAnswered = true;
      _blueCorrect = correct;
      _blueMsg = correct ? _correctMsg() : _wrongMsg();
      _blueShowMsg = true;
    });
    if (correct) {
      setState(() { _blueScore++; _blueSnakeLen++; });
      _spawnStars();
      _celebAnim.forward(from: 0);
      // Snake eat animations
      _blueFlashAnim.forward(from: 0);
      _blueSnakeGrowAnim.forward(from: 0);
      setState(() => _showBlueFloat = true);
      _blueScoreFloatAnim.forward(from: 0).then((_) {
        if (mounted) setState(() => _showBlueFloat = false);
      });
      if (_blueScore >= _winScore) { _timer?.cancel(); Future.delayed(const Duration(milliseconds: 800), _showWinner); return; }
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) { _generateBlueQ(); setState(() {}); }
      });
    } else {
      _blueShakeAnim.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) setState(() { _blueAnswered = false; _blueShowMsg = false; _blueSel1 = null; _blueSel2 = null; });
      });
    }
  }

  void _spawnStars() {
    final size = MediaQuery.of(context).size;
    _stars.clear();
    for (int i = 0; i < 16; i++) {
      _stars.add(_Star(
        x: _rand.nextDouble() * size.width,
        y: _rand.nextDouble() * size.height,
        emoji: _starEmojis[_rand.nextInt(_starEmojis.length)],
        size: 20 + _rand.nextDouble() * 22,
      ));
    }
  }

  String _correctMsg() {
    final l = ['🎉 Great!','⭐ Amazing!','🌟 Star!','🏆 Yes!','🎊 Super!'];
    return l[_rand.nextInt(l.length)];
  }

  String _wrongMsg() {
    final l = ['💪 Try Again!','🤔 Think!','😊 Try More!'];
    return l[_rand.nextInt(l.length)];
  }

  // ── Question display string ──
  String _qDisplay(int num, QType type, int? sel1, int? sel2) {
    if (type == QType.before) return '?  $num';
    if (type == QType.after) return '$num  ?';
    return '?  $num  ?';
  }

  // ── Popups ──
  void _showStartPopup() {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9800), Color(0xFFFF6B35)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.orange.withValues(alpha: 0.5), blurRadius: 24)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔢', style: TextStyle(fontSize: 36)),
                const SizedBox(height: 4),
                const Text('Before & After!',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Text('? 15   →  Before = 14', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                      Text('15 ?   →  After = 16', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                      Text('? 15 ? →  Both = 14 & 16', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text('🔴 Red Left  •  🔵 Blue Right',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text('Select Difficulty:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 6),
                Row(children: [
                  _diffBtn(setLocal, 'EASY', '1-20', const Color(0xFF4CAF50)),
                  const SizedBox(width: 6),
                  _diffBtn(setLocal, 'MEDIUM', '1-50', const Color(0xFFFFD600)),
                  const SizedBox(width: 6),
                  _diffBtn(setLocal, 'HARD', '1-100', const Color(0xFFFF5252)),
                ]),
                const SizedBox(height: 8),
                const Text('⏱️ 60s  •  First to 10 wins 🏆',
                    style: TextStyle(color: Colors.white70, fontSize: 11)),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () { Navigator.pop(ctx); _startGame(); },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🚀 ', style: TextStyle(fontSize: 18)),
                        Text('Start Game!',
                            style: TextStyle(color: Color(0xFFFF6B35), fontSize: 17, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bgEmoji(String e, double size) => Opacity(
    opacity: 0.25,
    child: Text(e, style: TextStyle(fontSize: size)),
  );

  Widget _diffBtn(StateSetter setLocal, String diff, String range, Color color) {
    final sel = _difficulty == diff;
    return Expanded(
      child: GestureDetector(
        onTap: () => setLocal(() => _difficulty = diff),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: sel ? color : color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: sel ? 2.5 : 1),
          ),
          child: Column(children: [
            Text(diff, style: TextStyle(color: sel ? Colors.white : color, fontSize: 11, fontWeight: FontWeight.w900)),
            Text(range, style: TextStyle(color: sel ? Colors.white70 : color.withValues(alpha: 0.7), fontSize: 10)),
          ]),
        ),
      ),
    );
  }

  void _showTimeUp() {
    final isRed = _redScore > _blueScore;
    final isTie = _redScore == _blueScore;
    final img = isRed ? 'assets/vscodered.png' : 'assets/vscodeblue.png';
    final c1 = isRed ? const Color(0xFFFF6B6B) : const Color(0xFF4ECDC4);
    final c2 = isRed ? const Color(0xFFFF3D00) : const Color(0xFF1E88E5);
    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => _ResultDialog(
        title: "⏰ Time's Up!",
        image: isTie ? null : img,
        message: isRed ? '🔴 Red Team Wins! 🎉' : isTie ? "It's a Draw! 🤝" : '🔵 Blue Team Wins! 🎉',
        redScore: _redScore, blueScore: _blueScore,
        c1: isTie ? const Color(0xFFFF9800) : c1,
        c2: isTie ? const Color(0xFFFF6B35) : c2,
        onHome: () { Navigator.pop(context); Navigator.pop(context); },
        onRestart: () { Navigator.pop(context); _showStartPopup(); },
      ),
    );
  }

  void _showWinner() {
    final isRed = _redScore >= _winScore;
    final img = isRed ? 'assets/vscodered.png' : 'assets/vscodeblue.png';
    final c1 = isRed ? const Color(0xFFFF6B6B) : const Color(0xFF4ECDC4);
    final c2 = isRed ? const Color(0xFFFF3D00) : const Color(0xFF1E88E5);
    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => _ResultDialog(
        title: '🏆 Winner!',
        image: img,
        message: isRed ? '🔴 Red Team Wins! 🎉' : '🔵 Blue Team Wins! 🎉',
        redScore: _redScore, blueScore: _blueScore,
        c1: c1, c2: c2,
        onHome: () { Navigator.pop(context); Navigator.pop(context); },
        onRestart: () { Navigator.pop(context); _showStartPopup(); },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLow = _seconds <= 10;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFE0F7),
              Color(0xFFE0F4FF),
              Color(0xFFFFF9C4),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // ── Fun background emojis ──
              Positioned(top: 10, left: 10, child: _bgEmoji('🌈', 28)),
              Positioned(top: 10, right: 10, child: _bgEmoji('⭐', 26)),
              Positioned(top: 60, left: 30, child: _bgEmoji('🦋', 22)),
              Positioned(top: 60, right: 30, child: _bgEmoji('🌸', 22)),
              Positioned(bottom: 80, left: 8, child: _bgEmoji('🎈', 26)),
              Positioned(bottom: 80, right: 8, child: _bgEmoji('🎀', 24)),
              Positioned(bottom: 30, left: 50, child: _bgEmoji('🌟', 22)),
              Positioned(bottom: 30, right: 50, child: _bgEmoji('🍭', 22)),
              Positioned(top: 140, left: 5, child: _bgEmoji('🐶', 20)),
              Positioned(top: 140, right: 5, child: _bgEmoji('🐱', 20)),
              Positioned(top: 220, left: 15, child: _bgEmoji('🎊', 18)),
              Positioned(top: 220, right: 15, child: _bgEmoji('💫', 18)),
              // Stars
              if (_stars.isNotEmpty)
                AnimatedBuilder(
                  animation: _celebAnim,
                  builder: (_, __) => Stack(
                    children: _stars.map((s) => Positioned(
                      left: s.x, top: s.y * _celebAnim.value * 1.5,
                      child: Opacity(
                        opacity: (1 - _celebAnim.value).clamp(0.0, 1.0),
                        child: Text(s.emoji, style: TextStyle(fontSize: s.size)),
                      ),
                    )).toList(),
                  ),
                ),

              // ── Red flash overlay ──
              AnimatedBuilder(
                animation: _redFlashAnim,
                builder: (_, __) => Positioned(
                  left: 0, top: 0, bottom: 0,
                  width: size.width / 2,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(_redFlash.value),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Blue flash overlay ──
              AnimatedBuilder(
                animation: _blueFlashAnim,
                builder: (_, __) => Positioned(
                  right: 0, top: 0, bottom: 0,
                  width: size.width / 2,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(_blueFlash.value),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                    ),
                  ),
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
                      color: Colors.white.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.grey),
                  ),
                ),
              ),

              Column(
                children: [
                  // ── Top bar ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedBuilder(
                              animation: _pulseAnim,
                              builder: (_, __) => Transform.scale(
                                scale: _pulse.value,
                                child: _ScoreCard(emoji: '🔴', label: 'Red', score: _redScore, color: const Color(0xFFE53935)),
                              ),
                            ),
                            Container(
                              width: 1, height: 36,
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              color: Colors.grey.shade300,
                            ),
                            Column(children: [
                              const SizedBox(height: 2),
                              AnimatedBuilder(
                                animation: _timerPulse,
                                builder: (_, __) => Transform.scale(
                                  scale: isLow && _gameStarted ? _timerScale.value : 1.0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isLow ? Colors.red.shade600 : const Color(0xFFFF9800),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text('⏱ $_seconds',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                                  ),
                                ),
                              ),
                            ]),
                            Container(
                              width: 1, height: 36,
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              color: Colors.grey.shade300,
                            ),
                            AnimatedBuilder(
                              animation: _pulseAnim,
                              builder: (_, __) => Transform.scale(
                                scale: _pulse.value,
                                child: _ScoreCard(emoji: '🔵', label: 'Blue', score: _blueScore, color: const Color(0xFF1E88E5)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Snake bars ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
                    child: Row(
                      children: [
                        // Red snake
                        Expanded(
                          child: Stack(
                            children: [
                              _SnakeBar(length: _redSnakeLen, color: Colors.red, growAnim: _redSnakeGrow),
                              if (_showRedFloat)
                                AnimatedBuilder(
                                  animation: _redScoreFloatAnim,
                                  builder: (_, __) => Positioned(
                                    top: _redScoreFloat.value + 10,
                                    left: 0, right: 0,
                                    child: Opacity(
                                      opacity: _redScoreOpacity.value,
                                      child: const Text('+1', textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.red, fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                              shadows: [Shadow(color: Colors.black26, blurRadius: 4)])),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Blue snake
                        Expanded(
                          child: Stack(
                            children: [
                              _SnakeBar(length: _blueSnakeLen, color: Colors.blue, growAnim: _blueSnakeGrow),
                              if (_showBlueFloat)
                                AnimatedBuilder(
                                  animation: _blueScoreFloatAnim,
                                  builder: (_, __) => Positioned(
                                    top: _blueScoreFloat.value + 10,
                                    left: 0, right: 0,
                                    child: Opacity(
                                      opacity: _blueScoreOpacity.value,
                                      child: const Text('+1', textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.blue, fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                              shadows: [Shadow(color: Colors.black26, blurRadius: 4)])),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),

                  // ── Two team panels ──
                  Expanded(
                    child: Row(
                      children: [
                        // ── RED TEAM LEFT ──
                        Expanded(
                          child: _TeamPanel(
                            teamColor: const Color(0xFFE53935),
                            bgColor: const Color(0xFFFFE5E5),
                            label: '🔴 Red Team',
                            number: _redNum,
                            qType: _redQType,
                            options: _redOpts,
                            sel1: _redSel1,
                            sel2: _redSel2,
                            answered: _redAnswered,
                            correct: _redCorrect,
                            message: _redMsg,
                            showMsg: _redShowMsg,
                            shakeAnim: _redShakeAnim,
                            shake: _redShake,
                            btnColors: _redBtnColors,
                            onTap: _onRedTap,
                            margin: const EdgeInsets.fromLTRB(8, 4, 4, 8),
                          ),
                        ),

                        // ── BLUE TEAM RIGHT ──
                        Expanded(
                          child: _TeamPanel(
                            teamColor: const Color(0xFF1E88E5),
                            bgColor: const Color(0xFFE3F2FD),
                            label: '🔵 Blue Team',
                            number: _blueNum,
                            qType: _blueQType,
                            options: _blueOpts,
                            sel1: _blueSel1,
                            sel2: _blueSel2,
                            answered: _blueAnswered,
                            correct: _blueCorrect,
                            message: _blueMsg,
                            showMsg: _blueShowMsg,
                            shakeAnim: _blueShakeAnim,
                            shake: _blueShake,
                            btnColors: _blueBtnColors,
                            onTap: _onBlueTap,
                            margin: const EdgeInsets.fromLTRB(4, 4, 8, 8),
                          ),
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

// ── Team Panel ────────────────────────────────────────────────────────────────
class _TeamPanel extends StatelessWidget {
  final Color teamColor;
  final Color bgColor;
  final String label;
  final int number;
  final QType qType;
  final List<int> options;
  final int? sel1;
  final int? sel2;
  final bool answered;
  final bool correct;
  final String message;
  final bool showMsg;
  final AnimationController shakeAnim;
  final Animation<double> shake;
  final List<Color> btnColors;
  final void Function(int) onTap;
  final EdgeInsets margin;

  const _TeamPanel({
    required this.teamColor, required this.bgColor, required this.label,
    required this.number, required this.qType, required this.options,
    required this.sel1, required this.sel2,
    required this.answered, required this.correct,
    required this.message, required this.showMsg,
    required this.shakeAnim, required this.shake,
    required this.btnColors, required this.onTap, required this.margin,
  });

  String get _qLabel {
    if (qType == QType.before) return '⬅️ What comes Before?';
    if (qType == QType.after) return '➡️ What comes After?';
    return '↔️ Find Before & After';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: teamColor.withValues(alpha: 0.4), width: 2),
      ),
      child: Column(
        children: [
          // Team label
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: teamColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Text(label, textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
          ),

          // Question type label
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(_qLabel,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: teamColor)),
          ),

          // ── Question display ──
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            child: AnimatedBuilder(
              animation: shakeAnim,
              builder: (_, child) => Transform.translate(
                offset: Offset(showMsg && !correct ? sin(shake.value * pi * 5) * 6 : 0, 0),
                child: child,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Before slot
                  _QSlot(
                    show: qType != QType.after,
                    isAnswer: qType != QType.after,
                    value: qType == QType.after ? number - 1 : null,
                    selected: qType == QType.both ? sel1 : (qType == QType.before ? sel1 : null),
                    color: teamColor,
                    label: 'Before',
                  ),
                  const SizedBox(width: 6),
                  // Main number
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: teamColor, width: 2.5),
                      boxShadow: [BoxShadow(color: teamColor.withValues(alpha: 0.3), blurRadius: 8)],
                    ),
                    child: Center(
                      child: Text('$number',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: teamColor)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // After slot
                  _QSlot(
                    show: qType != QType.before,
                    isAnswer: qType != QType.before,
                    value: qType == QType.before ? number + 1 : null,
                    selected: qType == QType.both ? sel2 : (qType == QType.after ? sel1 : null),
                    color: teamColor,
                    label: 'After',
                  ),
                ],
              ),
            ),
          ),

          // Both mode hint
          if (qType == QType.both)
            Text(
              sel1 == null ? '👆 Tap Before first' : '👆 Now tap After',
              style: TextStyle(fontSize: 10, color: teamColor, fontWeight: FontWeight.w700),
            ),

          // Feedback
          AnimatedOpacity(
            opacity: showMsg ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: correct ? const Color(0xFF4CAF50) : const Color(0xFFFF5252),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(message.isEmpty ? ' ' : message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
            ),
          ),

          const Spacer(),

          // ── Answer buttons ──
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
            child: Column(
              children: [
                // Row 1 — 3 buttons
                Row(
                  children: List.generate(3, (i) {
                    final opt = options[i];
                    final isSel = sel1 == opt || sel2 == opt;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: SizedBox(
                          height: 46,
                          child: _AnsBtn(
                            value: opt,
                            color: btnColors[i],
                            selected: isSel,
                            locked: answered,
                            onTap: () => onTap(opt),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 4),
                // Row 2 — 2 buttons
                Row(
                  children: List.generate(2, (i) {
                    final opt = options[3 + i];
                    final isSel = sel1 == opt || sel2 == opt;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: SizedBox(
                          height: 46,
                          child: _AnsBtn(
                            value: opt,
                            color: btnColors[3 + i],
                            selected: isSel,
                            locked: answered,
                            onTap: () => onTap(opt),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Question Slot ─────────────────────────────────────────────────────────────
class _QSlot extends StatelessWidget {
  final bool show;
  final bool isAnswer;
  final int? value;
  final int? selected;
  final Color color;
  final String label;

  const _QSlot({
    required this.show, required this.isAnswer,
    this.value, this.selected,
    required this.color, required this.label,
  });

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox(width: 52);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 2),
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: isAnswer
                ? (selected != null ? color : color.withValues(alpha: 0.1))
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 2),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 6)],
          ),
          child: Center(
            child: Text(
              isAnswer ? (selected != null ? '$selected' : '?') : '${value ?? ''}',
              style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w900,
                color: isAnswer ? (selected != null ? Colors.white : color) : color,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Score Card ────────────────────────────────────────────────────────────────
class _ScoreCard extends StatelessWidget {
  final String emoji;
  final String label;
  final int score;
  final Color color;

  const _ScoreCard({required this.emoji, required this.label, required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 4),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
          Text('$score', style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900, height: 1)),
        ]),
      ]),
    );
  }
}

// ── Answer Button ─────────────────────────────────────────────────────────────
class _AnsBtn extends StatelessWidget {
  final int value;
  final Color color;
  final VoidCallback onTap;
  final bool selected;
  final bool locked;

  const _AnsBtn({
    required this.value, required this.color,
    required this.onTap, required this.selected, required this.locked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: locked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: selected ? color : (locked ? color.withValues(alpha: 0.3) : color),
          borderRadius: BorderRadius.circular(14),
          border: selected ? Border.all(color: Colors.white, width: 2.5) : null,
          boxShadow: locked ? [] : [BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: 6, offset: const Offset(0, 3))],
        ),
        child: Center(
          child: Text('$value',
              style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w900,
                color: locked && !selected ? Colors.white54 : Colors.white,
                shadows: const [Shadow(color: Colors.black26, blurRadius: 3, offset: Offset(1, 1))],
              )),
        ),
      ),
    );
  }
}

// ── Result Dialog ─────────────────────────────────────────────────────────────
class _ResultDialog extends StatelessWidget {
  final String title;
  final String? image;
  final String message;
  final int redScore, blueScore;
  final Color c1, c2;
  final VoidCallback onHome, onRestart;

  const _ResultDialog({
    required this.title, this.image, required this.message,
    required this.redScore, required this.blueScore,
    required this.c1, required this.c2,
    required this.onHome, required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [c1, c2], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: c1.withValues(alpha: 0.5), blurRadius: 28)],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(image!, height: 130, fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Text('🏆', style: TextStyle(fontSize: 60))),
            ),
          if (image == null) const Text('🤝', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
          Text(message, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _chip('🔴', redScore), const SizedBox(width: 16), _chip('🔵', blueScore),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _btn('🏠 Home', Colors.white.withValues(alpha: 0.3), onHome)),
            const SizedBox(width: 10),
            Expanded(child: _btn('🔄 Restart', Colors.white, onRestart, textColor: c2)),
          ]),
        ]),
      ),
    );
  }

  Widget _chip(String e, int s) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white38),
    ),
    child: Column(children: [
      Text(e, style: const TextStyle(fontSize: 18)),
      Text('$s', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
    ]),
  );

  Widget _btn(String label, Color color, VoidCallback onTap, {Color textColor = Colors.white}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8)]),
          child: Text(label, textAlign: TextAlign.center,
              style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w900)),
        ),
      );
}

// ── Snake Bar ────────────────────────────────────────────────────────────────────────────
class _SnakeBar extends StatelessWidget {
  final int length;
  final Color color;
  final Animation<double> growAnim;
  const _SnakeBar({required this.length, required this.color, required this.growAnim});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: growAnim,
      builder: (_, __) {
        return SizedBox(
          height: 18,
          child: Row(
            children: List.generate(length, (i) {
              final isNew = i == length - 1;
              final scale = isNew ? growAnim.value : 1.0;
              return Expanded(
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: BoxDecoration(
                      color: i == 0
                          ? color
                          : color.withOpacity(0.5 + (i / length) * 0.5),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: i == 0
                          ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)]
                          : [],
                    ),
                    child: i == 0
                        ? Center(
                            child: Text('👀',
                                style: TextStyle(fontSize: 10)),
                          )
                        : null,
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

// ── Star ──────────────────────────────────────────────────────────────────────
class _Star {
  final double x, y, size;
  final String emoji;
  const _Star({required this.x, required this.y, required this.emoji, required this.size});
}
