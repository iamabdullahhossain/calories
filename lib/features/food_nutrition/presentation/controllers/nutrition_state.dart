import 'dart:io';
import '../../domain/entities/nutrition_result.dart';

class NutritionState {
  final File? imageFile;
  final bool isLoading;
  final NutritionResult? result;
  final String? errorMessage;

  const NutritionState({
    this.imageFile,
    this.isLoading = false,
    this.result,
    this.errorMessage,
  });

  NutritionState copyWith({
    File? imageFile,
    bool? isLoading,
    NutritionResult? result,
    String? errorMessage,
    bool clearError = false,
    bool clearResult = false,
    bool clearImage = false,
  }) {
    return NutritionState(
      imageFile: clearImage ? null : (imageFile ?? this.imageFile),
      isLoading: isLoading ?? this.isLoading,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
