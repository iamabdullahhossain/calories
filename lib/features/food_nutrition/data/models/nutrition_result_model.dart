import 'package:calories/features/food_nutrition/domain/entities/nutrition_result.dart';

 

class NutritionResultModel extends NutritionResult {
  const NutritionResultModel({
    required super.foodName,
    required super.calories,
    required super.nutrients,
    super.healthOverview,
    required super.positiveAspects,
    required super.negativeAspects,
  });

  factory NutritionResultModel.fromJson(Map<String, dynamic> json) {
    final posList = (json['positive_aspects'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final negList = (json['negative_aspects'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    final Map<String, String> nutrientsMap = {
      'Protein': json['protein']?.toString() ?? 'N/A',
      'Carbohydrates': json['carbs']?.toString() ?? 'N/A',
      'Total Fat': json['fat']?.toString() ?? 'N/A',
      'Saturated Fat': json['saturated_fat']?.toString() ?? 'N/A',
      'Dietary Fiber': json['fiber']?.toString() ?? 'N/A',
      'Sugar': json['sugar']?.toString() ?? 'N/A',
      'Sodium': json['sodium']?.toString() ?? 'N/A',
      'Potassium': json['potassium']?.toString() ?? 'N/A',
      'Cholesterol': json['cholesterol']?.toString() ?? 'N/A',
      'Vitamin C': json['vitamin_c']?.toString() ?? 'N/A',
      'Calcium': json['calcium']?.toString() ?? 'N/A',
      'Iron': json['iron']?.toString() ?? 'N/A',
    };

    return NutritionResultModel(
      foodName: json['food_name']?.toString() ?? 'Unknown Food',
      calories: json['calories']?.toString() ?? 'N/A',
      nutrients: nutrientsMap,
      healthOverview: json['health_overview']?.toString(),
      positiveAspects: posList,
      negativeAspects: negList,
    );
  }
}
