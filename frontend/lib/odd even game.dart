import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class OddEvenGamePage extends StatefulWidget {
  const OddEvenGamePage({super.key});
  @override
  State<OddEvenGamePage> createState() => _OddEvenGamePageState();
}

class _OddEvenGamePageState extends State<OddEvenGamePage>
    with TickerProviderStateMixin {
  final _rand = Random();

  int _redScore = 0;
  int _blueScore = 0;
  bool _gameStarted = false;
  static const int _winScore = 10;

  int _redNum = 0;
  int _blueNum = 0;

  bool _redShowMsg = false;
  bool _blueShowMsg = false;
  bool _redCorrect = false;
  bool _blueCorrect = false;
  String _redMsg = '';
  String _blueMsg = '';

  int _seconds = 60;
  Timer? _timer;

  late AnimationController _celebAnim;
  late AnimationController _pulseAnim;
  late AnimationController _timerPulse;
  late AnimationController _redNumAnim;
  late AnimationController _blueNumAnim;
  late AnimationController _redShakeAnim;
  late AnimationController _blueShakeAnim;

  late Animation<double> _pulse;
  late Animation<double> _timerScale;
  late Animation<double> _redNumScale;
  late Animation<double> _blueNumScale;
  late Animation<double> _redShake;
  late Animation<double> _blueShake;

  final List<_Star> _stars = [];
  final List<String> _starEmojis = ['⭐','🌟','✨','🎉','🎊','🎈','💫','🌈'];

  @override
  void initState() {
    super.initState();

    _celebAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _celebAnim.addStatusListener((s) {
      if (s == AnimationStatus.completed) setState(() => _stars.clear());
    });

    _pulseAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.06).animate(
        CurvedAnimation(parent: _pulseAnim, curve: Curves.easeInOut));

    _timerPulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
      ..repeat(reverse: true);
    _timerScale = Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: _timerPulse, curve: Curves.easeInOut));

    _redNumAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _redNumScale = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _redNumAnim, curve: Curves.elasticOut));

    _blueNumAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _blueNumScale = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _blueNumAnim, curve: Curves.elasticOut));

    _redShakeAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _redShake = Tween<double>(begin: 0, end: 1).animate(_redShakeAnim);

    _blueShakeAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _blueShake = Tween<double>(begin: 0, end: 1).animate(_blueShakeAnim);

    _generateBoth();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showStartPopup());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _celebAnim.dispose();
    _pulseAnim.dispose();
    _timerPulse.dispose();
    _redNumAnim.dispose();
    _blueNumAnim.dispose();
    _redShakeAnim.dispose();
    _blueShakeAnim.dispose();
    super.dispose();
  }

  void _generateBoth() {
    _redNum = _rand.nextInt(100) + 1;
    do { _blueNum = _rand.nextInt(100) + 1; } while (_blueNum == _redNum);
    _redShowMsg = _blueShowMsg = false;
    _redMsg = _blueMsg = '';
    setState(() {});
    _redNumAnim.forward(from: 0);
    _blueNumAnim.forward(from: 0);
  }

  void _generateRed() {
    _redNum = _rand.nextInt(100) + 1;
    while (_redNum == _blueNum) _redNum = _rand.nextInt(100) + 1;
    _redShowMsg = false; _redMsg = '';
    setState(() {});
    _redNumAnim.forward(from: 0);
  }

  void _generateBlue() {
    _blueNum = _rand.nextInt(100) + 1;
    while (_blueNum == _redNum) _blueNum = _rand.nextInt(100) + 1;
    _blueShowMsg = false; _blueMsg = '';
    setState(() {});
    _blueNumAnim.forward(from: 0);
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

  void _onRedTap(bool isOdd) {
    if (_redShowMsg || !_gameStarted) return;
    final correct = (_redNum % 2 != 0) == isOdd;
    if (correct) {
      setState(() { _redScore++; _redCorrect = true; _redMsg = _correctMsg(); _redShowMsg = true; });
      _spawnStars();
      _celebAnim.forward(from: 0);
      if (_redScore >= _winScore) { _timer?.cancel(); Future.delayed(const Duration(milliseconds: 800), _showWinner); return; }
      Future.delayed(const Duration(milliseconds: 1100), () { if (mounted) _generateRed(); });
    } else {
      setState(() { _redCorrect = false; _redMsg = _wrongMsg(); _redShowMsg = true; });
      _redShakeAnim.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 900), () { if (mounted) setState(() => _redShowMsg = false); });
    }
  }

  void _onBlueTap(bool isOdd) {
    if (_blueShowMsg || !_gameStarted) return;
    final correct = (_blueNum % 2 != 0) == isOdd;
    if (correct) {
      setState(() { _blueScore++; _blueCorrect = true; _blueMsg = _correctMsg(); _blueShowMsg = true; });
      _spawnStars();
      _celebAnim.forward(from: 0);
      if (_blueScore >= _winScore) { _timer?.cancel(); Future.delayed(const Duration(milliseconds: 800), _showWinner); return; }
      Future.delayed(const Duration(milliseconds: 1100), () { if (mounted) _generateBlue(); });
    } else {
      setState(() { _blueCorrect = false; _blueMsg = _wrongMsg(); _blueShowMsg = true; });
      _blueShakeAnim.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 900), () { if (mounted) setState(() => _blueShowMsg = false); });
    }
  }

  void _spawnStars() {
    final size = MediaQuery.of(context).size;
    _stars.clear();
    for (int i = 0; i < 18; i++) {
      _stars.add(_Star(
        x: _rand.nextDouble() * size.width,
        y: _rand.nextDouble() * size.height,
        emoji: _starEmojis[_rand.nextInt(_starEmojis.length)],
        size: 18 + _rand.nextDouble() * 24,
      ));
    }
  }

  String _correctMsg() {
    final l = ['🎉 Correct!', '⭐ Amazing!', '🌟 Yes!', '🏆 Great!', '🎊 Super!'];
    return l[_rand.nextInt(l.length)];
  }

  String _wrongMsg() {
    final l = ['💪 Try Again!', '🤔 Think!', '😊 Almost!'];
    return l[_rand.nextInt(l.length)];
  }

  // ── Popups ────────────────────────────────────────────────────────────────
  void _showStartPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7B61FF), Color(0xFF11998E)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.5), blurRadius: 24)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔢', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 6),
              const Text('Odd & Even!',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Column(children: [
                  Text('ODD = 1, 3, 5, 7, 9... (cannot be divided by 2)',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                  SizedBox(height: 4),
                  Text('EVEN = 2, 4, 6, 8, 10... (can be divided by 2)',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                ]),
              ),
              const SizedBox(height: 10),
              const Text('🔴 Red Left  •  🔵 Blue Right',
                  style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700)),
              const Text('⏱️ 60s  •  First to 10 wins 🏆',
                  style: TextStyle(color: Colors.white60, fontSize: 11)),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () { Navigator.pop(context); _startGame(); },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('🚀 ', style: TextStyle(fontSize: 18)),
                    Text('Start Game!',
                        style: TextStyle(color: Color(0xFF7B61FF), fontSize: 17, fontWeight: FontWeight.w900)),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTimeUp() {
    final isRed = _redScore > _blueScore;
    final isTie = _redScore == _blueScore;
    final c1 = isRed ? const Color(0xFFFF6B6B) : const Color(0xFF4ECDC4);
    final c2 = isRed ? const Color(0xFFFF3D00) : const Color(0xFF1E88E5);
    _showResultDialog(
      title: "⏰ Time's Up!",
      message: isRed ? '🔴 Red Team Wins! 🎉' : isTie ? "It's a Draw! 🤝" : '🔵 Blue Team Wins! 🎉',
      c1: isTie ? const Color(0xFFFF9800) : c1,
      c2: isTie ? const Color(0xFFFF6B35) : c2,
    );
  }

  void _showWinner() {
    final isRed = _redScore >= _winScore;
    final c1 = isRed ? const Color(0xFFFF6B6B) : const Color(0xFF4ECDC4);
    final c2 = isRed ? const Color(0xFFFF3D00) : const Color(0xFF1E88E5);
    _showResultDialog(
      title: '🏆 Winner!',
      message: isRed ? '🔴 Red Team Wins! 🎉' : '🔵 Blue Team Wins! 🎉',
      c1: c1, c2: c2,
    );
  }

  void _showResultDialog({required String title, required String message, required Color c1, required Color c2}) {
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
            const Text('🏆', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
            Text(message, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _chip('🔴', _redScore), const SizedBox(width: 16), _chip('🔵', _blueScore),
            ]),
            const SizedBox(height: 6),
            const Text('🎊 🎈 🌟 🎉 🌟 🎈 🎊', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
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

  Widget _chip(String e, int s) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white38)),
    child: Column(children: [
      Text(e, style: const TextStyle(fontSize: 20)),
      Text('$s', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
    ]),
  );

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

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLow = _seconds <= 10;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFFF3E5FF), Color(0xFFE8F5E9)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
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
                      boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.grey),
                  ),
                ),
              ),

              Column(
                children: [
                  // ── Scoreboard ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 6)],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedBuilder(
                              animation: _pulseAnim,
                              builder: (_, __) => Transform.scale(
                                scale: _pulse.value,
                                child: _ScoreCard(emoji: '🔴', label: 'Red Team', score: _redScore, color: const Color(0xFFE53935)),
                              ),
                            ),
                            Container(width: 1, height: 36, margin: const EdgeInsets.symmetric(horizontal: 10), color: Colors.grey.shade300),
                            AnimatedBuilder(
                              animation: _timerPulse,
                              builder: (_, __) => Transform.scale(
                                scale: isLow && _gameStarted ? _timerScale.value : 1.0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isLow ? Colors.red.shade600 : const Color(0xFF7B61FF),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [BoxShadow(color: (isLow ? Colors.red : Colors.purple).withOpacity(0.4), blurRadius: 6)],
                                  ),
                                  child: Text('⏱ $_seconds',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                                ),
                              ),
                            ),
                            Container(width: 1, height: 36, margin: const EdgeInsets.symmetric(horizontal: 10), color: Colors.grey.shade300),
                            AnimatedBuilder(
                              animation: _pulseAnim,
                              builder: (_, __) => Transform.scale(
                                scale: _pulse.value,
                                child: _ScoreCard(emoji: '🔵', label: 'Blue Team', score: _blueScore, color: const Color(0xFF1E88E5)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Two team panels ──
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── RED TEAM ──
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(8, 0, 4, 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE5E5),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFFE53935).withOpacity(0.35), width: 2),
                              boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.1), blurRadius: 10)],
                            ),
                            child: Column(
                              children: [
                                // Header
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE53935),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(22), topRight: Radius.circular(22)),
                                  ),
                                  child: const Text('🔴 Red Team', textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                                ),

                                // Question area
                                Expanded(
                                  child: _QuestionArea(
                                    number: _redNum,
                                    numScale: _redNumScale,
                                    shakeAnim: _redShakeAnim,
                                    shake: _redShake,
                                    showMsg: _redShowMsg,
                                    correct: _redCorrect,
                                    msg: _redMsg,
                                    teamColor: const Color(0xFFE53935),
                                  ),
                                ),

                                // Answer buttons
                                _AnswerButtons(
                                  onTap: _onRedTap,
                                  locked: _redShowMsg,
                                  oddColor: const Color(0xFFFF6B6B),
                                  evenColor: const Color(0xFFFF9999),
                                ),

                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),

                        // ── BLUE TEAM ──
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(4, 0, 8, 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFF1E88E5).withOpacity(0.35), width: 2),
                              boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 10)],
                            ),
                            child: Column(
                              children: [
                                // Header
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF1E88E5),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(22), topRight: Radius.circular(22)),
                                  ),
                                  child: const Text('🔵 Blue Team', textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                                ),

                                // Question area
                                Expanded(
                                  child: _QuestionArea(
                                    number: _blueNum,
                                    numScale: _blueNumScale,
                                    shakeAnim: _blueShakeAnim,
                                    shake: _blueShake,
                                    showMsg: _blueShowMsg,
                                    correct: _blueCorrect,
                                    msg: _blueMsg,
                                    teamColor: const Color(0xFF1E88E5),
                                  ),
                                ),

                                // Answer buttons
                                _AnswerButtons(
                                  onTap: _onBlueTap,
                                  locked: _blueShowMsg,
                                  oddColor: const Color(0xFF42A5F5),
                                  evenColor: const Color(0xFF64B5F6),
                                ),

                                const SizedBox(height: 10),
                              ],
                            ),
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

