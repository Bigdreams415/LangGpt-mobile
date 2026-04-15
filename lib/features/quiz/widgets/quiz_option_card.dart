import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class QuizOptionCard extends StatelessWidget {
  final String option;
  final int index;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback? onTap;

  const QuizOptionCard({
    super.key,
    required this.option,
    required this.index,
    this.isSelected = false,
    this.isCorrect = false,
    this.isWrong = false,
    this.onTap,
  });

  String get _optionLetter => String.fromCharCode(65 + index); // A, B, C, D

  Color get _backgroundColor {
    if (isCorrect) return AppColors.success.withOpacity(0.1);
    if (isWrong) return AppColors.error.withOpacity(0.1);
    if (isSelected) return AppColors.primary.withOpacity(0.1);
    return AppColors.surface;
  }

  Color get _borderColor {
    if (isCorrect) return AppColors.success;
    if (isWrong) return AppColors.error;
    if (isSelected) return AppColors.primary;
    return AppColors.divider;
  }

  IconData? get _trailingIcon {
    if (isCorrect) return Icons.check_circle_rounded;
    if (isWrong) return Icons.cancel_rounded;
    return null;
  }

  Color get _trailingIconColor {
    if (isCorrect) return AppColors.success;
    if (isWrong) return AppColors.error;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _borderColor,
                width: isSelected || isCorrect || isWrong ? 2 : 1,
              ),
              boxShadow: isSelected || isCorrect || isWrong
                  ? [
                      BoxShadow(
                        color: _borderColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected || isCorrect || isWrong
                        ? _borderColor.withOpacity(0.2)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      _optionLetter,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: isSelected || isCorrect || isWrong
                            ? _borderColor
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    option,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
                if (_trailingIcon != null) ...[
                  const SizedBox(width: 12),
                  Icon(
                    _trailingIcon,
                    color: _trailingIconColor,
                    size: 24,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}