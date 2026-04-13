import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Background ────────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.heroGradient,
            ),
          ),

          // ── Geometric Pattern Overlay ──────────────────────────────────────
          Positioned.fill(
            child: CustomPaint(
              painter: _GeometricPatternPainter(),
            ),
          ),

          // ── Language Badges (floating) ─────────────────────────────────────
          const Positioned(
            top: 100,
            right: -20,
            child: _FloatingBadge(
              flag: '🇳🇬',
              word: 'Ndewo',
              subtitle: 'Hello · Igbo',
              rotation: 0.1,
            ),
          ),
          const Positioned(
            top: 200,
            left: -15,
            child: _FloatingBadge(
              flag: '🇳🇬',
              word: 'Sannu',
              subtitle: 'Hello · Hausa',
              rotation: -0.08,
            ),
          ),
          const Positioned(
            top: 320,
            right: 20,
            child: _FloatingBadge(
              flag: '🇳🇬',
              word: 'Ẹ káàbọ̀',
              subtitle: 'Welcome · Yoruba',
              rotation: 0.06,
            ),
          ),

          // ── Main Content ───────────────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Logo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: const Center(
                            child: Text('🦅', style: TextStyle(fontSize: 22)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          AppStrings.appName,
                          style: AppTextStyles.headlineLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Bottom Card
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Language pills
                          const Row(
                            children: [
                              _LanguagePill('Igbo', AppColors.primarySurface, AppColors.primaryDark),
                              SizedBox(width: 8),
                              _LanguagePill('Yoruba', AppColors.secondarySurface, AppColors.secondaryDark),
                              SizedBox(width: 8),
                              _LanguagePill('Hausa', AppColors.accentBlueSurface, AppColors.accentBlue),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Headline
                          Text(
                            'Learn Nigerian\nlanguages the\nfun way',
                            style: AppTextStyles.displayMedium.copyWith(
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Master Igbo, Yoruba, or Hausa with bite-sized lessons, quizzes, and real conversations.',
                            style: AppTextStyles.bodyMedium,
                          ),
                          const SizedBox(height: 28),

                          // Stats row
                          Row(
                            children: [
                              const _StatItem('175M+', 'Speakers'),
                              _StatDivider(),
                              const _StatItem('3', 'Languages'),
                              _StatDivider(),
                              const _StatItem('Free', 'To start'),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // CTA Button
                          AppButton(
                            label: AppStrings.getStarted,
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.signup);
                            },
                          ),
                          const SizedBox(height: 12),
                          AppButton(
                            label: AppStrings.login,
                            variant: AppButtonVariant.outline,
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.login);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Supporting Widgets ───────────────────────────────────────────────────────

class _LanguagePill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color text;
  const _LanguagePill(this.label, this.bg, this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(color: text),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
          Text(label, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.divider,
    );
  }
}

class _FloatingBadge extends StatelessWidget {
  final String flag;
  final String word;
  final String subtitle;
  final double rotation;

  const _FloatingBadge({
    required this.flag,
    required this.word,
    required this.subtitle,
    required this.rotation,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(flag, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  word,
                  style: AppTextStyles.headlineSmall.copyWith(color: Colors.white),
                ),
              ],
            ),
            Text(
              subtitle,
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Geometric pattern painter ────────────────────────────────────────────────

class _GeometricPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw repeating diamond/rhombus shapes (Adinkra-inspired)
    const spacing = 60.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        final path = Path()
          ..moveTo(x, y - 20)
          ..lineTo(x + 20, y)
          ..lineTo(x, y + 20)
          ..lineTo(x - 20, y)
          ..close();
        canvas.drawPath(path, strokePaint);
        canvas.drawPath(path, paint);
      }
    }

    // Large decorative circle
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.25),
      120,
      Paint()..color = Colors.white.withOpacity(0.04),
    );
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.6),
      80,
      Paint()..color = Colors.white.withOpacity(0.04),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}