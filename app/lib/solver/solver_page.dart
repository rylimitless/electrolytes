import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

class SolverPage extends StatefulWidget {
  const SolverPage({super.key});

  @override
  State<SolverPage> createState() => _SolverPageState();
}

class _SolverPageState extends State<SolverPage> {
  String? _selectedImage;
  XFile? _selectedXFile;
  final ImagePicker _picker = ImagePicker();
  Map<String, dynamic>? _aiResponse;
  bool _isProcessing = false;

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = image.path;
          _selectedXFile = image;
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
          _selectedImage = image.path;
          _selectedXFile = image;
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

    try {
      // Upload image to backend and get processed results
      final response = await _uploadImageToBackend();

      setState(() {
        _aiResponse = response;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing image: $e')),
      );
    }
  }

  Future<Map<String, dynamic>> _uploadImageToBackend() async {
    if (_selectedImage == null) {
      throw Exception('No image selected');
    }

    // Backend URL - update this to match your actual backend URL
    const String backendUrl = 'http://52.3.253.79:8000';

    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$backendUrl/upload'),
      );

      // Add image file - handle web vs mobile differently
      http.MultipartFile file;
      if (kIsWeb && _selectedImage!.startsWith('blob:')) {
        // For web, we need to fetch the blob and convert it
        final response = await http.get(Uri.parse(_selectedImage!));

        // Use XFile's mime type for proper content type detection
        String contentType = 'image/jpeg'; // Default fallback
        String filename = 'image.jpg'; // Default fallback

        if (_selectedXFile != null) {
          contentType = _selectedXFile!.mimeType ?? 'image/jpeg';
          filename = _selectedXFile!.name;

          // Ensure filename has proper extension
          if (!filename.contains('.')) {
            filename = contentType.endsWith('png') ? 'image.png' : 'image.jpg';
          }
        } else {
          // Fallback if XFile is not available
          contentType = 'image/jpeg';
          filename = 'image.jpg';
        }

        file = http.MultipartFile.fromBytes(
          'file',
          response.bodyBytes,
          filename: filename,
          contentType: MediaType.parse(contentType),
        );
      } else {
        // For mobile/desktop, use the file path
        file = await http.MultipartFile.fromPath(
          'file',
          File(_selectedImage!).path,
        );
      }
      request.files.add(file);

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        
        // Debug: Print the response structure
        print('Backend response: ${response.body}');

        // The backend returns an object with webhook_response field containing an array
        // Check if we have the webhook_response field with array data
        if (responseData['webhook_response'] != null && 
            responseData['webhook_response'] is List &&
            (responseData['webhook_response'] as List).isNotEmpty) {
          var webhookData = responseData['webhook_response'][0];
          
          // Return the processed data structure from the webhook
          return {
            "extracted_text": webhookData['extracted_text'] ?? 'No text extracted',
            "question": webhookData['question'] ?? 'Math problem detected',
            "answer_analysis": webhookData['answer_analysis'] ?? {
              "total_steps": 0,
              "steps": [],
            },
            "summary": webhookData['summary'] ?? 'Solution provided.',
          };
        }
        // Fallback: check for direct response format (array at root level)
        else if (responseData is List && responseData.isNotEmpty) {
          var webhookData = responseData[0];
          
          return {
            "extracted_text": webhookData['extracted_text'] ?? 'No text extracted',
            "question": webhookData['question'] ?? 'Math problem detected',
            "answer_analysis": webhookData['answer_analysis'] ?? {
              "total_steps": 0,
              "steps": [],
            },
            "summary": webhookData['summary'] ?? 'Solution provided.',
          };
        }
        // Check if webhook_status indicates success but no response data
        else if (responseData['webhook_status'] != null && 
                 responseData['webhook_status']['success'] == true) {
          // Check if webhook_response exists but is empty
          if (responseData['webhook_response'] != null) {
            throw Exception('Image uploaded but AI returned empty response. Please try again.');
          } else {
            throw Exception('Image uploaded but no solution data received from AI. Please try again.');
          }
        }
        else {
          throw Exception('Unexpected response format from server: ${response.body.substring(0, 100)}...');
        }
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  void _uploadAnotherImage() {
    setState(() {
      _selectedImage = null;
      _selectedXFile = null;
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
                      child: _selectedImage!.startsWith('blob:')
                        ? Image.network(_selectedImage!, fit: BoxFit.cover)
                        : Image.asset(_selectedImage!, fit: BoxFit.cover),
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
    final question = _aiResponse!['extracted_text'] as String? ?? _aiResponse!['question'] as String? ?? 'Math problem detected';
    final summary = _aiResponse!['summary'] as String? ?? 'Solution provided';

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step['key_concept'] ?? 'Step ${step['step_number']}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Lexend',
                        color: const Color(0xFF7C3AED),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step['description'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Lexend',
                        color: theme.brightness == Brightness.light
                            ? const Color(0xFF111418)
                            : Colors.grey[200],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Calculation
          if (step['step_calculation'] != null) ...[
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
          ],

          // ELI5 Explanation
          if (step['eli5_explanation'] != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    theme.brightness == Brightness.light
                        ? Colors.amber[50]
                        : Colors.amber[900]?.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      theme.brightness == Brightness.light
                          ? Colors.amber[200]!
                          : Colors.amber[700]!,
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 20,
                    color:
                        theme.brightness == Brightness.light
                            ? Colors.amber[700]
                            : Colors.amber[300],
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
                                ? Colors.amber[900]
                                : Colors.amber[200],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
