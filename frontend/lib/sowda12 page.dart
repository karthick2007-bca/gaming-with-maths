import 'package:flutter/material.dart';
import 'class_detail_page.dart';
import 'lkg game.dart';
import 'counting game.dart';
import 'before after game.dart';
import 'shapes game.dart';
import 'odd even game.dart';

class sowda12page extends StatefulWidget {
  const sowda12page({super.key});
  @override
  State<sowda12page> createState() => _sowda12pageState();
}

class _sowda12pageState extends State<sowda12page>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..repeat(reverse: true);
    _bounce = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  // ── Shared compact list button (UKG) ──────────────────────────────────────
  Widget _topicBtn(String icon, String title, String sub, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: color.withOpacity(0.35), blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
                  if (sub.isNotEmpty)
                    Text(sub, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 12),
          ],
        ),
      ),
    );
  }

  // ── Square grid button (LKG) ──────────────────────────────────────────────
  Widget _gridBtn(String icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, height: 1.2)),
          ],
        ),
      ),
    );
  }

  SnackBar _comingSoon(String title, Color color) => SnackBar(
    content: Text('$title — Coming Soon! 🚀',
        style: const TextStyle(fontWeight: FontWeight.w700)),
    backgroundColor: color,
    duration: const Duration(seconds: 2),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  // ── LKG Dialog ────────────────────────────────────────────────────────────
  void _showLkgDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7B61FF), Color(0xFFFF6FB7)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.4), blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('🔢', style: TextStyle(fontSize: 28)),
                SizedBox(width: 8),
                Text('LKG Topics', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
              ]),
              const SizedBox(height: 3),
              const Text('🔴 Red vs 🔵 Blue  •  First to 10 wins 🏆',
                  style: TextStyle(color: Colors.white70, fontSize: 11)),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _gridBtn('🔍', 'Find\nNumber', const Color(0xFF7B61FF),
                    () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const LkgNumberGame())); })),
                const SizedBox(width: 8),
                Expanded(child: _gridBtn('🤣', 'Counting\nObjects', const Color(0xFF44A08D),
                    () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const CountingGamePage())); })),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _gridBtn('🔢', 'Before\n& After', const Color(0xFFFF9800),
                    () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const BeforeAfterGame())); })),
                const SizedBox(width: 8),
                Expanded(child: _gridBtn('🔷', 'Basic\nShapes', const Color(0xFFFF6B9D),
                    () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ShapesGamePage())); })),
              ]),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── UKG Dialog ────────────────────────────────────────────────────────────
  void _showUkgDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.5), blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('🎓', style: TextStyle(fontSize: 28)),
                SizedBox(width: 8),
                Text('UKG Topics', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
              ]),
              const SizedBox(height: 3),
              const Text('🔴 Red vs 🔵 Blue  •  First to 10 wins 🏆',
                  style: TextStyle(color: Colors.white70, fontSize: 11)),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _gridBtn('➕', 'Simple\nAddition', const Color(0xFF4CAF50),
                    () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(_comingSoon('Simple Addition', const Color(0xFF4CAF50))); })),
                const SizedBox(width: 8),
                Expanded(child: _gridBtn('➖', 'Simple\nSubtraction', const Color(0xFFFF7043),
                    () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(_comingSoon('Simple Subtraction', const Color(0xFFFF7043))); })),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _gridBtn('🔢', 'Odd & Even\nNumbers', const Color(0xFF7B61FF),
                    () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const OddEvenGamePage())); })),
                const SizedBox(width: 8),
                Expanded(child: _gridBtn('🔷', '2D & 3D\nShapes', const Color(0xFFFF6B9D),
                    () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(_comingSoon('2D Shapes', const Color(0xFFFF6B9D))); })),
              ]),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Class 1 Dialog ──────────────────────────────────────────────────────
  void _showClass1Dialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFFFD700)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.5), blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('🏫', style: TextStyle(fontSize: 28)),
                SizedBox(width: 8),
                Text('Class 1 Topics', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
              ]),
              const SizedBox(height: 3),
              const Text('🔴 Red vs 🔵 Blue  •  First to 10 wins 🏆',
                  style: TextStyle(color: Colors.white70, fontSize: 11)),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _gridBtn('🔤', 'Number\nNames', const Color(0xFF7B61FF),
                    () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(_comingSoon('Number Names', const Color(0xFF7B61FF))); })),
                const SizedBox(width: 8),
                Expanded(child: _gridBtn('⚖️', 'Comparing\nNumbers', const Color(0xFF0288D1),
                    () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(_comingSoon('Comparing Numbers', const Color(0xFF0288D1))); })),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _gridBtn('✖️', 'Multiplication\n×2, ×3', const Color(0xFFE53935),
                    () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(_comingSoon('Multiplication Intro', const Color(0xFFE53935))); })),
                const SizedBox(width: 8),
                Expanded(child: _gridBtn('🔷', 'Shapes &\nSpatial', const Color(0xFFFF6B9D),
                    () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(_comingSoon('Shapes & Spatial Sense', const Color(0xFFFF6B9D))); })),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _gridBtn('📏', 'Measure-\nment', const Color(0xFF43A047),
                    () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(_comingSoon('Measurement', const Color(0xFF43A047))); })),
                const SizedBox(width: 8),
                Expanded(child: _gridBtn('🕐', 'Time\n(Clock)', const Color(0xFFFFB300),
                    () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(_comingSoon('Time - Clock Reading', const Color(0xFFFFB300))); })),
              ]),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Class 2 Dialog ──────────────────────────────────────────────────────
  void _showClass2Dialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.5), blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('✏️', style: TextStyle(fontSize: 28)),
                SizedBox(width: 8),
                Text('Class 2 Topics', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
              ]),
              const SizedBox(height: 3),
              const Text('🔴 Red vs 🔵 Blue  •  First to 10 wins 🏆',
                  style: TextStyle(color: Colors.white70, fontSize: 11)),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _gridBtn('✖️', 'Multiplication\nTables 2–10', const Color(0xFF7B61FF),
                    () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(_comingSoon('Multiplication Tables', const Color(0xFF7B61FF))); })),
                const SizedBox(width: 8),
                Expanded(child: _gridBtn('➗', 'Division\nBasics', const Color(0xFFE53935),
                    () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(_comingSoon('Division Basics', const Color(0xFFE53935))); })),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _gridBtn('½', 'Fractions\nIntro', const Color(0xFF43A047),
                    () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(_comingSoon('Fractions Intro', const Color(0xFF43A047))); })),
                const SizedBox(width: 8),
                Expanded(child: _gridBtn('🔢', 'Place Value\n(Hundreds)', const Color(0xFF0288D1),
                    () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(_comingSoon('Place Value', const Color(0xFF0288D1))); })),
              ]),
              const SizedBox(height: 8),
              _gridBtn('🔁', 'Patterns & Sequences', const Color(0xFFFF6B9D),
                  () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(_comingSoon('Patterns & Sequences', const Color(0xFFFF6B9D))); }),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Class 3 Dialog ──────────────────────────────────────────────────────
  void _showClass3Dialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.5), blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('📚', style: TextStyle(fontSize: 28)),
                SizedBox(width: 8),
                Text('Class 3 Topics', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
              ]),
              const SizedBox(height: 3),
              const Text('🔴 Red vs 🔵 Blue  •  First to 10 wins 🏆',
                  style: TextStyle(color: Colors.white70, fontSize: 11)),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _gridBtn('🔢', 'Fractions\n(Like)', const Color(0xFF7B61FF),
                    () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(_comingSoon('Fractions', const Color(0xFF7B61FF))); })),
                const SizedBox(width: 8),
                Expanded(child: _gridBtn('📐', 'Geometry\nLines & Angles', const Color(0xFF0288D1),
                    () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(_comingSoon('Geometry', const Color(0xFF0288D1))); })),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _gridBtn('📏', 'Perimeter\nof Shapes', const Color(0xFF43A047),
                    () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(_comingSoon('Perimeter', const Color(0xFF43A047))); })),
                const SizedBox(width: 8),
                Expanded(child: _gridBtn('🏛️', 'Roman\nNumerals', const Color(0xFFE53935),
                    () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(_comingSoon('Roman Numerals I–XX', const Color(0xFFE53935))); })),
              ]),
              const SizedBox(height: 8),
              _gridBtn('⚖️', 'Weight & Capacity (kg, litre)', const Color(0xFFFFB300),
                  () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(_comingSoon('Weight & Capacity', const Color(0xFFFFB300))); }),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tug of War difficulty ─────────────────────────────────────────────────
  void _showDifficultyDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Select Difficulty',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _diffOption('🟢 EASY', Colors.green),
            const SizedBox(height: 10),
            _diffOption('🟡 MEDIUM', Colors.amber),
            const SizedBox(height: 10),
            _diffOption('🔴 HARD', Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _diffOption(String label, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context,
          MaterialPageRoute(builder: (_) => ClassDetailPage(className: label)));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.6), width: 1.5),
        ),
        child: Text(label, textAlign: TextAlign.center,
            style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/sowda12.png', fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A1A2E))),
          Positioned(
            bottom: 20, left: 20, right: 20,
            child: AnimatedBuilder(
              animation: _bounceController,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, _bounce.value),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Row 1: TUG OF WAR, LKG, UKG, CLASS 1 ──
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _showDifficultyDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B35),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 6, shadowColor: Colors.orange.withOpacity(0.6),
                            ),
                            child: const Column(mainAxisSize: MainAxisSize.min, children: [
                              Text('🪢', style: TextStyle(fontSize: 20)),
                              SizedBox(height: 2),
                              Text('TUG OF WAR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                            ]),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _showLkgDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7B61FF),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 6, shadowColor: Colors.purple.withOpacity(0.6),
                            ),
                            child: const Column(mainAxisSize: MainAxisSize.min, children: [
                              Text('🔢', style: TextStyle(fontSize: 20)),
                              SizedBox(height: 2),
                              Text('LKG', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                            ]),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _showUkgDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF11998E),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 6, shadowColor: Colors.teal.withOpacity(0.6),
                            ),
                            child: const Column(mainAxisSize: MainAxisSize.min, children: [
                              Text('🎓', style: TextStyle(fontSize: 20)),
                              SizedBox(height: 2),
                              Text('UKG', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                            ]),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _showClass1Dialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8F00),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 6, shadowColor: Colors.orange.withOpacity(0.6),
                            ),
                            child: const Column(mainAxisSize: MainAxisSize.min, children: [
                              Text('🏫', style: TextStyle(fontSize: 20)),
                              SizedBox(height: 2),
                              Text('CLASS 1', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                            ]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // ── Row 2: CLASS 2, CLASS 3 ──
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _showClass2Dialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1565C0),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 6, shadowColor: Colors.blue.withOpacity(0.6),
                            ),
                            child: const Column(mainAxisSize: MainAxisSize.min, children: [
                              Text('✏️', style: TextStyle(fontSize: 20)),
                              SizedBox(height: 2),
                              Text('CLASS 2', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                            ]),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _showClass3Dialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A1B9A),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 6, shadowColor: Colors.purple.withOpacity(0.6),
                            ),
                            child: const Column(mainAxisSize: MainAxisSize.min, children: [
                              Text('📚', style: TextStyle(fontSize: 20)),
                              SizedBox(height: 2),
                              Text('CLASS 3', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
