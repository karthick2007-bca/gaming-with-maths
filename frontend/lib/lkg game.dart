import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// ── Number to word map (1–20) ─────────────────────────────────────────────────
const Map<int, String> _numWords = {
  1: 'One', 2: 'Two', 3: 'Three', 4: 'Four', 5: 'Five',
  6: 'Six', 7: 'Seven', 8: 'Eight', 9: 'Nine', 10: 'Ten',
  11: 'Eleven', 12: 'Twelve', 13: 'Thirteen', 14: 'Fourteen', 15: 'Fifteen',
  16: 'Sixteen', 17: 'Seventeen', 18: 'Eighteen', 19: 'Nineteen', 20: 'Twenty',
  21: 'Twenty One', 22: 'Twenty Two', 23: 'Twenty Three', 24: 'Twenty Four',
  25: 'Twenty Five', 26: 'Twenty Six', 27: 'Twenty Seven', 28: 'Twenty Eight',
  29: 'Twenty Nine', 30: 'Thirty', 31: 'Thirty One', 32: 'Thirty Two',
  33: 'Thirty Three', 34: 'Thirty Four', 35: 'Thirty Five', 36: 'Thirty Six',
  37: 'Thirty Seven', 38: 'Thirty Eight', 39: 'Thirty Nine', 40: 'Forty',
  41: 'Forty One', 42: 'Forty Two', 43: 'Forty Three', 44: 'Forty Four',
  45: 'Forty Five', 46: 'Forty Six', 47: 'Forty Seven', 48: 'Forty Eight',
  49: 'Forty Nine', 50: 'Fifty',
};

class LkgNumberGame extends StatefulWidget {
  const LkgNumberGame({super.key});

  @override
  State<LkgNumberGame> createState() => _LkgNumberGameState();
}

