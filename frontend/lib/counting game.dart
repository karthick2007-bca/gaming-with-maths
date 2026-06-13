import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

const List<String> _emojis = ['🍎','⭐','🎈','🐶','🌸','🍭','🦋','🚗','🍦','🐱','🐸','🌻','🍓','🐠','🎀'];

class CountingGamePage extends StatefulWidget {
  const CountingGamePage({super.key});

  @override
  State<CountingGamePage> createState() => _CountingGamePageState();
}

class _CountingGamePageState extends State<CountingGamePage>
    with TickerProviderStateMixin {
  final _rand = Random();

  int _redScore = 0;
  int _blueScore = 0;
  bool _gameStarted = false;
  bool _roundLocked = false; // lock after first correct answer
  String _difficulty = 'EASY';
  static const int _winScore = 10;

  int _count = 0;
  String _emoji = '🍎';
  List<int> _redOptions = [];
  List<int> _blueOptions = [];

  String _redMsg = '';
  String _blueMsg = '';
  bool _redShowMsg = false;
  bool _blueShowMsg = false;
  bool _redCorrect = false;
  bool _blueCorrect = false;

  int _seconds = 60;
  Timer? _timer;

  late AnimationController _celebAnim;
  late AnimationController _objectAnim;
  late AnimationController _pulseAnim;
  late AnimationController _timerPulse;
  late AnimationController _redShakeAnim;
  late AnimationController _blueShakeAnim;
  late Animation<double> _objectScale;
  late Animation<double> _pulse;
  late Animation<double> _timerScale;
  late Animation<double> _redShake;
  late Animation<double> _blueShake;

  final List<_Star> _stars = [];
  final List<String> _starEmojis = ['⭐','🌟','✨','🎉','🎊','🎈','💫','🌈'];

  final List<Color> _redBtnColors = [
    Color(0xFFFF6B9D), Color(0xFFFF8C94), Color(0xFFFFB347),
    Color(0xFFFF6B6B), Color(0xFFFF4081),
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

    _objectAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _objectScale = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _objectAnim, curve: Curves.elasticOut));

    _pulseAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.07).animate(
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

    _generateQuestion();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showStartPopup());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _celebAnim.dispose();
    _objectAnim.dispose();
    _pulseAnim.dispose();
    _timerPulse.dispose();
    _redShakeAnim.dispose();
    _blueShakeAnim.dispose();
    super.dispose();
  }

  int get _maxCount {
    if (_difficulty == 'EASY') return 10;
    if (_difficulty == 'MEDIUM') return 20;
    return 50;
  }

  void _generateQuestion() {
    _emoji = _emojis[_rand.nextInt(_emojis.length)];
    _count = _rand.nextInt(_maxCount) + 1;
    _redOptions = _generateOptions(_count);
    _blueOptions = _generateOptions(_count);
    _redMsg = '';
    _blueMsg = '';
    _redShowMsg = false;
    _blueShowMsg = false;
    _redCorrect = false;
    _blueCorrect = false;
    _roundLocked = false;
    setState(() {});
    _objectAnim.forward(from: 0);
  }

  List<int> _generateOptions(int correct) {
    final opts = <int>{correct};
    while (opts.length < 5) {
      int w = max(1, correct + _rand.nextInt(7) - 3);
      if (w != correct) opts.add(w);
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
    _generateQuestion();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_seconds <= 0) { t.cancel(); _showTimeUp(); }
      else setState(() => _seconds--);
    });
  }

  void _onRedTap(int val) {
    if (!_gameStarted || _redShowMsg || _roundLocked) return;
    if (val == _count) {
      setState(() {
        _redScore++;
        _redCorrect = true;
        _redMsg = _correctMsg();
        _redShowMsg = true;
        _roundLocked = true;
      });
      _spawnStars();
      _celebAnim.forward(from: 0);
      if (_redScore >= _winScore) { _timer?.cancel(); Future.delayed(const Duration(milliseconds: 800), _showWinner); return; }
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) _generateQuestion();
      });
    } else {
      setState(() { _redCorrect = false; _redMsg = _wrongMsg(); _redShowMsg = true; });
      _redShakeAnim.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) setState(() => _redShowMsg = false);
      });
    }
  }

  void _onBlueTap(int val) {
    if (!_gameStarted || _blueShowMsg || _roundLocked) return;
    if (val == _count) {
      setState(() {
        _blueScore++;
        _blueCorrect = true;
        _blueMsg = _correctMsg();
        _blueShowMsg = true;
        _roundLocked = true;
      });
      _spawnStars();
      _celebAnim.forward(from: 0);
      if (_blueScore >= _winScore) { _timer?.cancel(); Future.delayed(const Duration(milliseconds: 800), _showWinner); return; }
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) _generateQuestion();
      });
    } else {
      setState(() { _blueCorrect = false; _blueMsg = _wrongMsg(); _blueShowMsg = true; });
      _blueShakeAnim.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) setState(() => _blueShowMsg = false);
      });
    }
  }

  void _spawnStars() {
    _stars.clear();
    for (int i = 0; i < 18; i++) {
      _stars.add(_Star(
        x: _rand.nextDouble(), y: _rand.nextDouble(),
        emoji: _starEmojis[_rand.nextInt(_starEmojis.length)],
        size: 20 + _rand.nextDouble() * 24,
      ));
    }
  }

  String _correctMsg() {
    final msgs = ['🎉 Great!','⭐ Amazing!','🌟 Star!','🏆 Yes!','🎊 Super!'];
    return msgs[_rand.nextInt(msgs.length)];
  }

  String _wrongMsg() {
    final msgs = ['💪 Try Again!','🤔 Count Again!','😊 Keep Going!'];
    return msgs[_rand.nextInt(msgs.length)];
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
                colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.5), blurRadius: 24)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔢', style: TextStyle(fontSize: 38)),
                const SizedBox(height: 4),
                const Text('Counting Objects!',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                const Text('Both teams answer at the same time!\nFirst correct answer wins the point! 🏆',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 10),
                const Text('Select Difficulty:',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _diffBtn(setLocal, 'EASY', '1-10', const Color(0xFF4CAF50)),
                    const SizedBox(width: 6),
                    _diffBtn(setLocal, 'MEDIUM', '1-20', const Color(0xFFFFD600)),
                    const SizedBox(width: 6),
                    _diffBtn(setLocal, 'HARD', '1-50', const Color(0xFFFF5252)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('⏱️ 60s  •  First to 10 wins 🏆',
                    style: TextStyle(color: Colors.white70, fontSize: 11)),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () { Navigator.pop(ctx); _startGame(); },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🚀 ', style: TextStyle(fontSize: 18)),
                        Text('Start Game!',
                            style: TextStyle(color: Color(0xFF44A08D), fontSize: 17, fontWeight: FontWeight.w900)),
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

  Widget _diffBtn(StateSetter setLocal, String diff, String range, Color color) {
    final selected = _difficulty == diff;
    return Expanded(
      child: GestureDetector(
        onTap: () => setLocal(() => _difficulty = diff),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? color : color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: selected ? 2.5 : 1),
          ),
          child: Column(children: [
            Text(diff, style: TextStyle(color: selected ? Colors.white : color, fontSize: 11, fontWeight: FontWeight.w900)),
            Text(range, style: TextStyle(color: selected ? Colors.white70 : color.withOpacity(0.7), fontSize: 10)),
          ]),
        ),
      ),
    );
  }

  void _showTimeUp() {
    final isRedWin = _redScore > _blueScore;
    final isTie = _redScore == _blueScore;
    final winImage = isRedWin ? 'assets/vscodered.png' : 'assets/vscodeblue.png';
    final c1 = isRedWin ? const Color(0xFFFF6B6B) : const Color(0xFF4ECDC4);
    final c2 = isRedWin ? const Color(0xFFFF3D00) : const Color(0xFF1E88E5);

    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isTie ? [const Color(0xFFFF9800), const Color(0xFFFF6B35)] : [c1, c2],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: (isTie ? Colors.orange : c1).withOpacity(0.5), blurRadius: 28)],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('⏰', style: TextStyle(fontSize: 48)),
            const Text("Time's Up!", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            if (!isTie) ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(winImage, height: 130, fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Text('🏆', style: TextStyle(fontSize: 60))),
            ),
            if (isTie) const Text('🤝', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 8),
            Text(isRedWin ? '🔴 Red Team Wins! 🎉' : isTie ? "It's a Draw! 🤝" : '🔵 Blue Team Wins! 🎉',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _chip('🔴', _redScore), const SizedBox(width: 16), _chip('🔵', _blueScore),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _dlgBtn('🏠 Home', Colors.white.withOpacity(0.3), () { Navigator.pop(context); Navigator.pop(context); })),
              const SizedBox(width: 10),
              Expanded(child: _dlgBtn('🔄 Restart', Colors.white, () { Navigator.pop(context); _showStartPopup(); }, textColor: isTie ? const Color(0xFFFF6B35) : c2)),
            ]),
          ]),
        ),
      ),
    );
  }

  void _showWinner() {
    final isRed = _redScore >= _winScore;
    final winImage = isRed ? 'assets/vscodered.png' : 'assets/vscodeblue.png';
    final c1 = isRed ? const Color(0xFFFF6B6B) : const Color(0xFF4ECDC4);
    final c2 = isRed ? const Color(0xFFFF3D00) : const Color(0xFF1E88E5);

    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [c1, c2], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: c1.withOpacity(0.5), blurRadius: 30)],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(winImage, height: 160, fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Text('🏆', style: TextStyle(fontSize: 70))),
            ),
            const SizedBox(height: 8),
            const Text('🏆 Winner! 🏆', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
            Text(isRed ? '🔴 Red Team' : '🔵 Blue Team',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text('$_redScore 🔴  vs  🔵 $_blueScore', style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 8),
            const Text('🎊 🎈 🌟 🎉 🌟 🎈 🎊', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _dlgBtn('🏠 Home', Colors.white.withOpacity(0.3), () { Navigator.pop(context); Navigator.pop(context); })),
              const SizedBox(width: 10),
              Expanded(child: _dlgBtn('🔄 Restart', Colors.white, () { Navigator.pop(context); _showStartPopup(); }, textColor: c2)),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _chip(String e, int s) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
              boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8)]),
          child: Text(label, textAlign: TextAlign.center,
              style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w900)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLow = _seconds <= 10;
    final displayEmojis = List.filled(_count, _emoji);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF9C4), Color(0xFFE8F5E9)],
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

              Column(
                children: [
                  // ── Top bar ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
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
                                scale: _pulse.value,
                                child: _ScoreCard(emoji: '🔴', label: 'Red Team', score: _redScore, color: const Color(0xFFE53935)),
                              ),
                            ),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isLow ? Colors.red.shade600 : const Color(0xFF44A08D),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [BoxShadow(color: (isLow ? Colors.red : Colors.teal).withOpacity(0.4), blurRadius: 6)],
                                  ),
                                  child: Text('⏱ $_seconds',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
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
                                scale: _pulse.value,
                                child: _ScoreCard(emoji: '🔵', label: 'Blue Team', score: _blueScore, color: const Color(0xFF1E88E5)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Question
                  Text('Count the $_emoji objects! 🤔',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.grey.shade700)),

                  const SizedBox(height: 6),

                  // Objects display center
                  Expanded(
                    flex: 4,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.teal.withOpacity(0.3), width: 2),
                      ),
                      child: ScaleTransition(
                        scale: _objectScale,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: _count <= 20
                              ? Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 4, runSpacing: 4,
                                  children: displayEmojis.map((e) =>
                                      Text(e, style: TextStyle(fontSize: _count <= 10 ? 34 : 26))).toList(),
                                )
                              : GridView.count(
                                  crossAxisCount: 8, shrinkWrap: true,
                                  mainAxisSpacing: 2, crossAxisSpacing: 2,
                                  children: displayEmojis.map((e) =>
                                      Center(child: Text(e, style: const TextStyle(fontSize: 18)))).toList(),
                                ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Both teams buttons side by side ──
                  Expanded(
                    flex: 5,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // RED TEAM buttons (LEFT)
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(8, 0, 4, 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE5E5).withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFE53935).withOpacity(0.4), width: 2),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE53935),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(18), topRight: Radius.circular(18)),
                                  ),
                                  child: const Text('🔴 Red Team', textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                                ),
                                // Red feedback
                                AnimatedOpacity(
                                  opacity: _redShowMsg ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Container(
                                    margin: const EdgeInsets.fromLTRB(6, 4, 6, 0),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _redCorrect ? const Color(0xFF4CAF50) : const Color(0xFFFF5252),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(_redMsg.isEmpty ? ' ' : _redMsg,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
                                  ),
                                ),
                                // Red buttons
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: AnimatedBuilder(
                                      animation: _redShakeAnim,
                                      builder: (_, child) => Transform.translate(
                                        offset: Offset(_redShowMsg && !_redCorrect ? sin(_redShake.value * pi * 5) * 6 : 0, 0),
                                        child: child,
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: List.generate(3, (i) {
                                              final opt = _redOptions[i];
                                              return Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(3),
                                                  child: SizedBox(
                                                    height: 48,
                                                    child: _AnsBtn(
                                                      value: opt,
                                                      color: _redBtnColors[i],
                                                      onTap: () => _onRedTap(opt),
                                                      locked: _roundLocked,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                          ),
                                          Row(
                                            children: List.generate(2, (i) {
                                              final opt = _redOptions[3 + i];
                                              return Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(3),
                                                  child: SizedBox(
                                                    height: 48,
                                                    child: _AnsBtn(
                                                      value: opt,
                                                      color: _redBtnColors[3 + i],
                                                      onTap: () => _onRedTap(opt),
                                                      locked: _roundLocked,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // BLUE TEAM buttons (RIGHT)
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(4, 0, 8, 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD).withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF1E88E5).withOpacity(0.4), width: 2),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF1E88E5),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(18), topRight: Radius.circular(18)),
                                  ),
                                  child: const Text('🔵 Blue Team', textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                                ),
                                // Blue feedback
                                AnimatedOpacity(
                                  opacity: _blueShowMsg ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Container(
                                    margin: const EdgeInsets.fromLTRB(6, 4, 6, 0),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _blueCorrect ? const Color(0xFF4CAF50) : const Color(0xFFFF5252),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(_blueMsg.isEmpty ? ' ' : _blueMsg,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
                                  ),
                                ),
                                // Blue buttons
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: AnimatedBuilder(
                                      animation: _blueShakeAnim,
                                      builder: (_, child) => Transform.translate(
                                        offset: Offset(_blueShowMsg && !_blueCorrect ? sin(_blueShake.value * pi * 5) * 6 : 0, 0),
                                        child: child,
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: List.generate(3, (i) {
                                              final opt = _blueOptions[i];
                                              return Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(3),
                                                  child: SizedBox(
                                                    height: 48,
                                                    child: _AnsBtn(
                                                      value: opt,
                                                      color: _blueBtnColors[i],
                                                      onTap: () => _onBlueTap(opt),
                                                      locked: _roundLocked,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                          ),
                                          Row(
                                            children: List.generate(2, (i) {
                                              final opt = _blueOptions[3 + i];
                                              return Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(3),
                                                  child: SizedBox(
                                                    height: 48,
                                                    child: _AnsBtn(
                                                      value: opt,
                                                      color: _blueBtnColors[3 + i],
                                                      onTap: () => _onBlueTap(opt),
                                                      locked: _roundLocked,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                          ),
                                        ],
                                      ),
                                    ),
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
            ],
          ),
        ),
      ),
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
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
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
  final bool locked;
  const _AnsBtn({required this.value, required this.color, required this.onTap, required this.locked});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: locked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: locked ? color.withOpacity(0.4) : color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: locked ? [] : [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6, offset: const Offset(0, 3))],
        ),
        child: Center(
          child: Text('$value',
              style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.w900,
                color: locked ? Colors.white54 : Colors.white,
                shadows: const [Shadow(color: Colors.black26, blurRadius: 3, offset: Offset(1, 1))],
              )),
        ),
      ),
    );
  }
}

// ── Star ──────────────────────────────────────────────────────────────────────
class _Star {
  final double x, y, size;
  final String emoji;
  const _Star({required this.x, required this.y, required this.emoji, required this.size});
}
