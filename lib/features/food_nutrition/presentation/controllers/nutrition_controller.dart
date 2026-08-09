import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/nutrition_result.dart';
import '../../domain/repositories/nutrition_repository.dart';

class NutritionController extends ChangeNotifier {
  final NutritionRepository repository;
  final ImagePicker _picker = ImagePicker();

  NutritionController({required this.repository});

  File? _imageFile;
  bool _isLoading = false;
  NutritionResult? _result;
  String? _errorMessage;

  File? get imageFile => _imageFile;
  bool get isLoading => _isLoading;
  NutritionResult? get result => _result;
  String? get errorMessage => _errorMessage;

  Future<void> analyzeImage({
    required ImageSource source,
    required String apiKey,
  }) async {
    if (apiKey.trim().isEmpty) {
      _errorMessage = 'Please enter your Gemini API key first!';
      notifyListeners();
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

      _imageFile = File(pickedFile.path);
      _isLoading = true;
      _result = null;
      _errorMessage = null;
      notifyListeners();

      final nutritionResult = await repository.analyzeFoodImage(
        imageFile: _imageFile!,
        apiKey: apiKey,
      );

      _isLoading = false;
      _result = nutritionResult;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage =
          'Failed to analyze image. Please check API Key or try again.\nError: $e';
      notifyListeners();
    }
  }
}
