import 'dart:io';
import '../entities/nutrition_result.dart';

abstract class NutritionRepository {
  Future<NutritionResult> analyzeFoodImage({
    required File imageFile,
    required String apiKey,
  });
}
