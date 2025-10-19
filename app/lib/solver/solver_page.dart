import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SolverPage extends StatefulWidget {
  const SolverPage({super.key});

  @override
  State<SolverPage> createState() => _SolverPageState();
}

class _SolverPageState extends State<SolverPage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  Map<String, dynamic>? _aiResponse;
  bool _isProcessing = false;

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _aiResponse = null; // Clear previous results
        });
        await _processImage();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error selecting image: $e')));
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _aiResponse = null; // Clear previous results
        });
        await _processImage();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error taking photo: $e')));
    }
  }

  Future<void> _processImage() async {
    setState(() {
      _isProcessing = true;
    });

    // TODO: Replace this with your actual API call
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call

    // Mock response - replace with actual API response
    setState(() {
      _aiResponse = {
        "extracted_text":
            "1. (a) (i) Calculate the value of √(7.1)² + (2.9)² , giving your answer correct to a) 2 significant figures",
        "question":
            "Calculate the value of √(7.1)² + (2.9)², giving your answer correct to 2 significant figures.",
        "answer_analysis": {
          "total_steps": 5,
          "steps": [
            {
              "step_number": 1,
              "description": "Calculate the square of the first number (7.1).",
              "step_calculation": "(7.1)² = 7.1 × 7.1 = 50.41",
              "eli5_explanation":
                  "First, we take the number 7.1 and multiply it by itself. It's like building a square where each side is 7.1 units long, and we're finding its area.",
              "key_concept": "Squaring a number",
            },
            {
              "step_number": 2,
              "description": "Calculate the square of the second number (2.9).",
              "step_calculation": "(2.9)² = 2.9 × 2.9 = 8.41",
              "eli5_explanation":
                  "Next, we do the same thing for the second number, 2.9. We multiply 2.9 by 2.9 to find its 'square'.",
              "key_concept": "Squaring a number",
            },
            {
              "step_number": 3,
              "description": "Add the results from Step 1 and Step 2.",
              "step_calculation": "50.41 + 8.41 = 58.82",
              "eli5_explanation":
                  "Now we have two 'square' numbers. The plus sign (+) tells us to put them together, so we add 50.41 and 8.41.",
              "key_concept": "Addition",
            },
            {
              "step_number": 4,
              "description": "Calculate the square root of the sum.",
              "step_calculation": "√58.82 ≈ 7.6694185...",
              "eli5_explanation":
                  "The big 'checkmark' symbol (√) means we need to find a number that, when multiplied by itself, gives us 58.82. It's like figuring out the side length of a square if you know its area is 58.82.",
              "key_concept": "Square root",
            },
            {
              "step_number": 5,
              "description": "Round the final answer to 2 significant figures.",
              "step_calculation":
                  "7.6694185... rounded to 2 significant figures is 7.7",
              "eli5_explanation":
                  "We need to make our answer shorter, showing only the two most important numbers (significant figures). We look at the first two numbers (7 and 6). Because the third number (6) is 5 or more, we round up the second number (6) to 7. So, the answer becomes 7.7.",
              "key_concept": "Rounding to significant figures",
            },
          ],
        },
        "summary":
            "This problem requires calculating the squares of two numbers, adding them together, finding the square root of the sum, and finally rounding the result to two significant figures.",
      };
      _isProcessing = false;
    });
  }

  void _uploadAnotherImage() {
    setState(() {
      _selectedImage = null;
      _aiResponse = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color:
              theme.brightness == Brightness.light
                  ? const Color(0xFFF5F7F8)
                  : const Color(0xFF101922),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Mathix',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color:
                        theme.brightness == Brightness.light
                            ? const Color(0xFF111418)
                            : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lexend',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Main content
              Expanded(
                child:
                    _aiResponse != null
                        ? _buildResultsView(theme)
                        : _buildUploadView(theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadView(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image placeholder or selected image
          Container(
            width: double.infinity,
            height: 256,
            margin: const EdgeInsets.only(bottom: 32),
            decoration: BoxDecoration(
              color:
                  theme.brightness == Brightness.light
                      ? Colors.grey[200]
                      : Colors.grey[700]?.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                _isProcessing
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: const Color(0xFF7C3AED),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Processing...',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Lexend',
                              color:
                                  theme.brightness == Brightness.light
                                      ? const Color(0xFF111418)
                                      : Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                    )
                    : _selectedImage != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                    )
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image,
                          size: 80,
                          color:
                              theme.brightness == Brightness.light
                                  ? Colors.grey[400]
                                  : Colors.grey[500],
                        ),
                      ],
                    ),
          ),

          // Buttons
          Column(
            children: [
              // Upload from Gallery button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _pickImageFromGallery,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  icon: const Icon(Icons.photo_library, size: 24),
                  label: const Text(
                    'Upload from Gallery',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lexend',
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Camera button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _pickImageFromCamera,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        theme.brightness == Brightness.light
                            ? const Color(0xFF7C3AED).withOpacity(0.2)
                            : const Color(0xFF7C3AED).withOpacity(0.3),
                    foregroundColor:
                        theme.brightness == Brightness.light
                            ? const Color(0xFF7C3AED)
                            : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  icon: Icon(
                    Icons.photo_camera,
                    size: 24,
                    color:
                        theme.brightness == Brightness.light
                            ? const Color(0xFF7C3AED)
                            : Colors.white,
                  ),
                  label: Text(
                    'Camera',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lexend',
                      color:
                          theme.brightness == Brightness.light
                              ? const Color(0xFF7C3AED)
                              : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Description text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Upload an image of a math problem to get started.',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Lexend',
                color:
                    theme.brightness == Brightness.light
                        ? const Color(0xFF111418)
                        : Colors.grey[300],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView(ThemeData theme) {
    final steps = _aiResponse!['answer_analysis']['steps'] as List;
    final question = _aiResponse!['question'] as String;
    final summary = _aiResponse!['summary'] as String;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  theme.brightness == Brightness.light
                      ? Colors.white
                      : const Color(0xFF1A2633),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lexend',
                    color: const Color(0xFF7C3AED),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  question,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Lexend',
                    color:
                        theme.brightness == Brightness.light
                            ? const Color(0xFF111418)
                            : Colors.grey[200],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Steps Section
          Text(
            'Solution Steps',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Lexend',
              color:
                  theme.brightness == Brightness.light
                      ? const Color(0xFF111418)
                      : Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          // Step Cards
          ...steps.map((step) => _buildStepCard(theme, step)).toList(),

          const SizedBox(height: 24),

          // Summary Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  theme.brightness == Brightness.light
                      ? const Color(0xFF7C3AED).withOpacity(0.1)
                      : const Color(0xFF7C3AED).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF7C3AED).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: const Color(0xFF7C3AED),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Lexend',
                        color: const Color(0xFF7C3AED),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  summary,
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Lexend',
                    color:
                        theme.brightness == Brightness.light
                            ? const Color(0xFF111418)
                            : Colors.grey[200],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Upload Another Image Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _uploadAnotherImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              icon: const Icon(Icons.upload, size: 24),
              label: const Text(
                'Upload Another Image',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lexend',
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStepCard(ThemeData theme, Map<String, dynamic> step) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            theme.brightness == Brightness.light
                ? Colors.white
                : const Color(0xFF1A2633),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${step['step_number']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Lexend',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step['key_concept'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lexend',
                    color: const Color(0xFF7C3AED),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Description
          Text(
            step['description'],
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: 'Lexend',
              color:
                  theme.brightness == Brightness.light
                      ? const Color(0xFF111418)
                      : Colors.grey[200],
            ),
          ),

          const SizedBox(height: 8),

          // Calculation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  theme.brightness == Brightness.light
                      ? Colors.grey[100]
                      : Colors.grey[800]?.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              step['step_calculation'],
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Courier New',
                fontWeight: FontWeight.w500,
                color:
                    theme.brightness == Brightness.light
                        ? const Color(0xFF111418)
                        : Colors.grey[300],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ELI5 Explanation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  theme.brightness == Brightness.light
                      ? Colors.blue[50]
                      : Colors.blue[900]?.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    theme.brightness == Brightness.light
                        ? Colors.blue[200]!
                        : Colors.blue[700]!,
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color:
                      theme.brightness == Brightness.light
                          ? Colors.blue[700]
                          : Colors.blue[300],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    step['eli5_explanation'],
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Lexend',
                      color:
                          theme.brightness == Brightness.light
                              ? Colors.blue[900]
                              : Colors.blue[200],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
