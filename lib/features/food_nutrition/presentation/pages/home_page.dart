import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/nutrition_provider.dart';
import '../widgets/api_key_card.dart';
import '../widgets/food_image_picker_card.dart';
import '../widgets/insights_card.dart';
import '../widgets/nutrition_table_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _apiKeyController = TextEditingController(
    text: 'AQ.Ab8RN6IIjhx8418q4gyd3Syev0zc6aKPbqU-OnFJc4qvGzuZtQ',
  );

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nutritionNotifierProvider);
    final notifier = ref.read(nutritionNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Gemini Food Scanner 🥗',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // API Key Input Card
            ApiKeyCard(controller: _apiKeyController),
            const SizedBox(height: 20),

            // Image Display Container
            FoodImagePickerCard(imageFile: state.imageFile),
            const SizedBox(height: 20),

            // Camera Button
            ElevatedButton.icon(
              onPressed: state.isLoading
                  ? null
                  : () => notifier.analyzeImage(
                        source: ImageSource.camera,
                        apiKey: _apiKeyController.text,
                      ),
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              label: const Text(
                'Take Photo with Camera',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
            ),
            const SizedBox(height: 10),

            // Gallery Option
            OutlinedButton.icon(
              onPressed: state.isLoading
                  ? null
                  : () => notifier.analyzeImage(
                        source: ImageSource.gallery,
                        apiKey: _apiKeyController.text,
                      ),
              icon: const Icon(Icons.photo_library, color: Color(0xFF10B981)),
              label: const Text(
                'Choose from Gallery',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF10B981),
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFF10B981)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Loading Indicator
            if (state.isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Color(0xFF10B981)),
                    SizedBox(height: 12),
                    Text(
                      'Gemini AI is analyzing your food photo...',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // Error Display
            if (state.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),

            // Nutrition Results & Insights Display
            if (state.result != null && !state.isLoading) ...[
              const Text(
                'AI Nutrition Analysis',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 14),

              // Health Overview Card
              if (state.result!.healthOverview != null &&
                  state.result!.healthOverview!.isNotEmpty) ...[
                Card(
                  elevation: 0,
                  color: const Color(0xFFEFF6FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFBFDBFE)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: Color(0xFF2563EB)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            state.result!.healthOverview!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1E40AF),
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Positive Aspects
              InsightsCard(
                title: 'Positive Aspects (ভাল দিকসমূহ)',
                items: state.result!.positiveAspects,
                icon: Icons.thumb_up_rounded,
                iconColor: const Color(0xFF059669),
                bgColor: const Color(0xFFECFDF5),
                borderColor: const Color(0xFFA7F3D0),
                textColor: const Color(0xFF065F46),
              ),
              if (state.result!.positiveAspects.isNotEmpty)
                const SizedBox(height: 14),

              // Negative Aspects
              InsightsCard(
                title: 'Considerations / Risks (সতর্কতা / নেতিবাচক দিক)',
                items: state.result!.negativeAspects,
                icon: Icons.warning_amber_rounded,
                iconColor: const Color(0xFFDC2626),
                bgColor: const Color(0xFFFEF2F2),
                borderColor: const Color(0xFFFECACA),
                textColor: const Color(0xFF991B1B),
              ),
              if (state.result!.negativeAspects.isNotEmpty)
                const SizedBox(height: 14),

              // Nutrients Breakdown Table
              NutritionTableCard(result: state.result!),
            ],
          ],
        ),
      ),
    );
  }
}