class _LkgNumberGameState extends State<LkgNumberGame>
    with TickerProviderStateMixin {
  final _rand = Random();

  int _redScore = 0;
  int _blueScore = 0;
  bool _gameStarted = false;
  static const int _winScore = 10;

  // Red team question
  int _redNumber = 0;
  List<int> _redOptions = [];
  String _redMessage = '';
  bool _redShowMsg = false;
  bool _redCorrect = false;

  // Blue team question
  int _blueNumber = 0;
  List<int> _blueOptions = [];
  String _blueMessage = '';
  bool _blueShowMsg = false;
  bool _blueCorrect = false;

  // Timer
  int _seconds = 50;
  Timer? _timer;

  late AnimationController _redNumberAnim;
  late AnimationController _blueNumberAnim;
  late AnimationController _redShakeAnim;
  late AnimationController _blueShakeAnim;
  late AnimationController _pulseAnim;
  late AnimationController _timerPulse;
  late AnimationController _celebAnim;

  late Animation<double> _redScale;
  late Animation<double> _blueScale;
  late Animation<double> _redShake;
  late Animation<double> _blueShake;
  late Animation<double> _pulse;
  late Animation<double> _timerScale;

  final List<_Star> _stars = [];
  final List<String> _starEmojis = ['⭐', '🌟', '✨', '🎉', '🎊', '🎈', '💫'];

  // Button colors
  final List<Color> _redBtnColors = [
    Color(0xFFFF6B9D), Color(0xFFFF8C94), Color(0xFFFFB347),
  ];
  final List<Color> _blueBtnColors = [
    Color(0xFF4ECDC4), Color(0xFF64B5F6), Color(0xFFA8E6CF),
  ];

  @override
  void initState() {
    super.initState();

    _redNumberAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _redScale = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _redNumberAnim, curve: Curves.elasticOut));

    _blueNumberAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _blueScale = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _blueNumberAnim, curve: Curves.elasticOut));

    _redShakeAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _redShake = Tween<double>(begin: 0, end: 1).animate(_redShakeAnim);

    _blueShakeAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _blueShake = Tween<double>(begin: 0, end: 1).animate(_blueShakeAnim);

    _pulseAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.06).animate(
        CurvedAnimation(parent: _pulseAnim, curve: Curves.easeInOut));

    _timerPulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..repeat(reverse: true);
    _timerScale = Tween<double>(begin: 1.0, end: 1.25).animate(
        CurvedAnimation(parent: _timerPulse, curve: Curves.easeInOut));

    _celebAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _celebAnim.addStatusListener(
        (s) { if (s == AnimationStatus.completed) setState(() => _stars.clear()); });

    _generateBoth();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showStartPopup());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _redNumberAnim.dispose();
    _blueNumberAnim.dispose();
    _redShakeAnim.dispose();
    _blueShakeAnim.dispose();
    _pulseAnim.dispose();
    _timerPulse.dispose();
    _celebAnim.dispose();
    super.dispose();
  }

  // ── Generate different numbers for each team ──
  void _generateBoth() {
    _redNumber = _rand.nextInt(50) + 1;
    do {
      _blueNumber = _rand.nextInt(50) + 1;
    } while (_blueNumber == _redNumber);

    _redOptions = _generateOptions(_redNumber);
    _blueOptions = _generateOptions(_blueNumber);
    _redMessage = '';
    _blueMessage = '';
    _redShowMsg = false;
    _blueShowMsg = false;
    setState(() {});
    _redNumberAnim.forward(from: 0);
    _blueNumberAnim.forward(from: 0);
  }

  void _generateRedQuestion() {
    _redNumber = _rand.nextInt(50) + 1;
    while (_redNumber == _blueNumber) _redNumber = _rand.nextInt(50) + 1;
    _redOptions = _generateOptions(_redNumber);
    _redMessage = '';
    _redShowMsg = false;
    setState(() {});
    _redNumberAnim.forward(from: 0);
  }

  void _generateBlueQuestion() {
    _blueNumber = _rand.nextInt(50) + 1;
    while (_blueNumber == _redNumber) _blueNumber = _rand.nextInt(50) + 1;
    _blueOptions = _generateOptions(_blueNumber);
    _blueMessage = '';
    _blueShowMsg = false;
    setState(() {});
    _blueNumberAnim.forward(from: 0);
  }

  List<int> _generateOptions(int correct) {
    final opts = <int>{correct};
    while (opts.length < 3) {
      final wrong = _rand.nextInt(50) + 1;
      if (wrong != correct) opts.add(wrong);
    }
    return opts.toList()..shuffle();
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _seconds = 50;
      _redScore = 0;
      _blueScore = 0;
    });
    _generateBoth();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_seconds <= 0) {
        t.cancel();
        _showTimeUp();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  void _onRedTap(int val) {
    if (_redShowMsg || !_gameStarted) return;
    if (val == _redNumber) {
      setState(() {
        _redScore++;
        _redCorrect = true;
        _redMessage = _correctMsg();
        _redShowMsg = true;
      });
      _spawnStars();
      _celebAnim.forward(from: 0);
      if (_redScore >= _winScore) { _timer?.cancel(); Future.delayed(const Duration(milliseconds: 800), _showWinner); return; }
      Future.delayed(const Duration(milliseconds: 1100), () {
        if (mounted) _generateRedQuestion();
      });
    } else {
      setState(() { _redCorrect = false; _redMessage = _wrongMsg(); _redShowMsg = true; });
      _redShakeAnim.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) setState(() => _redShowMsg = false);
      });
    }
  }

  void _onBlueTap(int val) {
    if (_blueShowMsg || !_gameStarted) return;
    if (val == _blueNumber) {
      setState(() {
        _blueScore++;
        _blueCorrect = true;
        _blueMessage = _correctMsg();
        _blueShowMsg = true;
      });
      _spawnStars();
      _celebAnim.forward(from: 0);
      if (_blueScore >= _winScore) { _timer?.cancel(); Future.delayed(const Duration(milliseconds: 800), _showWinner); return; }
      Future.delayed(const Duration(milliseconds: 1100), () {
        if (mounted) _generateBlueQuestion();
      });
    } else {
      setState(() { _blueCorrect = false; _blueMessage = _wrongMsg(); _blueShowMsg = true; });
      _blueShakeAnim.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) setState(() => _blueShowMsg = false);
      });
    }
  }

  void _spawnStars() {
    _stars.clear();
    for (int i = 0; i < 16; i++) {
      _stars.add(_Star(
        x: _rand.nextDouble(),
        y: _rand.nextDouble(),
        emoji: _starEmojis[_rand.nextInt(_starEmojis.length)],
        size: 18 + _rand.nextDouble() * 22,
      ));
    }
  }

  String _correctMsg() {
    final msgs = ['🎉 Great!', '⭐ Amazing!', '🌟 Star!', '🏆 Awesome!', '🎊 Yes!'];
    return msgs[_rand.nextInt(msgs.length)];
  }

  String _wrongMsg() {
    final msgs = ['💪 Try Again!', '🤔 Almost!', '😊 Try!'];
    return msgs[_rand.nextInt(msgs.length)];
  }

  void _showStartPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7B61FF), Color(0xFFFF6FB7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.5), blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔢', style: TextStyle(fontSize: 36)),
              const SizedBox(height: 4),
              const Text('LKG Numbers!',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🔴', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 4),
                        Text('Red Top  •  🔵 Blue Bottom',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text('⏱️ 50s  •  First to 10 wins 🏆',
                        style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () { Navigator.pop(context); _startGame(); },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.4), blurRadius: 10)],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🚀 ', style: TextStyle(fontSize: 18)),
                      Text('Start Game!',
                          style: TextStyle(color: Color(0xFF7B61FF), fontSize: 16, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTimeUp() {
    final isRedWin = _redScore > _blueScore;
    final isTie = _redScore == _blueScore;
    final winImage = isRedWin ? 'assets/vscodered.png' : 'assets/vscodeblue.png';
    final winColor1 = isRedWin ? const Color(0xFFFF6B6B) : const Color(0xFF4ECDC4);
    final winColor2 = isRedWin ? const Color(0xFFFF3D00) : const Color(0xFF1E88E5);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isTie
                  ? [const Color(0xFFFF9800), const Color(0xFFFF6B35)]
                  : [winColor1, winColor2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(
                color: (isTie ? Colors.orange : winColor1).withOpacity(0.5),
                blurRadius: 30)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⏰', style: TextStyle(fontSize: 48)),
              const Text("Time's Up!",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              if (!isTie)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    winImage,
                    height: 140,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Text('🏆', style: TextStyle(fontSize: 60)),
                  ),
                ),
              if (isTie) const Text('🤝', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 8),
              Text(
                isRedWin ? '🔴 Red Team Wins! 🎉'
                    : isTie ? "It's a Draw! 🤝"
                    : '🔵 Blue Team Wins! 🎉',
                style: const TextStyle(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _scoreChip('🔴', _redScore),
                  const SizedBox(width: 16),
                  _scoreChip('🔵', _blueScore),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _dialogBtn('🏠 Home', Colors.white.withOpacity(0.3), () {
                    Navigator.pop(context); Navigator.pop(context);
                  })),
                  const SizedBox(width: 10),
                  Expanded(child: _dialogBtn('🔄 Restart', Colors.white, () {
                    Navigator.pop(context); _startGame();
                  }, textColor: isTie ? const Color(0xFFFF6B35) : winColor2)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWinner() {
    final isRedWin = _redScore >= _winScore;
    final winner = isRedWin ? '🔴 Red Team' : '🔵 Blue Team';
    final winImage = isRedWin ? 'assets/vscodered.png' : 'assets/vscodeblue.png';
    final winColor1 = isRedWin ? const Color(0xFFFF6B6B) : const Color(0xFF4ECDC4);
    final winColor2 = isRedWin ? const Color(0xFFFF3D00) : const Color(0xFF1E88E5);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [winColor1, winColor2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: winColor1.withOpacity(0.5), blurRadius: 30)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Winner image
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  winImage,
                  height: 180,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      Text('🏆', style: TextStyle(fontSize: 80)),
                ),
              ),
              const SizedBox(height: 10),
              const Text('🏆 Winner! 🏆',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(winner,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text('$_redScore 🔴  vs  🔵 $_blueScore',
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              const Text('🎊 🎈 🌟 🎉 🌟 🎈 🎊', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _dialogBtn('🏠 Home', Colors.white.withOpacity(0.3), () {
                    Navigator.pop(context); Navigator.pop(context);
                  })),
                  const SizedBox(width: 10),
                  Expanded(child: _dialogBtn('🔄 Restart', Colors.white, () {
                    Navigator.pop(context); _startGame();
                  }, textColor: winColor2)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scoreChip(String emoji, int score) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white38),
    ),
    child: Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        Text('$score', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
      ],
    ),
  );

  Widget _dialogBtn(String label, Color color, VoidCallback onTap,
      {Color textColor = Colors.white}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8)],
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w900)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLow = _seconds <= 10;

    return Scaffold(
      body: Stack(
        children: [
          // ── Background ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFE5E5), Color(0xFFE3F2FD)],
              ),
            ),
          ),

          // ── Divider line center ──
          Positioned(
            top: size.height * 0.5 - 2,
            left: 0, right: 0,
            child: Container(height: 4, color: Colors.white.withOpacity(0.6)),
          ),

          // ── Celebration stars ──
          if (_stars.isNotEmpty)
            AnimatedBuilder(
              animation: _celebAnim,
              builder: (_, __) => Stack(
                children: _stars.map((s) => Positioned(
                  left: s.x * size.width,
                  top: s.y * size.height * _celebAnim.value * 1.5,
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

          SafeArea(
            child: Column(
              children: [
                // ══════════════ TOP BAR ══════════════
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                          _MiniScore(emoji: '🔴', score: _redScore, color: const Color(0xFFE53935)),
                          Container(
                            width: 1, height: 36,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            color: Colors.grey.shade300,
                          ),
                          AnimatedBuilder(
                            animation: _timerPulse,
                            builder: (_, __) => Transform.scale(
                              scale: isLow && _gameStarted ? _timerScale.value : 1.0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isLow ? Colors.red.shade600 : const Color(0xFF7B61FF),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [BoxShadow(
                                    color: (isLow ? Colors.red : Colors.purple).withOpacity(0.4),
                                    blurRadius: 8,
                                  )],
                                ),
                                child: Text('⏱ $_seconds',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                              ),
                            ),
                          ),
                          Container(
                            width: 1, height: 36,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            color: Colors.grey.shade300,
                          ),
                          _MiniScore(emoji: '🔵', score: _blueScore, color: const Color(0xFF1E88E5)),
                        ],
                      ),
                    ),
                  ),
                ),

                // ══════════════ MAIN GAME AREA ══════════════
                Expanded(
                  child: Row(
                    children: [
                      // ── RED TEAM (LEFT) ──
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(8, 0, 4, 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE5E5).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFE53935).withOpacity(0.4), width: 2),
                          ),
                          child: Column(
                            children: [
                              // Red label top
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE53935),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(22),
                                    topRight: Radius.circular(22),
                                  ),
                                ),
                                child: const Text('🔴 Red Team',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                              ),

                              // Number display center
                              Expanded(
                                child: Center(
                                  child: ScaleTransition(
                                    scale: _redScale,
                                    child: AnimatedBuilder(
                                      animation: _redShakeAnim,
                                      builder: (_, child) => Transform.translate(
                                        offset: Offset(
                                          _redShowMsg && !_redCorrect ? sin(_redShake.value * pi * 6) * 8 : 0, 0),
                                        child: child,
                                      ),
                                      child: Container(
                                        width: 110,
                                        height: 110,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          border: Border.all(color: const Color(0xFFE53935), width: 3),
                                          boxShadow: [BoxShadow(
                                            color: Colors.red.withOpacity(0.25),
                                            blurRadius: 16, spreadRadius: 3,
                                          )],
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('$_redNumber',
                                                style: const TextStyle(
                                                    fontSize: 44, fontWeight: FontWeight.w900,
                                                    color: Color(0xFFE53935), height: 1)),
                                            Text(_numWords[_redNumber] ?? '',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontSize: 9, fontWeight: FontWeight.w700,
                                                    color: Color(0xFFE53935))),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Feedback
                              AnimatedOpacity(
                                opacity: _redShowMsg ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 200),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _redCorrect ? const Color(0xFF4CAF50) : const Color(0xFFFF5252),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _redMessage.isEmpty ? ' ' : _redMessage,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ),

                              // Red answer buttons — BOTTOM
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
                                child: Column(
                                  children: List.generate(3, (i) {
                                    final opt = _redOptions[i];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: _SpellingButton(
                                        word: _numWords[opt] ?? '$opt',
                                        color: _redBtnColors[i],
                                        onTap: () => _onRedTap(opt),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── BLUE TEAM (RIGHT) ──
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(4, 0, 8, 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFF1E88E5).withOpacity(0.4), width: 2),
                          ),
                          child: Column(
                            children: [
                              // Blue label top
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1E88E5),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(22),
                                    topRight: Radius.circular(22),
                                  ),
                                ),
                                child: const Text('🔵 Blue Team',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                              ),

                              // Number display center
                              Expanded(
                                child: Center(
                                  child: ScaleTransition(
                                    scale: _blueScale,
                                    child: AnimatedBuilder(
                                      animation: _blueShakeAnim,
                                      builder: (_, child) => Transform.translate(
                                        offset: Offset(
                                          _blueShowMsg && !_blueCorrect ? sin(_blueShake.value * pi * 6) * 8 : 0, 0),
                                        child: child,
                                      ),
                                      child: Container(
                                        width: 110,
                                        height: 110,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          border: Border.all(color: const Color(0xFF1E88E5), width: 3),
                                          boxShadow: [BoxShadow(
                                            color: Colors.blue.withOpacity(0.25),
                                            blurRadius: 16, spreadRadius: 3,
                                          )],
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('$_blueNumber',
                                                style: const TextStyle(
                                                    fontSize: 44, fontWeight: FontWeight.w900,
                                                    color: Color(0xFF1E88E5), height: 1)),
                                            Text(_numWords[_blueNumber] ?? '',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontSize: 9, fontWeight: FontWeight.w700,
                                                    color: Color(0xFF1E88E5))),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Feedback
                              AnimatedOpacity(
                                opacity: _blueShowMsg ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 200),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _blueCorrect ? const Color(0xFF4CAF50) : const Color(0xFFFF5252),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _blueMessage.isEmpty ? ' ' : _blueMessage,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ),

                              // Blue answer buttons — BOTTOM
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
                                child: Column(
                                  children: List.generate(3, (i) {
                                    final opt = _blueOptions[i];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: _SpellingButton(
                                        word: _numWords[opt] ?? '$opt',
                                        color: _blueBtnColors[i],
                                        onTap: () => _onBlueTap(opt),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mini Score Badge ──────────────────────────────────────────────────────────
class _MiniScore extends StatelessWidget {
  final String emoji;
  final int score;
  final Color color;
  const _MiniScore({required this.emoji, required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text('$score',
              style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

// ── Spelling Button ───────────────────────────────────────────────────────────
class _SpellingButton extends StatelessWidget {
  final String word;
  final Color color;
  final VoidCallback onTap;

  const _SpellingButton({
    required this.word,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 46,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: color.withOpacity(0.45), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              word,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black26, blurRadius: 3, offset: Offset(1, 1))],
              ),
            ),
          ),
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
