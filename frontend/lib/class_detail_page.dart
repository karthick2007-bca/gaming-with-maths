import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class ClassDetailPage extends StatefulWidget {
  final String className;
  const ClassDetailPage({super.key, required this.className});

  @override
  State<ClassDetailPage> createState() => _ClassDetailPageState();
}

class _ClassDetailPageState extends State<ClassDetailPage>
    with TickerProviderStateMixin {
  // ── Game state ──
  int _team1Score = 0;
  int _team2Score = 0;
  double _ropeOffset = 0.0; // -1.0 (team1 wins) to 1.0 (team2 wins)
  bool _gameStarted = false;
  bool _gameOver = false;
  int? _winnerTeam;

  // ── Timer ──
  int _seconds = 60;
  Timer? _timer;

  // ── Questions ──
  late Map<String, int> _q1;
  late Map<String, int> _q2;
  final _rand = Random();

  // ── Rope animation ──
  late AnimationController _ropeAnim;
  late AnimationController _pulseAnim;
  late AnimationController _tugAnim;
  late Animation<double> _tugPull;

  @override
  void initState() {
    super.initState();
    _ropeAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _pulseAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _tugAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _tugPull = Tween<double>(begin: -12, end: 12).animate(
      CurvedAnimation(parent: _tugAnim, curve: Curves.easeInOut),
    );
    _generateQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ropeAnim.dispose();
    _pulseAnim.dispose();
    _tugAnim.dispose();
    super.dispose();
  }

  Map<String, int> _newQuestion() {
    final ops = ['+', '-', '×'];
    final op = ops[_rand.nextInt(ops.length)];
    int a, b, ans;
    final diff = widget.className;
    switch (op) {
      case '+':
        if (diff.contains('EASY')) {
          a = _rand.nextInt(9) + 10;  // 10-18
          b = _rand.nextInt(9) + 1;   // 1-9
        } else if (diff.contains('MEDIUM')) {
          a = _rand.nextInt(9) + 10;  // 10-18
          b = _rand.nextInt(9) + 10;  // 10-18
        } else {
          a = _rand.nextInt(20) + 30; // 30-49
          b = _rand.nextInt(20) + 20; // 20-39
        }
        ans = a + b;
        break;
      case '-':
        if (diff.contains('EASY')) {
          a = _rand.nextInt(9) + 10;  // 10-18
          b = _rand.nextInt(8) + 1;   // 1-8
        } else if (diff.contains('MEDIUM')) {
          a = _rand.nextInt(10) + 15; // 15-24
          b = _rand.nextInt(9) + 10;  // 10-18
        } else {
          a = _rand.nextInt(20) + 50; // 50-69
          b = _rand.nextInt(20) + 20; // 20-39
        }
        ans = a - b;
        break;
      default: // ×
        if (diff.contains('EASY')) {
          a = _rand.nextInt(3) + 2;   // 2-4
          b = _rand.nextInt(4) + 2;   // 2-5
        } else if (diff.contains('MEDIUM')) {
          a = _rand.nextInt(4) + 4;   // 4-7
          b = _rand.nextInt(4) + 4;   // 4-7
        } else {
          a = _rand.nextInt(5) + 10;  // 10-14
          b = _rand.nextInt(5) + 3;   // 3-7
        }
        ans = a * b;
    }
    return {'a': a, 'b': b, 'ans': ans, 'op': op.codeUnitAt(0)};
  }

  void _generateQuestions() {
    _q1 = _newQuestion();
    _q2 = _newQuestion();
  }

  String _qText(Map<String, int> q) =>
      '${q['a']} ${String.fromCharCode(q['op']!)} ${q['b']} = ?';

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _gameOver = false;
      _ropeOffset = 0;
      _team1Score = 0;
      _team2Score = 0;
      _seconds = 60;
      _winnerTeam = null;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds <= 0) {
        t.cancel();
        _endGame();
      } else {
        setState(() => _seconds--);
      }
    });
    _tugAnim.repeat(reverse: true);
  }

  void _endGame({int? winner}) {
    _timer?.cancel();
    setState(() => _gameOver = true);
    _tugAnim.stop();
    _showResult(winner: winner);
  }

  void _onAnswer(int team, String input) {
    if (_gameOver || !_gameStarted) return;
    final q = team == 1 ? _q1 : _q2;
    final correct = int.tryParse(input) == q['ans'];
    setState(() {
      if (correct) {
        if (team == 1) {
          _team1Score++;
          _ropeOffset = (_ropeOffset - 0.34).clamp(-1.0, 1.0);
        } else {
          _team2Score++;
          _ropeOffset = (_ropeOffset + 0.34).clamp(-1.0, 1.0);
        }
        if (team == 1) _q1 = _newQuestion();
        else _q2 = _newQuestion();
      }
    });
    _ropeAnim.forward(from: 0);
    // cross left boundary → team1 wins, cross right boundary → team2 wins
    if (_ropeOffset <= -1.0) {
      _endGame(winner: 1);
    } else if (_ropeOffset >= 1.0) {
      _endGame(winner: 2);
    }
  }

  void _showHomeMenu(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Menu',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _menuOption(Icons.play_arrow, 'Resume', Colors.green, () {
              Navigator.pop(ctx);
            }),
            const SizedBox(height: 10),
            _menuOption(Icons.restart_alt, 'Restart', Colors.amber, () {
              Navigator.pop(ctx);
              _generateQuestions();
              _startGame();
            }),
            const SizedBox(height: 10),
            _menuOption(Icons.home, 'Home', Colors.redAccent, () {
              Navigator.pop(ctx);
              Navigator.pop(ctx);
            }),
          ],
        ),
      ),
    );
  }

  Widget _menuOption(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showResult({int? winner}) {
    if (winner == 1) {
    } else if (winner == 2) {
    } else if (_team1Score > _team2Score) {
      winner = 1;
    } else if (_team2Score > _team1Score) {
      winner = 2;
    }
    setState(() => _winnerTeam = winner);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      body: SafeArea(
        child: Stack(
          children: [
            // Full page background
            Positioned.fill(
              child: Image.asset(
                'assets/background.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Column(
              children: [
                _TopBar(
                  className: widget.className,
                  seconds: _seconds,
                  gameStarted: _gameStarted,
                  onStart: _startGame,
                  onHome: () => _showHomeMenu(context),
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.28,
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: _TeamPanel(
                            team: 1,
                            color: const Color(0xFF1565C0),
                            accentColor: const Color(0xFF42A5F5),
                            score: _team1Score,
                            question: _qText(_q1),
                            onSubmit: (val) => _onAnswer(1, val),
                            enabled: _gameStarted && !_gameOver,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _GameCenter(
                          ropeOffset: _ropeOffset,
                          ropeAnim: _ropeAnim,
                          pulseAnim: _pulseAnim,
                          tugPull: _tugPull,
                          gameStarted: _gameStarted,
                          winnerTeam: _winnerTeam,
                          onStart: _startGame,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.28,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: _TeamPanel(
                            team: 2,
                            color: const Color(0xFFC62828),
                            accentColor: const Color(0xFFEF5350),
                            score: _team2Score,
                            question: _qText(_q2),
                            onSubmit: (val) => _onAnswer(2, val),
                            enabled: _gameStarted && !_gameOver,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Full page winner overlay
            if (_winnerTeam != null)
              Positioned.fill(
                child: Stack(
                  children: [
                    // Full page dim
                    Container(color: Colors.black.withOpacity(0.75)),
                    // Glow behind image
                    Center(
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (_winnerTeam == 2
                                      ? Colors.red
                                      : Colors.blue)
                                  .withOpacity(0.7),
                              blurRadius: 100,
                              spreadRadius: 60,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Winner image + buttons
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          _winnerTeam == 2
                              ? 'assets/vscodered.png'
                              : 'assets/vscode blue.png',
                          fit: BoxFit.contain,
                          height: 460,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.home),
                              label: const Text('Home'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: _startGame,
                              icon: const Icon(Icons.restart_alt),
                              label: const Text('Restart'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── TOP BAR ──────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final String className;
  final int seconds;
  final bool gameStarted;
  final VoidCallback onStart;
  final VoidCallback onHome;

  const _TopBar({
    required this.className,
    required this.seconds,
    required this.gameStarted,
    required this.onStart,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    final timeStr =
        '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    final isLow = seconds <= 10;

    return Container(
      height: 56,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
        ),
        boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 8)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Back + class name
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white70, size: 22),
            onPressed: onHome,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 6),
          Text(className,
              style: const TextStyle(
                  color: Colors.white54, fontSize: 13)),

          // Title center
          const Expanded(
            child: Text(
              'TUG OF WAR: MATHEMATICS',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ),

          // Timer or nothing (START button moved to center)
          if (gameStarted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isLow ? Colors.red.shade700 : const Color(0xFF0F3460),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isLow ? Colors.red : Colors.blue.shade300, width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer,
                      color: isLow ? Colors.white : Colors.blue.shade200,
                      size: 16),
                  const SizedBox(width: 4),
                  Text(timeStr,
                      style: TextStyle(
                          color: isLow ? Colors.white : Colors.blue.shade100,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                ],
              ),
            ),

          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// ── TEAM PANEL ───────────────────────────────────────────────────────────────
class _TeamPanel extends StatefulWidget {
  final int team;
  final Color color;
  final Color accentColor;
  final int score;
  final String question;
  final void Function(String) onSubmit;
  final bool enabled;

  const _TeamPanel({
    required this.team,
    required this.color,
    required this.accentColor,
    required this.score,
    required this.question,
    required this.onSubmit,
    required this.enabled,
  });

  @override
  State<_TeamPanel> createState() => _TeamPanelState();
}

class _TeamPanelState extends State<_TeamPanel> {
  String _input = '';

  void _key(String v) {
    if (!widget.enabled) return;
    setState(() { if (_input.length < 4) _input += v; });
  }

  void _backspace() => setState(() {
        if (_input.isNotEmpty) _input = _input.substring(0, _input.length - 1);
      });

  void _submit() {
    if (_input.isEmpty || !widget.enabled) return;
    widget.onSubmit(_input);
    setState(() => _input = '');
  }

  void _clear() => setState(() => _input = '');

  @override
  Widget build(BuildContext context) {
    final c = widget.color;
    final ac = widget.accentColor;

    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c.withOpacity(0.95), c.withOpacity(0.7)],
        ),
        border: Border(
          right: widget.team == 1
              ? BorderSide(color: ac.withOpacity(0.3), width: 1)
              : BorderSide.none,
          left: widget.team == 2
              ? BorderSide(color: ac.withOpacity(0.3), width: 1)
              : BorderSide.none,
        ),
      ),
      child: Column(
        children: [
          // Score header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 7),
            color: Colors.black26,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TEAM ${widget.team}',
                    style: TextStyle(
                        color: ac,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 1.2)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: ac,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${widget.score}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
              ],
            ),
          ),

          // Question box
          Container(
            margin: const EdgeInsets.fromLTRB(6, 4, 6, 4),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ac.withOpacity(0.6), width: 1.5),
            ),
            child: Text(
              widget.question,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),

          // Answer display
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ac, width: 2),
            ),
            child: Text(
              _input.isEmpty ? '_ _ _' : _input,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _input.isEmpty ? Colors.white38 : Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4),
            ),
          ),

          const SizedBox(height: 4),

          // Number keypad
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Column(
                children: [
                  // 1-9
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 3,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      childAspectRatio: 1.8,
                      children: List.generate(9, (i) {
                        final n = (i + 1).toString();
                        return _NumKey(
                            label: n,
                            color: ac,
                            onTap: () => _key(n),
                            enabled: widget.enabled);
                      }),
                    ),
                  ),
                  // Bottom row: Clear | 0 | ⌫
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4, top: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: _NumKey(
                              label: 'C',
                              color: Colors.orange,
                              onTap: _clear,
                              enabled: widget.enabled),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _NumKey(
                              label: '0',
                              color: ac,
                              onTap: () => _key('0'),
                              enabled: widget.enabled),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _NumKey(
                              icon: Icons.backspace_outlined,
                              color: Colors.orange,
                              onTap: _backspace,
                              enabled: widget.enabled),
                        ),
                      ],
                    ),
                  ),
                  // Submit button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: widget.enabled ? _submit : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ac,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.white12,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 4,
                        ),
                        child: const Text('SUBMIT ✓',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumKey extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final Color color;
  final VoidCallback onTap;
  final bool enabled;

  const _NumKey(
      {this.label,
      this.icon,
      required this.color,
      required this.onTap,
      required this.enabled});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        decoration: BoxDecoration(
          color: enabled ? color.withOpacity(0.2) : Colors.white10,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: enabled ? color.withOpacity(0.7) : Colors.white12,
              width: 1.5),
          boxShadow: enabled
              ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 4)]
              : [],
        ),
        child: Center(
          child: label != null
              ? Text(label!,
                  style: TextStyle(
                      color: enabled ? Colors.white : Colors.white30,
                      fontSize: 20,
                      fontWeight: FontWeight.bold))
              : Icon(icon,
                  color: enabled ? color : Colors.white30, size: 20),
        ),
      ),
    );
  }
}

