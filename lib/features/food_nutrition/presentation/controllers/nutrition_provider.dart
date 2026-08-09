import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/datasources/gemini_remote_data_source.dart';
import '../../data/repositories/nutrition_repository_impl.dart';
import '../../domain/repositories/nutrition_repository.dart';
import 'nutrition_state.dart';

// Dependency Providers
final geminiRemoteDataSourceProvider = Provider<GeminiRemoteDataSource>((ref) {
  return GeminiRemoteDataSourceImpl();
});

final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) {
  final remoteDataSource = ref.watch(geminiRemoteDataSourceProvider);
  return NutritionRepositoryImpl(remoteDataSource: remoteDataSource);
});

// StateNotifier Provider
final nutritionNotifierProvider =
    StateNotifierProvider<NutritionNotifier, NutritionState>((ref) {
  final repository = ref.watch(nutritionRepositoryProvider);
  return NutritionNotifier(repository: repository);
});

class NutritionNotifier extends StateNotifier<NutritionState> {
  final NutritionRepository repository;
  final ImagePicker _picker = ImagePicker();

  NutritionNotifier({required this.repository}) : super(const NutritionState());

  Future<void> analyzeImage({
    required ImageSource source,
  }) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    if (apiKey.trim().isEmpty) {
      state = state.copyWith(
        errorMessage: 'Gemini API key not found in .env file!',
      );
      return;
    }

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      final imageFile = File(pickedFile.path);

      state = state.copyWith(
        imageFile: imageFile,
        isLoading: true,
        clearResult: true,
        clearError: true,
      );

      final nutritionResult = await repository.analyzeFoodImage(
        imageFile: imageFile,
        apiKey: apiKey,
      );

      state = state.copyWith(
        isLoading: false,
        result: nutritionResult,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Failed to analyze image. Please check API Key or try again.\nError: $e',
      );
    }
  }
}
