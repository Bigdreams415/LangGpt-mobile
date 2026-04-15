import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class QuizResultDialog extends StatefulWidget {
  final int score;
  final int correctCount;
  final int totalQuestions;
  final bool passed;
  final VoidCallback? onContinue;
  final VoidCallback? onRetry;
  final VoidCallback onClose;

  const QuizResultDialog({
    super.key,
    required this.score,
    required this.correctCount,
    required this.totalQuestions,
    required this.passed,
    this.onContinue,
    this.onRetry,
    required this.onClose,
  });

  @override
  State<QuizResultDialog> createState() => _QuizResultDialogState();
}

class _QuizResultDialogState extends State<QuizResultDialog> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    if (widget.passed) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with animation
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: widget.passed
                          ? const LinearGradient(
                              colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                            )
                          : LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryDark],
                            ),
                      boxShadow: [
                        BoxShadow(
                          color: (widget.passed ? Colors.green : AppColors.primary)
                              .withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.passed ? Icons.emoji_events_rounded : Icons.school_rounded,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Title
                Text(
                  widget.passed ? 'Congratulations! 🎉' : 'Keep Practicing! 💪',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: widget.passed ? AppColors.success : AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                // Score with animation
                TweenAnimationBuilder(
                  tween: IntTween(begin: 0, end: widget.score),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Text(
                      '$value%',
                      style: AppTextStyles.displaySmall.copyWith(
                        fontSize: 48,
                        color: widget.passed ? AppColors.success : AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                
                Text(
                  '${widget.correctCount} out of ${widget.totalQuestions} correct',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
                
                const SizedBox(height: 24),
                
                // Pass/Fail Message
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.passed
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.passed
                          ? AppColors.success.withOpacity(0.3)
                          : AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    widget.passed
                        ? 'Excellent! You\'ve mastered this topic. Ready to continue your learning journey?'
                        : 'You need 80% to pass. Don\'t worry - review the material and try again!',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: widget.passed ? AppColors.success : AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Actions
                Row(
                  children: [
                    if (!widget.passed) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            widget.onClose();
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Close'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            widget.onRetry?.call();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Try Again'),
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            widget.onContinue?.call();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Continue'),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // Confetti overlay
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: -3.14 / 2, // Upward
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            gravity: 0.2,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
              Colors.yellow,
            ],
          ),
        ),
      ],
    );
  }
}