// ── Question Area ─────────────────────────────────────────────────────────────
class _QuestionArea extends StatelessWidget {
  final int number;
  final Animation<double> numScale;
  final AnimationController shakeAnim;
  final Animation<double> shake;
  final bool showMsg;
  final bool correct;
  final String msg;
  final Color teamColor;

  const _QuestionArea({
    required this.number, required this.numScale,
    required this.shakeAnim, required this.shake,
    required this.showMsg, required this.correct,
    required this.msg, required this.teamColor,
  });

  @override
  Widget build(BuildContext context) {
    final isOdd = number % 2 != 0;
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 10, 8, 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: teamColor.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Question label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: teamColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('Is this ODD or EVEN?',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: teamColor)),
          ),
          const SizedBox(height: 12),

          // Number circle with shake
          AnimatedBuilder(
            animation: shakeAnim,
            builder: (_, child) => Transform.translate(
              offset: Offset(showMsg && !correct ? sin(shake.value * pi * 5) * 7 : 0, 0),
              child: child,
            ),
            child: ScaleTransition(
              scale: numScale,
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: teamColor, width: 3.5),
                  boxShadow: [BoxShadow(color: teamColor.withOpacity(0.3), blurRadius: 16, spreadRadius: 2)],
                ),
                child: Center(
                  child: Text('$number',
                      style: TextStyle(
                        fontSize: number >= 100 ? 32 : 44,
                        fontWeight: FontWeight.w900,
                        color: teamColor,
                        height: 1,
                      )),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ODD / EVEN hint badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isOdd ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isOdd ? Colors.orange.shade300 : Colors.green.shade300),
            ),
            child: Text(
              isOdd ? 'Hint: Not divisible by 2' : 'Hint: Divisible by 2',
              style: TextStyle(
                fontSize: 9, fontWeight: FontWeight.w700,
                color: isOdd ? Colors.orange.shade700 : Colors.green.shade700,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Feedback
          AnimatedOpacity(
            opacity: showMsg ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: correct ? const Color(0xFF4CAF50) : const Color(0xFFFF5252),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(
                  color: (correct ? Colors.green : Colors.red).withOpacity(0.3),
                  blurRadius: 8,
                )],
              ),
              child: Text(msg.isEmpty ? ' ' : msg,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Answer Buttons ────────────────────────────────────────────────────────────
class _AnswerButtons extends StatelessWidget {
  final void Function(bool isOdd) onTap;
  final bool locked;
  final Color oddColor;
  final Color evenColor;

  const _AnswerButtons({
    required this.onTap, required this.locked,
    required this.oddColor, required this.evenColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Row(
        children: [
          // ODD button
          Expanded(
            child: GestureDetector(
              onTap: locked ? null : () => onTap(true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 54,
                margin: const EdgeInsets.only(right: 5),
                decoration: BoxDecoration(
                  color: locked ? oddColor.withOpacity(0.4) : oddColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: locked ? [] : [BoxShadow(color: oddColor.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('ODD',
                          style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w900,
                            color: locked ? Colors.white54 : Colors.white,
                            shadows: const [Shadow(color: Colors.black26, blurRadius: 3, offset: Offset(1, 1))],
                          )),
                      Text('1, 3, 5...',
                          style: TextStyle(fontSize: 9, color: locked ? Colors.white38 : Colors.white70, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // EVEN button
          Expanded(
            child: GestureDetector(
              onTap: locked ? null : () => onTap(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 54,
                margin: const EdgeInsets.only(left: 5),
                decoration: BoxDecoration(
                  color: locked ? evenColor.withOpacity(0.4) : evenColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: locked ? [] : [BoxShadow(color: evenColor.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('EVEN',
                          style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w900,
                            color: locked ? Colors.white54 : Colors.white,
                            shadows: const [Shadow(color: Colors.black26, blurRadius: 3, offset: Offset(1, 1))],
                          )),
                      Text('2, 4, 6...',
                          style: TextStyle(fontSize: 9, color: locked ? Colors.white38 : Colors.white70, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Score Card ────────────────────────────────────────────────────────────────
class _ScoreCard extends StatelessWidget {
  final String emoji, label;
  final int score;
  final Color color;

  const _ScoreCard({required this.emoji, required this.label, required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(emoji, style: const TextStyle(fontSize: 18)),
      const SizedBox(width: 5),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700)),
        Text('$score', style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900, height: 1)),
      ]),
    ]);
  }
}

// ── Star ──────────────────────────────────────────────────────────────────────
class _Star {
  final double x, y, size;
  final String emoji;
  const _Star({required this.x, required this.y, required this.emoji, required this.size});
}
