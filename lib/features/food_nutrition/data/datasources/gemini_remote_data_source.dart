import 'dart:convert';
import 'dart:io';
import '../models/nutrition_result_model.dart';

abstract class GeminiRemoteDataSource {
  Future<NutritionResultModel> analyzeFoodImage({
    required File imageFile,
    required String apiKey,
  });
}

class GeminiRemoteDataSourceImpl implements GeminiRemoteDataSource {
  @override
  Future<NutritionResultModel> analyzeFoodImage({
    required File imageFile,
    required String apiKey,
  }) async {
    final imageBytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(imageBytes);
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=$apiKey',
    );

    final httpResponse = await HttpClient().postUrl(url).then((request) {
      request.headers.set('Content-Type', 'application/json');
      request.add(utf8.encode(jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text': '''
Analyze this food image and provide a comprehensive estimated nutrition info list, along with health insights.
Respond ONLY in pure valid JSON format with the exact keys:
{
  "food_name": "Name of the food",
  "calories": "e.g., 350 kcal",
  "protein": "e.g., 20 g",
  "carbs": "e.g., 40 g",
  "fat": "e.g., 12 g",
  "saturated_fat": "e.g., 3 g",
  "fiber": "e.g., 5 g",
  "sugar": "e.g., 8 g",
  "sodium": "e.g., 450 mg",
  "potassium": "e.g., 300 mg",
  "cholesterol": "e.g., 35 mg",
  "vitamin_c": "e.g., 15 mg",
  "calcium": "e.g., 120 mg",
  "iron": "e.g., 2.5 mg",
  "health_overview": "A brief summary description of whether this food item is healthy or not and overall recommendation",
  "positive_aspects": [
    "Good source of protein for muscle recovery",
    "High fiber content helping in digestion"
  ],
  "negative_aspects": [
    "High sodium content which may affect blood pressure",
    "Contains saturated fats"
  ]
}
If the image does not contain food, set "food_name" to "Not a food item" and put "N/A" for all other keys with empty lists for positive_aspects and negative_aspects. Do not include markdown code block formatting.
'''
              },
              {
                'inlineData': {
                  'mimeType': 'image/jpeg',
                  'data': base64Image,
                }
              }
            ]
          }
        ]
      })));
      return request.close();
    });

    final responseBody = await httpResponse.transform(utf8.decoder).join();

    final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);

    if (httpResponse.statusCode != 200) {
      final errorMsg =
          jsonResponse['error']?['message'] ?? 'API Error (${httpResponse.statusCode})';
      throw Exception(errorMsg);
    }

    final text =
        jsonResponse['candidates']?[0]?['content']?['parts']?[0]?['text']?.trim() ?? '';

    String cleanJson = text;
    if (cleanJson.startsWith('```')) {
      cleanJson = cleanJson.replaceAll(RegExp(r'^```(json)?|```$'), '').trim();
    }

    final Map<String, dynamic> decoded = jsonDecode(cleanJson);
    return NutritionResultModel.fromJson(decoded);
  }
}
