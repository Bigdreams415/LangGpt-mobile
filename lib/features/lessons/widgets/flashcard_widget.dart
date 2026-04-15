import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../data/models/lesson_model.dart';

class FlashcardWidget extends StatefulWidget {
  final List<VocabItemModel> vocabulary;

  const FlashcardWidget({
    super.key,
    required this.vocabulary,
  });

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget> {
  late PageController _controller;
  int _currentIndex = 0;
  final Map<int, bool> _isFlipped = {};

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    setState(() {
      _isFlipped[_currentIndex] = !(_isFlipped[_currentIndex] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                // Reset flip state when changing cards
                _isFlipped[index] = false;
              });
            },
            itemCount: widget.vocabulary.length,
            itemBuilder: (context, index) {
              final vocab = widget.vocabulary[index];
              final isFlipped = _isFlipped[index] ?? false;

              return Padding(
                padding: const EdgeInsets.all(24),
                child: GestureDetector(
                  onTap: _flipCard,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      return RotationTransition(
                        turns: animation,
                        child: child,
                      );
                    },
                    child: Container(
                      key: ValueKey(isFlipped),
                      decoration: BoxDecoration(
                        color: isFlipped ? AppColors.secondarySurface : AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: (isFlipped ? AppColors.secondary : AppColors.primary).withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!isFlipped) ...[
                                Text(
                                  vocab.word,
                                  style: AppTextStyles.displaySmall.copyWith(
                                    fontSize: 36,
                                    color: AppColors.primaryDark,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  vocab.pronunciation,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    'Tap to reveal',
                                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  vocab.translation,
                                  style: AppTextStyles.displaySmall.copyWith(
                                    fontSize: 32,
                                    color: AppColors.secondaryDark,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        '"${vocab.exampleSentence}"',
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          fontStyle: FontStyle.italic,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        vocab.sentenceTranslation,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Card counter
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${_currentIndex + 1}/${widget.vocabulary.length}',
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: _currentIndex > 0
                    ? () => _controller.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        )
                    : null,
                icon: const Icon(Icons.arrow_back_ios_rounded),
              ),
              IconButton(
                onPressed: _currentIndex < widget.vocabulary.length - 1
                    ? () => _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        )
                    : null,
                icon: const Icon(Icons.arrow_forward_ios_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }
}