// ── CENTER GAME AREA ──────────────────────────────────────────────────────────
class _GameCenter extends StatelessWidget {
  final double ropeOffset;
  final AnimationController ropeAnim;
  final AnimationController pulseAnim;
  final Animation<double> tugPull;
  final bool gameStarted;
  final int? winnerTeam;
  final VoidCallback onStart;

  const _GameCenter({
    required this.ropeOffset,
    required this.ropeAnim,
    required this.pulseAnim,
    required this.tugPull,
    required this.gameStarted,
    required this.winnerTeam,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ground line
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Container(height: 3, color: Colors.green.shade700),
          ),

          // Center dashed boundary line
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: CustomPaint(
                size: const Size(4, double.infinity),
                painter: _DashedLinePainter(),
              ),
            ),
          ),

          // Tug of war image
          AnimatedBuilder(
            animation: Listenable.merge([ropeAnim, tugPull]),
            builder: (context, _) {
              final shift = ropeOffset * (MediaQuery.of(context).size.width * 0.18);
              final pull = gameStarted ? tugPull.value : 0.0;
              return Align(
                alignment: Alignment.bottomCenter,
                child: Transform.translate(
                  offset: Offset(shift + pull, 0),
                  child: Image.asset(
                    'assets/vscode2.png',
                    height: MediaQuery.of(context).size.height * 0.45,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),

          // Win zone indicators
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: pulseAnim,
                builder: (_, __) => Opacity(
                  opacity: ropeOffset < -0.6
                      ? 0.4 + pulseAnim.value * 0.6
                      : 0.15,
                  child: Container(
                    width: 28,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Text('WIN',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: pulseAnim,
                builder: (_, __) => Opacity(
                  opacity: ropeOffset > 0.6
                      ? 0.4 + pulseAnim.value * 0.6
                      : 0.15,
                  child: Container(
                    width: 28,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Text('WIN',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Rope progress bar at bottom
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: _RopeProgressBar(offset: ropeOffset),
          ),

          // Not started overlay
          if (!gameStarted)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: ElevatedButton(
                    onPressed: onStart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 36, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      elevation: 8,
                    ),
                    child: const Text('START',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                            letterSpacing: 2)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RopeTension extends StatelessWidget {
  final double offset;
  const _RopeTension({required this.offset});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 20,
      child: CustomPaint(painter: _RopePainter(offset: offset)),
    );
  }
}

class _RopePainter extends CustomPainter {
  final double offset;
  const _RopePainter({required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8B4513)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height / 2);
    final tension = offset.abs() * 8;
    for (int i = 0; i < 6; i++) {
      final x1 = i * (size.width / 5) + size.width / 15;
      final x2 = i * (size.width / 5) + size.width / 7;
      final x3 = (i + 1) * (size.width / 5);
      final wave = (i % 2 == 0 ? 1 : -1) * (4 + tension);
      path.cubicTo(x1, size.height / 2 + wave, x2,
          size.height / 2 - wave, x3, size.height / 2);
    }
    canvas.drawPath(path, paint);

    // Strand marks
    final strand = Paint()
      ..color = const Color(0xFFA0522D)
      ..strokeWidth = 2;
    for (int i = 0; i < 8; i++) {
      final x = i * (size.width / 7);
      canvas.drawLine(Offset(x, size.height / 2 - 3),
          Offset(x + 10, size.height / 2 + 3), strand);
    }
  }

  @override
  bool shouldRepaint(_RopePainter old) => old.offset != offset;
}

class _RopeProgressBar extends StatelessWidget {
  final double offset;
  const _RopeProgressBar({required this.offset});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Text('🔵', style: TextStyle(fontSize: 12)),
            Expanded(
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white12,
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: ((1 - offset) / 2).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFFC62828)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Text('🔴', style: TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashH = 12.0;
    const gap = 8.0;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(0, y + dashH), paint);
      y += dashH + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
