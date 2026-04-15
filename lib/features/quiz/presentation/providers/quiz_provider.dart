import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/quiz_model.dart';
import '../../data/repositories/quiz_repository_impl.dart';
import '../../../progress/data/datasources/progress_remote_datasource.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

enum QuizStatus { initial, loading, loaded, error, submitting }

class QuizState {
  final QuizStatus status;
  final QuizResponseModel? quiz;
  final String? errorMessage;
  final bool isCompleted;
  final int? finalScore;

  const QuizState({
    required this.status,
    this.quiz,
    this.errorMessage,
    this.isCompleted = false,
    this.finalScore,
  });

  const QuizState.initial()
      : status = QuizStatus.initial,
        quiz = null,
        errorMessage = null,
        isCompleted = false,
        finalScore = null;

  QuizState copyWith({
    QuizStatus? status,
    QuizResponseModel? quiz,
    String? errorMessage,
    bool? isCompleted,
    int? finalScore,
  }) {
    return QuizState(
      status: status ?? this.status,
      quiz: quiz ?? this.quiz,
      errorMessage: errorMessage ?? this.errorMessage,
      isCompleted: isCompleted ?? this.isCompleted,
      finalScore: finalScore ?? this.finalScore,
    );
  }
}

class QuizNotifier extends StateNotifier<QuizState> {
  QuizNotifier(this.ref) : super(const QuizState.initial());

  final Ref ref;
  final _quizRepo = QuizRepositoryImpl.instance;
  final _progressDataSource = ProgressRemoteDataSource.instance;

  Future<void> generateQuiz({
    required String language,
    required String level,
    required String unit,
    required int subtopicIndex,
    String? subtopicName,
    int numQuestions = 8,
  }) async {
    state = state.copyWith(status: QuizStatus.loading, errorMessage: null);

    try {
      final quiz = await _quizRepo.generateQuiz(
        language: language,
        level: level,
        unit: unit,
        subtopicIndex: subtopicIndex,
        subtopicName: subtopicName,
        numQuestions: numQuestions,
      );
      if (!mounted) return;
      state = QuizState(status: QuizStatus.loaded, quiz: quiz);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        status: QuizStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<CheckAnswerResponseModel?> checkAnswer({
    required String language,
    required String question,
    required String userAnswer,
    required String correctAnswer,
  }) async {
    try {
      return await _quizRepo.checkAnswer(
        language: language,
        question: question,
        userAnswer: userAnswer,
        correctAnswer: correctAnswer,
      );
    } catch (e) {
      return null;
    }
  }

  Future<bool> submitQuizResults({
    required String unit,
    required int subtopicIndex,
    required String subtopicName,
    required String level,
    required int score,
  }) async {
    state = state.copyWith(status: QuizStatus.submitting);

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) {
        throw Exception('User not logged in');
      }

      await _progressDataSource.updateProgress(
        userId: user.id,
        language: user.selectedLanguage ?? 'Igbo',
        unit: unit,
        subtopicIndex: subtopicIndex,
        subtopicName: subtopicName,
        score: score,
        level: level,
      );

      final passed = score >= 80;
      if (!mounted) return false;
      state = state.copyWith(
        status: QuizStatus.loaded,
        isCompleted: true,
        finalScore: score,
      );

      return passed;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(
        status: QuizStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  void reset() {
    state = const QuizState.initial();
  }
}

final quizProvider =
    AutoDisposeStateNotifierProvider<QuizNotifier, QuizState>((ref) {
  return QuizNotifier(ref);
});
