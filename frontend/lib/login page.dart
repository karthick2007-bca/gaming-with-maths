import 'package:flutter/material.dart';
import 'sowda12 page.dart';

class LoginSignupPage extends StatefulWidget {
  const LoginSignupPage({super.key});

  @override
  State<LoginSignupPage> createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage>
    with TickerProviderStateMixin {
  final _loginFormKey = GlobalKey<FormState>();
  final _loginName = TextEditingController();
  final _loginPassword = TextEditingController();
  bool _loginObscure = true;

  late AnimationController _floatController;
  late Animation<double> _floatAnim;
  late AnimationController _starController;
  late Animation<double> _starAnim;

  final List<_FloatingEmoji> _emojis = [
    // Top row
    _FloatingEmoji('⭐', 0.05, 0.03),
    _FloatingEmoji('🎯', 0.30, 0.02),
    _FloatingEmoji('🔢', 0.55, 0.04),
    _FloatingEmoji('🌟', 0.80, 0.02),
    _FloatingEmoji('🎈', 0.95, 0.06),
    // Second row
    _FloatingEmoji('➕', 0.02, 0.18),
    _FloatingEmoji('✖️', 0.25, 0.16),
    _FloatingEmoji('🟡', 0.50, 0.15),
    _FloatingEmoji('➖', 0.75, 0.17),
    _FloatingEmoji('🔵', 0.93, 0.20),
    // Middle row
    _FloatingEmoji('🎮', 0.03, 0.38),
    _FloatingEmoji('⭐', 0.88, 0.35),
    _FloatingEmoji('🌈', 0.03, 0.55),
    _FloatingEmoji('🎯', 0.90, 0.52),
    // Fourth row
    _FloatingEmoji('🔢', 0.05, 0.70),
    _FloatingEmoji('➕', 0.28, 0.72),
    _FloatingEmoji('🌟', 0.52, 0.68),
    _FloatingEmoji('✖️', 0.75, 0.71),
    _FloatingEmoji('🎈', 0.92, 0.67),
    // Bottom row
    _FloatingEmoji('🟡', 0.04, 0.88),
    _FloatingEmoji('⭐', 0.28, 0.90),
    _FloatingEmoji('🎮', 0.52, 0.87),
    _FloatingEmoji('🔵', 0.76, 0.91),
    _FloatingEmoji('➖', 0.93, 0.86),
  ];

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    _starController = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _starAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _starController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _loginName.dispose();
    _loginPassword.dispose();
    _floatController.dispose();
    _starController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? v) =>
      (v == null || v.trim().isEmpty) ? 'This field is required' : null;

  String? _validatePassword(String? v) =>
      (v == null || v.length < 4) ? 'Minimum 4 characters' : null;

  void _login() {
    if (_loginFormKey.currentState!.validate()) {
      final name = _loginName.text.trim();
      final password = _loginPassword.text.trim();
      if (name == 'admin' && password == '2007') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const sowda12page()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Invalid username or password'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFE066),
              Color(0xFFFF6FB7),
              Color(0xFF7B61FF),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Floating background emojis
            ..._emojis.map((e) => Positioned(
                  left: e.x * size.width,
                  top: e.y * size.height,
                  child: AnimatedBuilder(
                    animation: _floatController,
                    builder: (_, __) => Transform.translate(
                      offset: Offset(0, _floatAnim.value * (e.x > 0.5 ? 1 : -1)),
                      child: Opacity(
                        opacity: 0.35,
                        child: Text(e.emoji,
                            style: const TextStyle(fontSize: 32)),
                      ),
                    ),
                  ),
                )),

            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      // Top mascot / title
                      AnimatedBuilder(
                        animation: _floatController,
                        builder: (_, __) => Transform.translate(
                          offset: Offset(0, _floatAnim.value),
                          child: Column(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.purple.withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text('🧮',
                                      style: TextStyle(fontSize: 52)),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Play With Maths!',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      blurRadius: 6,
                                      offset: Offset(2, 3),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              AnimatedBuilder(
                                animation: _starController,
                                builder: (_, __) => Opacity(
                                  opacity: _starAnim.value,
                                  child: const Text(
                                    '⭐ Learn • Play • Win ⭐',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Login card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.25),
                              blurRadius: 30,
                              spreadRadius: 2,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(28),
                        child: Form(
                          key: _loginFormKey,
                          child: Column(
                            children: [
                              // Welcome text
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF7B61FF), Color(0xFFFF6FB7)],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  '👋 Welcome, Champ!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Name field
                              _KidTextField(
                                controller: _loginName,
                                label: 'Your Name',
                                emoji: '🧒',
                                validator: _validateRequired,
                              ),
                              const SizedBox(height: 16),

                              // Password field
                              _KidTextField(
                                controller: _loginPassword,
                                label: 'Password',
                                emoji: '🔑',
                                obscure: _loginObscure,
                                validator: _validatePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _loginObscure
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    color: const Color(0xFF7B61FF),
                                  ),
                                  onPressed: () => setState(
                                      () => _loginObscure = !_loginObscure),
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Login button
                              GestureDetector(
                                onTap: _login,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFF6FB7),
                                        Color(0xFF7B61FF),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF7B61FF)
                                            .withOpacity(0.4),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('🚀 ',
                                          style: TextStyle(fontSize: 20)),
                                      Text(
                                        "LET'S GO!",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),
                              const Text(
                                '🎮 Ready to play & learn maths? 🎮',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Bottom fun row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: ['➕', '➖', '✖️', '➗', '🟰']
                            .map((e) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: AnimatedBuilder(
                                    animation: _starController,
                                    builder: (_, __) => Transform.scale(
                                      scale: 0.85 + _starAnim.value * 0.15,
                                      child: Text(e,
                                          style:
                                              const TextStyle(fontSize: 26)),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KidTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String emoji;
  final bool obscure;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const _KidTextField({
    required this.controller,
    required this.label,
    required this.emoji,
    this.obscure = false,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            color: Color(0xFF7B61FF), fontWeight: FontWeight.w600),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(emoji, style: const TextStyle(fontSize: 20)),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF3F0FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: Color(0xFF7B61FF), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }
}

class _FloatingEmoji {
  final String emoji;
  final double x;
  final double y;
  const _FloatingEmoji(this.emoji, this.x, this.y);
}
