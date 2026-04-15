import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../data/models/quiz_model.dart';
import '../presentation/providers/quiz_provider.dart';
import '../widgets/quiz_option_card.dart';
import '../widgets/quiz_result_dialog.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String language;
  final String level;
  final String unitId;
  final int subtopicIndex;
  final String unitTitle;
  final String subtopicName;

  const QuizScreen({
    super.key,
    required this.language,
    required this.level,
    required this.unitId,
    required this.subtopicIndex,
    required this.unitTitle,
    required this.subtopicName,
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  late PageController _pageController;
  int _currentQuestionIndex = 0;
  final Map<int, String> _answers = {};
  final Map<int, bool> _answerCorrectness = {};
  bool _showExplanation = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizProvider.notifier).generateQuiz(
            language: widget.language,
            level: widget.level,
            unit: widget.unitId,
            subtopicIndex: widget.subtopicIndex,
            subtopicName: widget.subtopicName,
          );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(quizState),
      body: _buildContent(quizState),
    );
  }

  PreferredSizeWidget _buildAppBar(QuizState state) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
        onPressed: () => _showExitConfirmation(),
      ),
      title: Column(
        children: [
          Text(
            'Quiz Time! 📝',
            style: AppTextStyles.headlineSmall,
          ),
          if (state.quiz != null)
            Text(
              state.quiz!.subtopic,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4),
        child: _buildProgressBar(state),
      ),
    );
  }

  Widget _buildProgressBar(QuizState state) {
    if (state.quiz == null) return const SizedBox.shrink();

    final progress = (_currentQuestionIndex + 1) / state.quiz!.questions.length;

    return Container(
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.divider,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildContent(QuizState state) {
    if (state.status == QuizStatus.loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Preparing your quiz...'),
          ],
        ),
      );
    }

    if (state.status == QuizStatus.submitting) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Saving your results...'),
          ],
        ),
      );
    }

    if (state.status == QuizStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(
                state.errorMessage ?? 'Failed to load quiz',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(quizProvider.notifier).generateQuiz(
                        language: widget.language,
                        level: widget.level,
                        unit: widget.unitId,
                        subtopicIndex: widget.subtopicIndex,
                        subtopicName: widget.subtopicName,
                      );
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final quiz = state.quiz;
    if (quiz == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Question counter
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '${_currentQuestionIndex + 1}/${quiz.questions.length}',
                  style: AppTextStyles.labelLarge
                      .copyWith(color: AppColors.primary),
                ),
              ),
              if (_answers.containsKey(_currentQuestionIndex))
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _answerCorrectness[_currentQuestionIndex] == true
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _answerCorrectness[_currentQuestionIndex] == true
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: _answerCorrectness[_currentQuestionIndex] == true
                            ? AppColors.success
                            : AppColors.error,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _answerCorrectness[_currentQuestionIndex] == true
                            ? 'Correct!'
                            : 'Incorrect',
                        style: AppTextStyles.labelSmall.copyWith(
                          color:
                              _answerCorrectness[_currentQuestionIndex] == true
                                  ? AppColors.success
                                  : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Questions PageView
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentQuestionIndex = index;
                _showExplanation = false;
              });
            },
            itemCount: quiz.questions.length,
            itemBuilder: (context, index) {
              return _buildQuestionCard(quiz.questions[index]);
            },
          ),
        ),

        // Bottom actions
        _buildBottomActions(quiz),
      ],
    );
  }

  Widget _buildQuestionCard(QuizQuestionModel question) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.help_outline_rounded,
                  color: AppColors.primary,
                  size: 32,
                ),
                const SizedBox(height: 16),
                Text(
                  question.question,
                  style: AppTextStyles.headlineMedium.copyWith(height: 1.4),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Options
          ...question.options.asMap().entries.map((entry) {
            final optionIndex = entry.key;
            final option = entry.value;
            final isSelected = _answers[_currentQuestionIndex] == option;
            final showCorrect =
                _showExplanation && option == question.correctAnswer;
            final showWrong = _showExplanation &&
                isSelected &&
                option != question.correctAnswer;

            return QuizOptionCard(
              option: option,
              index: optionIndex,
              isSelected: isSelected,
              isCorrect: showCorrect,
              isWrong: showWrong,
              onTap: _answers.containsKey(_currentQuestionIndex)
                  ? null
                  : () => _handleAnswerSelection(question, option),
            );
          }),

          // Explanation
          if (_showExplanation &&
              _answers.containsKey(_currentQuestionIndex)) ...[
            const SizedBox(height: 24),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.lightbulb_outline_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Explanation',
                        style: AppTextStyles.headlineSmall
                            .copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    question.explanation,
                    style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomActions(QuizResponseModel quiz) {
    final hasAnswered = _answers.containsKey(_currentQuestionIndex);
    final isLastQuestion = _currentQuestionIndex == quiz.questions.length - 1;
    final allQuestionsAnswered = _answers.length == quiz.questions.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentQuestionIndex > 0)
            TextButton.icon(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
              label: const Text('Previous'),
            )
          else
            const SizedBox(width: 100),
          const Spacer(),
          if (!hasAnswered)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.divider.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Select an answer',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.textHint),
              ),
            )
          else if (!_showExplanation)
            SizedBox(
              width: 140,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _showExplanation = true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Show Explanation'),
              ),
            )
          else if (!isLastQuestion)
            SizedBox(
              width: 140,
              child: ElevatedButton(
                onPressed: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Next'),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  ],
                ),
              ),
            )
          else if (allQuestionsAnswered)
            SizedBox(
              width: 160,
              child: ElevatedButton(
                onPressed: () => _submitQuiz(quiz),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Finish Quiz'),
                    SizedBox(width: 4),
                    Icon(Icons.check_circle_rounded, size: 18),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleAnswerSelection(
      QuizQuestionModel question, String selectedAnswer) async {
    final isCorrect = selectedAnswer == question.correctAnswer;

    setState(() {
      _answers[_currentQuestionIndex] = selectedAnswer;
      _answerCorrectness[_currentQuestionIndex] = isCorrect;
    });

    // Get AI feedback
    try {
      final feedback = await ref.read(quizProvider.notifier).checkAnswer(
            language: widget.language,
            question: question.question,
            userAnswer: selectedAnswer,
            correctAnswer: question.correctAnswer,
          );

      if (mounted && feedback != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  isCorrect
                      ? Icons.check_circle_rounded
                      : Icons.info_outline_rounded,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isCorrect ? feedback.encouragement : feedback.feedback,
                  ),
                ),
              ],
            ),
            backgroundColor: isCorrect ? AppColors.success : AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Silently fail - feedback is not critical
    }

    // Auto-show explanation after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _showExplanation = true);
      }
    });
  }

  Future<void> _submitQuiz(QuizResponseModel quiz) async {
    final correctCount =
        _answerCorrectness.values.where((correct) => correct).length;
    final score = ((correctCount / quiz.questions.length) * 100).round();

    final passed = await ref.read(quizProvider.notifier).submitQuizResults(
          unit: widget.unitId,
          subtopicIndex: widget.subtopicIndex,
          subtopicName: widget.subtopicName,
          level: widget.level,
          score: score,
        );

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => QuizResultDialog(
          score: score,
          correctCount: correctCount,
          totalQuestions: quiz.questions.length,
          passed: passed,
          onContinue: passed
              ? () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context, true); // Return with success
                }
              : null,
          onRetry: passed
              ? null
              : () {
                  Navigator.pop(context); // Close dialog
                  _resetQuiz();
                },
          onClose: () {
            Navigator.pop(context); // Close dialog
            if (!passed) {
              Navigator.pop(context); // Go back
            }
          },
        ),
      );
    }
  }

  void _resetQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _answers.clear();
      _answerCorrectness.clear();
      _showExplanation = false;
    });
    _pageController.jumpToPage(0);
    ref.read(quizProvider.notifier).generateQuiz(
          language: widget.language,
          level: widget.level,
          unit: widget.unitId,
          subtopicIndex: widget.subtopicIndex,
          subtopicName: widget.subtopicName,
        );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Quit Quiz?'),
        content: Text(
          _answers.isNotEmpty
              ? 'Your progress will be lost. Are you sure?'
              : 'Are you sure you want to exit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Quit'),
          ),
        ],
      ),
    );
  }
}
