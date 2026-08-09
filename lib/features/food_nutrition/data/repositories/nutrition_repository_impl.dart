import 'dart:io';
import '../../domain/entities/nutrition_result.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../datasources/gemini_remote_data_source.dart';

class NutritionRepositoryImpl implements NutritionRepository {
  final GeminiRemoteDataSource remoteDataSource;

  NutritionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<NutritionResult> analyzeFoodImage({
    required File imageFile,
    required String apiKey,
  }) async {
    return await remoteDataSource.analyzeFoodImage(
      imageFile: imageFile,
      apiKey: apiKey,
    );
  }
}
