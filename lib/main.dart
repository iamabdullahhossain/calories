import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() {
  runApp(const FoodNutritionApp());
}

class FoodNutritionApp extends StatelessWidget {
  const FoodNutritionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Nutrition Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10B981),
          brightness: Brightness.light,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _apiKeyController = TextEditingController();
  
  File? _imageFile;
  bool _isLoading = false;
  Map<String, String>? _nutritionData;
  String? _errorMessage;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _analyzeImageWithGemini(ImageSource source) async {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your Gemini API key first!'),
          backgroundColor: Colors.redAccent,
        ),
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

      setState(() {
        _imageFile = File(pickedFile.path);
        _isLoading = true;
        _nutritionData = null;
        _errorMessage = null;
      });

      // Use direct REST API call to guarantee compatibility with gemini-flash-latest and v1beta endpoint
      final imageBytes = await pickedFile.readAsBytes();
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
Analyze this food image and provide its estimated nutrition info.
Respond ONLY in pure valid JSON format with the exact keys:
{
  "food_name": "Name of the food",
  "calories": "e.g., 350 kcal",
  "protein": "e.g., 20 g",
  "carbs": "e.g., 40 g",
  "fat": "e.g., 12 g",
  "fiber": "e.g., 5 g"
}
If the image does not contain food, set "food_name" to "Not a food item" and put "N/A" for others. Do not include markdown code block formatting.
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
      
      // Print API Response to Console Log
      print('=================== GEMINI API RESPONSE ===================');
      print('Status Code: ${httpResponse.statusCode}');
      print('Response Body: $responseBody');
      print('===========================================================');

      final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);

      if (httpResponse.statusCode != 200) {
        final errorMsg = jsonResponse['error']?['message'] ?? 'API Error (${httpResponse.statusCode})';
        throw Exception(errorMsg);
      }

      final text = jsonResponse['candidates']?[0]?['content']?['parts']?[0]?['text']?.trim() ?? '';
      print('Extracted Text: $text');
      
      // Clean json string if backticks exist
      String cleanJson = text;
      if (cleanJson.startsWith('```')) {
        cleanJson = cleanJson.replaceAll(RegExp(r'^```(json)?|```$'), '').trim();
      }

      final Map<String, dynamic> decoded = jsonDecode(cleanJson);

      setState(() {
        _isLoading = false;
        _nutritionData = {
          'Food Name': decoded['food_name'] ?? 'Unknown Food',
          'Calories': decoded['calories'] ?? 'N/A',
          'Protein': decoded['protein'] ?? 'N/A',
          'Carbs': decoded['carbs'] ?? 'N/A',
          'Fat': decoded['fat'] ?? 'N/A',
          'Fiber': decoded['fiber'] ?? 'N/A',
        };
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to analyze image. Please check API Key or try again.\nError: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.key, color: Color(0xFF10B981), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Gemini API Key',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _apiKeyController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Paste your Gemini API key here',
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Image Display Container
            Container(
              height: 260,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.withOpacity(0.15),
                ),
              ),
              child: _imageFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.file(
                        _imageFile!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 44,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Snap or upload a food photo',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 20),

            // Camera Button
            ElevatedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () => _analyzeImageWithGemini(ImageSource.camera),
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
              onPressed: _isLoading
                  ? null
                  : () => _analyzeImageWithGemini(ImageSource.gallery),
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
            if (_isLoading)
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
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),

            // Nutrition Results Display
            if (_nutritionData != null && !_isLoading) ...[
              const Text(
                'AI Nutrition Analysis',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 14),
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey.withOpacity(0.15)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _nutritionData!['Food Name'] ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _nutritionData!['Calories'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 28),
                      _buildNutritionRow('Protein', _nutritionData!['Protein']!),
                      const SizedBox(height: 10),
                      _buildNutritionRow('Carbohydrates', _nutritionData!['Carbs']!),
                      const SizedBox(height: 10),
                      _buildNutritionRow('Fat', _nutritionData!['Fat']!),
                      const SizedBox(height: 10),
                      _buildNutritionRow('Dietary Fiber', _nutritionData!['Fiber']!),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF374151),
          ),
        ),
      ],
    );
  }
}
