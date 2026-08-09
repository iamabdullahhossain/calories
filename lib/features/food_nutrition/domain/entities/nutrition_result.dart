class NutritionResult {
  final String foodName;
  final String calories;
  final Map<String, String> nutrients;
  final String? healthOverview;
  final List<String> positiveAspects;
  final List<String> negativeAspects;

  const NutritionResult({
    required this.foodName,
    required this.calories,
    required this.nutrients,
    this.healthOverview,
    required this.positiveAspects,
    required this.negativeAspects,
  });
}
