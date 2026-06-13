import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class NumberGamePage extends StatefulWidget {
  const NumberGamePage({super.key});

  @override
  State<NumberGamePage> createState() => _NumberGamePageState();
}

class _NumberGamePageState extends State<NumberGamePage>
    with TickerProviderStateMixin {
  final _rand = Random();

  // ── Game state ──
  int _score = 0;
  int _questionIndex = 0;
  int _totalQuestions = 10;
  int _currentNumber = 0;
  List<int> _options = [];
  int? _selectedOption;
  bool _answered = false;
  bool _gameOver = false;
  String _feedback = '';
  Color _feedbackColor = Colors.green;

  // ── Level ranges ──
  final List<Map<String, dynamic>> _levels = [
    {'label': '⭐ Level 1', 'min': 1, 'max': 10, 'color': Color(0xFF4CAF50)},
    {'label': '⭐⭐ Level 2', 'min': 11, 'max': 20, 'color': Color(0xFF2196F3)},
    {'label': '⭐⭐⭐ Level 3', 'min': 21, 'max': 35, 'color': Color(0xFFFF9800)},
    {'label': '🏆 Level 4', 'min': 36, 'max': 50, 'color': Color(0xFFE91E63)},
  ];
  int _levelIndex = 0;

  // ── Animations ──
  late AnimationController _numberAnim;
  late AnimationController _feedbackAnim;
  late AnimationController _starAnim;
  late AnimationController _bounceAnim;
  late Animation<double> _numberScale;
  late Animation<double> _feedbackOpacity;
  late Animation<double> _starScale;
  late Animation<double> _bounce;

  // ── Decorations per question ──
  final List<String> _animals = ['🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯', '🦁', '🐸', '🐙', '🦄', '🐬'];
  final List<String> _balloons = ['🎈', '🎀', '🌟', '⭐', '🎉', '🎊', '🌈', '🍭', '🍬', '🦋'];
  final List<Color> _bgGradients = [
    const Color(0xFFFF6B9D),
    const Color(0xFF4ECDC4),
    const Color(0xFFFFE66D),
    const Color(0xFFA8E6CF),
    const Color(0xFFFFAA85),
    const Color(0xFF88D8B0),
    const Color(0xFFFF8C94),
    const Color(0xFF91C5F2),
  ];
  late Color _currentBg1;
  late Color _currentBg2;
  late String _currentAnimal;

  @override
  void initState() {
    super.initState();

    _numberAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _numberScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _numberAnim, curve: Curves.elasticOut),
    );

    _feedbackAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _feedbackOpacity = Tween<double>(begin: 0, end: 1).animate(_feedbackAnim);

    _starAnim = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _starScale = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _starAnim, curve: Curves.easeInOut),
    );

    _bounceAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _bounce = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _bounceAnim, curve: Curves.easeInOut),
    );

    _nextQuestion();
  }

  @override
  void dispose() {
    _numberAnim.dispose();
    _feedbackAnim.dispose();
    _starAnim.dispose();
    _bounceAnim.dispose();
    super.dispose();
  }

  void _nextQuestion() {
    if (_questionIndex >= _totalQuestions) {
      setState(() => _gameOver = true);
      return;
    }

    // Determine level based on questionIndex
    _levelIndex = (_questionIndex ~/ (_totalQuestions / _levels.length))
        .clamp(0, _levels.length - 1);
    final level = _levels[_levelIndex];
    final min = level['min'] as int;
    final max = level['max'] as int;

    _currentNumber = min + _rand.nextInt(max - min + 1);
    _options = _generateOptions(_currentNumber, min, max);
    _selectedOption = null;
    _answered = false;
    _feedback = '';

    // Random background & animal
    final bgIdx = _rand.nextInt(_bgGradients.length - 1);
    _currentBg1 = _bgGradients[bgIdx];
    _currentBg2 = _bgGradients[bgIdx + 1];
    _currentAnimal = _animals[_rand.nextInt(_animals.length)];

    setState(() {});
    _numberAnim.forward(from: 0);
    _feedbackAnim.reset();
  }

  List<int> _generateOptions(int correct, int min, int max) {
    final opts = <int>{correct};
    while (opts.length < 4) {
      int wrong = min + _rand.nextInt(max - min + 1);
      if (wrong != correct) opts.add(wrong);
    }
    final list = opts.toList()..shuffle();
    return list;
  }

  void _onAnswer(int selected) {
    if (_answered) return;
    setState(() {
      _selectedOption = selected;
      _answered = true;
      if (selected == _currentNumber) {
        _score++;
        _feedback = _correctFeedback();
        _feedbackColor = const Color(0xFF4CAF50);
      } else {
        _feedback = _wrongFeedback();
        _feedbackColor = const Color(0xFFFF5252);
      }
      _questionIndex++;
    });
    _feedbackAnim.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _nextQuestion();
    });
  }

  String _correctFeedback() {
    final list = ['Great Job! 🎉', 'Amazing! ⭐', 'You\'re a Star! 🌟',
      'Awesome! 🏆', 'Brilliant! 🎊', 'Super! 🦄', 'Fantastic! 🎈'];
    return list[_rand.nextInt(list.length)];
  }

  String _wrongFeedback() {
    final list = ['Try Again! 💪', 'Almost! 🤔', 'Keep Going! 🌈',
      'You Can Do It! 😊', 'Don\'t Give Up! ⭐'];
    return list[_rand.nextInt(list.length)];
  }

  Color _optionColor(int opt) {
    if (!_answered) {
      final colors = [
        const Color(0xFFFF6B9D),
        const Color(0xFF4ECDC4),
        const Color(0xFFFFE66D),
        const Color(0xFFA8E6CF),
      ];
      return colors[_options.indexOf(opt) % colors.length];
    }
    if (opt == _currentNumber) return const Color(0xFF4CAF50);
    if (opt == _selectedOption) return const Color(0xFFFF5252);
    return Colors.grey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    if (_gameOver) return _RewardScreen(score: _score, total: _totalQuestions,
      onRestart: () => setState(() {
        _score = 0;
        _questionIndex = 0;
        _gameOver = false;
        _levelIndex = 0;
        _nextQuestion();
      }),
      onHome: () => Navigator.pop(context),
    );

    final level = _levels[_levelIndex];

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_currentBg1, _currentBg2],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top Bar ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    // Level badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(level['label'],
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 13)),
                    ),
                    // Score
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Text('⭐ ', style: TextStyle(fontSize: 16)),
                          Text('$_score',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Progress bar ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _questionIndex / _totalQuestions,
                    minHeight: 10,
                    backgroundColor: Colors.white30,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ── Question text ──
              AnimatedBuilder(
                animation: _bounceAnim,
                builder: (_, __) => Transform.translate(
                  offset: Offset(0, _bounce.value),
                  child: const Text(
                    'What number is this? 🤔',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── Number display ──
              Expanded(
                flex: 3,
                child: Center(
                  child: ScaleTransition(
                    scale: _numberScale,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_currentAnimal,
                              style: const TextStyle(fontSize: 32)),
                          Text(
                            '$_currentNumber',
                            style: TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.w900,
                              color: level['color'] as Color,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Feedback ──
              FadeTransition(
                opacity: _feedbackOpacity,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: _feedbackColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                          color: _feedbackColor.withOpacity(0.4),
                          blurRadius: 12)
                    ],
                  ),
                  child: Text(
                    _feedback.isEmpty ? ' ' : _feedback,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Answer options ──
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.8,
                    physics: const NeverScrollableScrollPhysics(),
                    children: _options.map((opt) {
                      final color = _optionColor(opt);
                      return GestureDetector(
                        onTap: () => _onAnswer(opt),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '$opt',
                              style: const TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(1, 2))
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Decorative bottom emoji row ──
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AnimatedBuilder(
                  animation: _starAnim,
                  builder: (_, __) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _balloons
                        .take(6)
                        .toList()
                        .asMap()
                        .entries
                        .map((e) => Transform.scale(
                              scale: e.key % 2 == 0
                                  ? _starScale.value
                                  : 2 - _starScale.value,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(e.value,
                                    style: const TextStyle(fontSize: 22)),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

// ── Reward Screen ─────────────────────────────────────────────────────────────
class _RewardScreen extends StatefulWidget {
  final int score;
  final int total;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  const _RewardScreen({
    required this.score,
    required this.total,
    required this.onRestart,
    required this.onHome,
  });

  @override
  State<_RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<_RewardScreen>
    with TickerProviderStateMixin {
  late AnimationController _trophyAnim;
  late AnimationController _starsAnim;
  late Animation<double> _trophyScale;
  late Animation<double> _starsOpacity;

  @override
  void initState() {
    super.initState();
    _trophyAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _trophyScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _trophyAnim, curve: Curves.elasticOut),
    );
    _starsAnim = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _starsOpacity = Tween<double>(begin: 0.5, end: 1.0).animate(_starsAnim);
    _trophyAnim.forward();
  }

  @override
  void dispose() {
    _trophyAnim.dispose();
    _starsAnim.dispose();
    super.dispose();
  }

  int get _stars {
    final pct = widget.score / widget.total;
    if (pct >= 0.8) return 3;
    if (pct >= 0.5) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE066), Color(0xFFFF6B9D)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Floating emojis top
                AnimatedBuilder(
                  animation: _starsAnim,
                  builder: (_, __) => Opacity(
                    opacity: _starsOpacity.value,
                    child: const Text(
                      '🎊 🎈 🌟 🎉 🎈 🎊',
                      style: TextStyle(fontSize: 28),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Trophy
                ScaleTransition(
                  scale: _trophyScale,
                  child: const Text('🏆',
                      style: TextStyle(fontSize: 100)),
                ),

                const SizedBox(height: 10),

                const Text(
                  'You Did It!',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Colors.black26, blurRadius: 6,
                          offset: Offset(2, 3))
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Stars rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) => AnimatedBuilder(
                    animation: _starsAnim,
                    builder: (_, __) => Transform.scale(
                      scale: i < _stars ? _starsOpacity.value : 0.7,
                      child: Text(
                        i < _stars ? '⭐' : '☆',
                        style: TextStyle(
                          fontSize: 48,
                          color: i < _stars ? Colors.amber : Colors.white38,
                        ),
                      ),
                    ),
                  )),
                ),

                const SizedBox(height: 16),

                // Score
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white54, width: 2),
                  ),
                  child: Column(
                    children: [
                      const Text('Your Score',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                      Text(
                        '${widget.score} / ${widget.total}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  widget.score == widget.total
                      ? '🌟 Perfect Score! You\'re Amazing! 🌟'
                      : widget.score >= widget.total ~/ 2
                          ? '😊 Great effort! Keep practicing!'
                          : '💪 Keep trying! You can do it!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 28),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _rewardBtn('🏠 Home', const Color(0xFF4ECDC4),
                        widget.onHome),
                    const SizedBox(width: 16),
                    _rewardBtn('🔄 Play Again', const Color(0xFFFF6B35),
                        widget.onRestart),
                  ],
                ),

                const SizedBox(height: 20),

                AnimatedBuilder(
                  animation: _starsAnim,
                  builder: (_, __) => Opacity(
                    opacity: _starsOpacity.value,
                    child: const Text(
                      '🦄 🌈 🎠 🌟 🎡 🦋',
                      style: TextStyle(fontSize: 28),
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

  Widget _rewardBtn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900)),
      ),
    );
  }
}
