import 'package:flutter/material.dart';
import 'dart:math';
import 'package:app/services/stats_service.dart';

class GeometryPage extends StatefulWidget {
  @override
  State<GeometryPage> createState() {
    return _GeometryPageState();
  }
}

class _GeometryPageState extends State<GeometryPage> {
  int currentQuestionIndex = 0;
  List<GeometryQuestion> questions = [];
  String? selectedAnswer;
  bool showResult = false;
  int correctAnswers = 0;
  Random random = Random();
  String _selectedDifficulty = 'easy';
  String _selectedTopic = 'mixed'; // mixed | measurement | algebraic
  bool _checking = false;

  // Feedback state
  List<String> _explanationSteps = [];
  String? _correctAnswerForFeedback;

  @override
  void initState() {
    super.initState();
    _generateQuestions();
  }

  int get _level {
    switch (_selectedDifficulty) {
      case 'hard':
        return 2;
      case 'medium':
        return 1;
      case 'easy':
      default:
        return 0;
    }
  }

  void _generateQuestions() {
    final level = _level;
    final measurement = [
      _generateTriangleQuestion(level),
      _generateAngleQuestion(level),
      _generateAreaQuestion(level),
      _generatePerimeterQuestion(level),
      _generateCircleQuestion(level),
    ];
    final algebraic = [
      _generateAlgebraicSquareQuestion(level),
      _generateAlgebraicRectangleQuestion(level),
      _generateAlgebraicTriangleQuestion(level),
    ];

    if (_selectedTopic == 'measurement') {
      questions = measurement;
    } else if (_selectedTopic == 'algebraic') {
      questions = algebraic;
    } else {
      questions = [...measurement, ...algebraic];
    }
  }

  GeometryQuestion _generateTriangleQuestion(int level) {
    // Ranges scale with difficulty
    final base = level == 0
        ? 5
        : level == 1
        ? 8
        : 12;
    int a = random.nextInt(base) + 3;
    int b = random.nextInt(base) + 3;
    int c = random.nextInt(base) + 3;

    // Make it a valid triangle
    if (a + b <= c) c = a + b - 1;
    if (a + c <= b) b = a + c - 1;
    if (b + c <= a) a = b + c - 1;

    String correctAnswer = c.toString();
    List<String> options = [
      correctAnswer,
      (c + 1 + level).toString(),
      (c - 1 - level).toString(),
      (c + 2 + level).toString(),
    ];
    options.shuffle();

    return GeometryQuestion(
      question:
          "In a triangle, if two sides are $a cm and $b cm, and the third side is x cm, find x:",
      options: options,
      correctAnswer: correctAnswer,
      type: QuestionType.triangle,
      visualData: {'a': a, 'b': b, 'c': c},
    );
  }

  GeometryQuestion _generateAngleQuestion(int level) {
    // Ensure a valid triangle with a reasonable spread
    int angle1 = random.nextInt(40 + level * 10) + 30; // 30 - up to 80/90
    int angle2 = 180 - angle1 - (random.nextInt(20 + level * 10) + 20);
    int angle3 = 180 - angle1 - angle2;

    String correctAnswer = angle3.toString();
    List<String> options = [
      correctAnswer,
      (angle3 + 5 + level * 5).toString(),
      (angle3 - 5 - level * 5).toString(),
      (angle3 + 8 + level * 4).toString(),
    ];
    options.shuffle();

    return GeometryQuestion(
      question:
          "In a triangle, if two angles are ${angle1}° and ${angle2}°, find the third angle x:",
      options: options,
      correctAnswer: correctAnswer,
      type: QuestionType.angle,
      visualData: {'angle1': angle1, 'angle2': angle2, 'angle3': angle3},
    );
  }

  GeometryQuestion _generateAreaQuestion(int level) {
    int length = random.nextInt(6 + level * 4) + (level == 2 ? 6 : 4);
    int width = random.nextInt(6 + level * 4) + (level == 2 ? 5 : 3);
    int area = length * width;

    String correctAnswer = area.toString();
    List<String> options = [
      correctAnswer,
      (area + 3 + level * 4).toString(),
      (area - 2 - level * 3).toString(),
      (length + width + level * 2).toString(),
    ];
    options.shuffle();

    return GeometryQuestion(
      question:
          "Find the area of a rectangle with length $length cm and width $width cm:",
      options: options,
      correctAnswer: correctAnswer,
      type: QuestionType.area,
      visualData: {'length': length, 'width': width, 'area': area},
    );
  }

  GeometryQuestion _generatePerimeterQuestion(int level) {
    int side1 = random.nextInt(6 + level * 4) + 3;
    int side2 = random.nextInt(6 + level * 4) + 3;
    int side3 = random.nextInt(6 + level * 4) + 3;
    int perimeter = side1 + side2 + side3;

    String correctAnswer = perimeter.toString();
    List<String> options = [
      correctAnswer,
      (perimeter + 2 + level * 2).toString(),
      (perimeter - 1 - level).toString(),
      (perimeter + side1 - level).toString(),
    ];
    options.shuffle();

    return GeometryQuestion(
      question:
          "Find the perimeter of a triangle with sides $side1 cm, $side2 cm, and $side3 cm:",
      options: options,
      correctAnswer: correctAnswer,
      type: QuestionType.perimeter,
      visualData: {
        'side1': side1,
        'side2': side2,
        'side3': side3,
        'perimeter': perimeter,
      },
    );
  }

  GeometryQuestion _generateCircleQuestion(int level) {
    int radius = random.nextInt(6 + level * 4) + 2;
    double area = 3.14159 * radius * radius;
    int roundedArea = area.round();

    String correctAnswer = roundedArea.toString();
    List<String> options = [
      correctAnswer,
      (roundedArea + 4 + level * 4).toString(),
      (roundedArea - 2 - level * 3).toString(),
      (radius * (2 + level)).toString(),
    ];
    options.shuffle();

    return GeometryQuestion(
      question:
          "Find the approximate area of a circle with radius $radius cm (use π ≈ 3.14):",
      options: options,
      correctAnswer: correctAnswer,
      type: QuestionType.circle,
      visualData: {'radius': radius, 'area': roundedArea},
    );
  }

  GeometryQuestion _generateAlgebraicSquareQuestion(int level) {
    // Generate x value (solution)
    int x = random.nextInt(6) + 2; // 2-7

    // Create two expressions that should be equal for a square
    int a = random.nextInt(2 + level) + 1; // 1..(2+level)
    int b = random.nextInt(4 + level * 2) + 1;

    // Second side = first side when x is the solution
    // First side: ax + b
    // Second side: c*x + d where c*x + d = a*x + b when solved
    int firstSide = a * x + b;

    // Create second expression
    int c = random.nextInt(2 + level) + 1;
    int d = firstSide - (c * x);

    String correctAnswer = x.toString();
    List<String> options = [
      correctAnswer,
      (x + 1 + level).toString(),
      (x - 1 - level).toString(),
      (x + 2 + level).toString(),
    ];
    options.shuffle();

    return GeometryQuestion(
      question:
          "In a square, one side is ${a}x + $b and another side is ${c}x + $d. Find x:",
      options: options,
      correctAnswer: correctAnswer,
      type: QuestionType.algebraicSquare,
      visualData: {'a': a, 'b': b, 'c': c, 'd': d, 'x': x},
    );
  }

  GeometryQuestion _generateAlgebraicRectangleQuestion(int level) {
    // For rectangle: opposite sides are equal
    int x = random.nextInt(5) + 3; // 3-7

    int a = random.nextInt(2 + level) + 2; // coefficient
    int b = random.nextInt(4 + level * 2) + 1; // constant

    // Length: ax + b
    int length = a * x + b;

    // Width: cx + d (should equal length's opposite side)
    int c = random.nextInt(1 + level) + 1;
    int d = length - (c * x);

    String correctAnswer = x.toString();
    List<String> options = [
      correctAnswer,
      (x + 1 + level).toString(),
      (x - 1 - level).toString(),
      (x + 2 + level).toString(),
    ];
    options.shuffle();

    return GeometryQuestion(
      question:
          "In a rectangle, the length is ${a}x + $b and the width is ${c}x + $d. If opposite sides are equal, find x:",
      options: options,
      correctAnswer: correctAnswer,
      type: QuestionType.algebraicRectangle,
      visualData: {'a': a, 'b': b, 'c': c, 'd': d, 'x': x, 'length': length},
    );
  }

  GeometryQuestion _generateAlgebraicTriangleQuestion(int level) {
    // For isosceles triangle: two sides are equal
    int x = random.nextInt(6) + 2; // 2-7

    int a = random.nextInt(2 + level) + 1;
    int b = random.nextInt(5 + level * 2) + 2;

    // Side 1: ax + b
    int side1 = a * x + b;

    // Side 2: cx + d (equal to side 1 for isosceles)
    int c = random.nextInt(1 + level) + 2;
    int d = side1 - (c * x);

    String correctAnswer = x.toString();
    List<String> options = [
      correctAnswer,
      (x + 1 + level).toString(),
      (x - 1 - level).toString(),
      (x + 2 + level).toString(),
    ];
    options.shuffle();

    return GeometryQuestion(
      question:
          "In an isosceles triangle, two equal sides are ${a}x + $b and ${c}x + $d. Find x:",
      options: options,
      correctAnswer: correctAnswer,
      type: QuestionType.algebraicTriangle,
      visualData: {'a': a, 'b': b, 'c': c, 'd': d, 'x': x},
    );
  }

  void _chooseAnswer(String answer) {
    if (showResult) return; // don't change after checking
    setState(() {
      selectedAnswer = answer;
    });
  }

  Future<void> _checkAnswer() async {
    if (selectedAnswer == null || _checking) return;
    setState(() => _checking = true);
    try {
      final q = questions[currentQuestionIndex];
      final isCorrect = selectedAnswer == q.correctAnswer;
      final steps = _buildExplanationSteps(q);
      setState(() {
        showResult = true;
        if (isCorrect) correctAnswers++;
        _explanationSteps = steps;
        _correctAnswerForFeedback = q.correctAnswer;
      });
      // Log attempt with selected difficulty
      await StatsService.instance.incrementAttempt(
        'Geometry',
        _selectedDifficulty,
        correct: isCorrect,
      );
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  void _nextQuestion() {
    setState(() {
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
        selectedAnswer = null;
        showResult = false;
        _explanationSteps = [];
        _correctAnswerForFeedback = null;
      } else {
        _showResults();
      }
    });
  }

  void _previousQuestion() {
    if (currentQuestionIndex == 0) return;
    setState(() {
      currentQuestionIndex--;
      selectedAnswer = null;
      showResult = false;
      _explanationSteps = [];
      _correctAnswerForFeedback = null;
    });
  }

  void _showResults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quiz Complete!'),
        content: Text(
          'You got $correctAnswers out of ${questions.length} questions correct!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetQuiz();
            },
            child: Text('Try Again'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _resetQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      selectedAnswer = null;
      showResult = false;
      correctAnswers = 0;
      _generateQuestions();
      _explanationSteps = [];
      _correctAnswerForFeedback = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Geometry Practice',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${currentQuestionIndex + 1}/${questions.length}',
              style: TextStyle(
                color: Colors.blue[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Topic and Difficulty Selectors (like Algebra)
              Row(
                children: [
                  Expanded(child: _buildTopicSelector()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDifficultySelector()),
                ],
              ),
              const SizedBox(height: 16),
              // Progress Bar
              Container(
                width: double.infinity,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (currentQuestionIndex + 1) / questions.length,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[400]!, Colors.blue[600]!],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Question Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.blue[50]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${currentQuestionIndex + 1}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      questions[currentQuestionIndex].question,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Visual representation
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: CustomPaint(
                        painter: QuestionVisualPainter(
                          questions[currentQuestionIndex],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Answer Options
              Text(
                'Choose your answer:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),

              ...questions[currentQuestionIndex].options.map((option) {
                bool isSelected = selectedAnswer == option;
                bool isCorrect =
                    option == questions[currentQuestionIndex].correctAnswer;
                bool showColors = showResult;

                Color backgroundColor = Colors.white;
                Color borderColor = Colors.grey[300]!;
                Color textColor = Colors.black87;

                if (showColors) {
                  if (isCorrect) {
                    backgroundColor = Colors.green[50]!;
                    borderColor = Colors.green[400]!;
                    textColor = Colors.green[700]!;
                  } else if (isSelected && !isCorrect) {
                    backgroundColor = Colors.red[50]!;
                    borderColor = Colors.red[400]!;
                    textColor = Colors.red[700]!;
                  }
                } else if (isSelected) {
                  backgroundColor = Colors.blue[50]!;
                  borderColor = Colors.blue[400]!;
                  textColor = Colors.blue[700]!;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: showResult ? null : () => _chooseAnswer(option),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        border: Border.all(color: borderColor, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                          ),
                          if (showColors && isCorrect)
                            Icon(Icons.check_circle, color: Colors.green[600]),
                          if (showColors && isSelected && !isCorrect)
                            Icon(Icons.cancel, color: Colors.red[600]),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 24),

              // Check Answer button (like Algebra)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (selectedAnswer == null || _checking)
                      ? null
                      : _checkAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[500],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_checking) ...[
                        const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ] else ...[
                        const Icon(Icons.check_circle_outline, size: 24),
                        const SizedBox(width: 8),
                      ],
                      const Text(
                        'Check Answer',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Feedback with explanation
              if (showResult) _buildAnswerFeedback(),

              const SizedBox(height: 24),

              // Navigation buttons like Algebra
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: currentQuestionIndex > 0
                          ? _previousQuestion
                          : null,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: currentQuestionIndex > 0
                              ? Colors.blue[400]!
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_back,
                            color: currentQuestionIndex > 0
                                ? Colors.blue[700]
                                : Colors.grey[400],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Previous',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: currentQuestionIndex > 0
                                  ? Colors.blue[700]
                                  : Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[500],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentQuestionIndex < questions.length - 1
                                ? 'Next'
                                : 'Finish',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTopic,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: Colors.blue[700]),
          style: TextStyle(
            color: Colors.blue[900],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          dropdownColor: Colors.blue[50],
          items: const [
            DropdownMenuItem(value: 'mixed', child: Text('MIXED')),
            DropdownMenuItem(value: 'measurement', child: Text('MEASUREMENT')),
            DropdownMenuItem(value: 'algebraic', child: Text('ALGEBRAIC')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedTopic = value;
                currentQuestionIndex = 0;
                selectedAnswer = null;
                showResult = false;
                correctAnswers = 0;
                _explanationSteps = [];
                _correctAnswerForFeedback = null;
                _generateQuestions();
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedDifficulty,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: Colors.orange[700]),
          style: TextStyle(
            color: Colors.orange[900],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          dropdownColor: Colors.orange[50],
          items: const [
            DropdownMenuItem(value: 'easy', child: Text('EASY')),
            DropdownMenuItem(value: 'medium', child: Text('MEDIUM')),
            DropdownMenuItem(value: 'hard', child: Text('HARD')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedDifficulty = value;
                currentQuestionIndex = 0;
                selectedAnswer = null;
                showResult = false;
                correctAnswers = 0;
                _explanationSteps = [];
                _correctAnswerForFeedback = null;
                _generateQuestions();
              });
            }
          },
        ),
      ),
    );
  }

  // Build detailed answer feedback
  Widget _buildAnswerFeedback() {
    final q = questions[currentQuestionIndex];
    final isCorrect = selectedAnswer == q.correctAnswer;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? Colors.green[300]! : Colors.red[300]!,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green[700] : Colors.red[700],
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'Correct!' : 'Incorrect',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green[900] : Colors.red[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Your answer: ${selectedAnswer ?? '-'}',
            style: TextStyle(color: Colors.grey[800]),
          ),
          const SizedBox(height: 4),
          Text(
            'Correct answer: ${_correctAnswerForFeedback ?? q.correctAnswer}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[900],
            ),
          ),
          if (_explanationSteps.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.school_outlined, color: Colors.purple[700]),
                const SizedBox(width: 6),
                Text(
                  'Explanation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[900],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._explanationSteps.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(
                      child: Text(
                        s,
                        style: TextStyle(color: Colors.grey[800], height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Create explanation steps for each question type
  List<String> _buildExplanationSteps(GeometryQuestion q) {
    switch (q.type) {
      case QuestionType.triangle:
        final a = q.visualData['a'];
        final b = q.visualData['b'];
        final c = q.visualData['c'];
        return [
          'The problem gives side lengths a=$a cm, b=$b cm and the third side as c=$c cm.',
          'Therefore x equals the provided third side: x = $c cm.',
        ];
      case QuestionType.angle:
        final a1 = q.visualData['angle1'];
        final a2 = q.visualData['angle2'];
        final a3 = q.visualData['angle3'];
        return [
          'The sum of interior angles in a triangle equals 180°. ',
          'Compute x = 180° - $a1° - $a2° = $a3°.',
        ];
      case QuestionType.area:
        final l = q.visualData['length'];
        final w = q.visualData['width'];
        final area = q.visualData['area'];
        return [
          'Area of a rectangle is A = length × width.',
          'Compute A = $l × $w = $area cm².',
        ];
      case QuestionType.perimeter:
        final s1 = q.visualData['side1'];
        final s2 = q.visualData['side2'];
        final s3 = q.visualData['side3'];
        final p = q.visualData['perimeter'];
        return [
          'Perimeter of a triangle is the sum of side lengths.',
          'Compute P = $s1 + $s2 + $s3 = $p cm.',
        ];
      case QuestionType.circle:
        final r = q.visualData['radius'];
        final a = q.visualData['area'];
        return [
          'Area of a circle is A = πr². Use π ≈ 3.14.',
          'Compute A ≈ 3.14 × $r × $r ≈ $a cm² (rounded).',
        ];
      case QuestionType.algebraicSquare:
        final a = q.visualData['a'];
        final b = q.visualData['b'];
        final c = q.visualData['c'];
        final d = q.visualData['d'];
        return [
          'In a square, all sides are equal so set the expressions equal: ${a}x + $b = ${c}x + $d.',
          'Rearrange: (${a} - ${c})x = ${d - b}.',
          if ((a - c) != 0)
            'Solve for x: x = (${d - b})/(${a - c}).'
          else
            'Coefficients equal; values chosen ensure sides equal for the given x.',
        ];
      case QuestionType.algebraicRectangle:
        final a = q.visualData['a'];
        final b = q.visualData['b'];
        final c = q.visualData['c'];
        final d = q.visualData['d'];
        return [
          'Opposite sides in a rectangle are equal.',
          'Set expressions equal: ${a}x + $b = ${c}x + $d.',
          'Rearrange: (${a} - ${c})x = ${d - b}, then solve x = (${d - b})/(${a - c}).',
        ];
      case QuestionType.algebraicTriangle:
        final a = q.visualData['a'];
        final b = q.visualData['b'];
        final c = q.visualData['c'];
        final d = q.visualData['d'];
        return [
          'In an isosceles triangle, two sides are equal.',
          'Set ${a}x + $b = ${c}x + $d and solve for x.',
        ];
    }
  }
}

enum QuestionType {
  triangle,
  angle,
  area,
  perimeter,
  circle,
  algebraicSquare,
  algebraicRectangle,
  algebraicTriangle,
}

class GeometryQuestion {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final QuestionType type;
  final Map<String, dynamic> visualData;

  GeometryQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.type,
    required this.visualData,
  });
}

class QuestionVisualPainter extends CustomPainter {
  final GeometryQuestion question;

  QuestionVisualPainter(this.question);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    switch (question.type) {
      case QuestionType.triangle:
        _drawTriangle(canvas, size, paint, textPainter);
        break;
      case QuestionType.angle:
        _drawAngleQuestion(canvas, size, paint, textPainter);
        break;
      case QuestionType.area:
        _drawRectangle(canvas, size, paint, textPainter);
        break;
      case QuestionType.perimeter:
        _drawPerimeterTriangle(canvas, size, paint, textPainter);
        break;
      case QuestionType.circle:
        _drawCircle(canvas, size, paint, textPainter);
        break;
      case QuestionType.algebraicSquare:
        _drawAlgebraicSquare(canvas, size, paint, textPainter);
        break;
      case QuestionType.algebraicRectangle:
        _drawAlgebraicRectangle(canvas, size, paint, textPainter);
        break;
      case QuestionType.algebraicTriangle:
        _drawAlgebraicTriangle(canvas, size, paint, textPainter);
        break;
    }
  }

  void _drawTriangle(
    Canvas canvas,
    Size size,
    Paint paint,
    TextPainter textPainter,
  ) {
    paint.color = Colors.blue[600]!;

    final center = Offset(size.width / 2, size.height / 2);
    final triangleSize = 100.0;

    final p1 = Offset(center.dx, center.dy - triangleSize / 2);
    final p2 = Offset(
      center.dx - triangleSize / 2,
      center.dy + triangleSize / 2,
    );
    final p3 = Offset(
      center.dx + triangleSize / 2,
      center.dy + triangleSize / 2,
    );

    final path = Path();
    path.moveTo(p1.dx, p1.dy);
    path.lineTo(p2.dx, p2.dy);
    path.lineTo(p3.dx, p3.dy);
    path.close();

    canvas.drawPath(path, paint);

    // Labels
    _drawText(
      canvas,
      '${question.visualData['a']} cm',
      Offset(p2.dx - 20, p2.dy + 10),
      textPainter,
    );
    _drawText(
      canvas,
      '${question.visualData['b']} cm',
      Offset(p3.dx + 10, p3.dy + 10),
      textPainter,
    );
    _drawText(
      canvas,
      'x cm',
      Offset(center.dx + 30, center.dy - 20),
      textPainter,
    );
  }

  void _drawAngleQuestion(
    Canvas canvas,
    Size size,
    Paint paint,
    TextPainter textPainter,
  ) {
    paint.color = Colors.purple[600]!;

    final center = Offset(size.width / 2, size.height / 2 + 20);
    final lineLength = 80.0;

    // Draw triangle
    final p1 = Offset(center.dx, center.dy - 60);
    final p2 = Offset(center.dx - lineLength, center.dy + 40);
    final p3 = Offset(center.dx + lineLength, center.dy + 40);

    final path = Path();
    path.moveTo(p1.dx, p1.dy);
    path.lineTo(p2.dx, p2.dy);
    path.lineTo(p3.dx, p3.dy);
    path.close();

    canvas.drawPath(path, paint);

    // Angle labels
    _drawText(
      canvas,
      '${question.visualData['angle1']}°',
      Offset(p1.dx - 15, p1.dy - 20),
      textPainter,
    );
    _drawText(
      canvas,
      '${question.visualData['angle2']}°',
      Offset(p2.dx - 30, p2.dy - 10),
      textPainter,
    );
    _drawText(canvas, 'x°', Offset(p3.dx + 10, p3.dy - 10), textPainter);
  }

  void _drawRectangle(
    Canvas canvas,
    Size size,
    Paint paint,
    TextPainter textPainter,
  ) {
    paint.color = Colors.green[600]!;

    final center = Offset(size.width / 2, size.height / 2);
    final rectWidth = 120.0;
    final rectHeight = 80.0;

    final rect = Rect.fromCenter(
      center: center,
      width: rectWidth,
      height: rectHeight,
    );
    canvas.drawRect(rect, paint);

    // Labels
    _drawText(
      canvas,
      '${question.visualData['length']} cm',
      Offset(center.dx, rect.bottom + 15),
      textPainter,
    );
    _drawText(
      canvas,
      '${question.visualData['width']} cm',
      Offset(rect.left - 25, center.dy),
      textPainter,
    );
  }

  void _drawPerimeterTriangle(
    Canvas canvas,
    Size size,
    Paint paint,
    TextPainter textPainter,
  ) {
    paint.color = Colors.orange[600]!;

    final center = Offset(size.width / 2, size.height / 2);
    final triangleSize = 100.0;

    final p1 = Offset(center.dx, center.dy - triangleSize / 2);
    final p2 = Offset(
      center.dx - triangleSize / 2,
      center.dy + triangleSize / 2,
    );
    final p3 = Offset(
      center.dx + triangleSize / 2,
      center.dy + triangleSize / 2,
    );

    final path = Path();
    path.moveTo(p1.dx, p1.dy);
    path.lineTo(p2.dx, p2.dy);
    path.lineTo(p3.dx, p3.dy);
    path.close();

    canvas.drawPath(path, paint);

    // Side labels
    _drawText(
      canvas,
      '${question.visualData['side1']} cm',
      Offset(p1.dx - 40, center.dy - 10),
      textPainter,
    );
    _drawText(
      canvas,
      '${question.visualData['side2']} cm',
      Offset(center.dx + 30, center.dy - 10),
      textPainter,
    );
    _drawText(
      canvas,
      '${question.visualData['side3']} cm',
      Offset(center.dx, p2.dy + 15),
      textPainter,
    );
  }

  void _drawCircle(
    Canvas canvas,
    Size size,
    Paint paint,
    TextPainter textPainter,
  ) {
    paint.color = Colors.red[600]!;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = 60.0;

    canvas.drawCircle(center, radius, paint);

    // Draw radius line
    canvas.drawLine(center, Offset(center.dx + radius, center.dy), paint);

    // Radius label
    _drawText(
      canvas,
      '${question.visualData['radius']} cm',
      Offset(center.dx + 20, center.dy - 10),
      textPainter,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position,
    TextPainter textPainter,
  ) {
    textPainter.text = TextSpan(
      text: text,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  void _drawAlgebraicSquare(
    Canvas canvas,
    Size size,
    Paint paint,
    TextPainter textPainter,
  ) {
    paint.color = Colors.indigo[600]!;

    final center = Offset(size.width / 2, size.height / 2);
    final squareSize = 100.0;

    final rect = Rect.fromCenter(
      center: center,
      width: squareSize,
      height: squareSize,
    );
    canvas.drawRect(rect, paint);

    // Draw equal marks on opposite sides
    final markPaint = Paint()
      ..strokeWidth = 2
      ..color = Colors.indigo[800]!;

    // Top side mark
    canvas.drawLine(
      Offset(center.dx - 5, rect.top - 5),
      Offset(center.dx + 5, rect.top - 5),
      markPaint,
    );

    // Bottom side mark
    canvas.drawLine(
      Offset(center.dx - 5, rect.bottom + 5),
      Offset(center.dx + 5, rect.bottom + 5),
      markPaint,
    );

    // Labels with algebraic expressions
    final a = question.visualData['a'];
    final b = question.visualData['b'];
    final c = question.visualData['c'];
    final d = question.visualData['d'];

    _drawText(
      canvas,
      '${a}x ${b >= 0 ? '+' : ''} $b',
      Offset(center.dx - 30, rect.top - 25),
      textPainter,
    );
    _drawText(
      canvas,
      '${c}x ${d >= 0 ? '+' : ''} $d',
      Offset(center.dx - 30, rect.bottom + 15),
      textPainter,
    );
  }

  void _drawAlgebraicRectangle(
    Canvas canvas,
    Size size,
    Paint paint,
    TextPainter textPainter,
  ) {
    paint.color = Colors.teal[600]!;

    final center = Offset(size.width / 2, size.height / 2);
    final rectWidth = 130.0;
    final rectHeight = 85.0;

    final rect = Rect.fromCenter(
      center: center,
      width: rectWidth,
      height: rectHeight,
    );
    canvas.drawRect(rect, paint);

    // Draw equal marks on opposite sides
    final markPaint = Paint()
      ..strokeWidth = 2
      ..color = Colors.teal[800]!;

    // Top and bottom marks (length)
    canvas.drawLine(
      Offset(center.dx, rect.top - 5),
      Offset(center.dx, rect.top - 10),
      markPaint,
    );
    canvas.drawLine(
      Offset(center.dx, rect.bottom + 5),
      Offset(center.dx, rect.bottom + 10),
      markPaint,
    );

    // Labels
    final a = question.visualData['a'];
    final b = question.visualData['b'];
    final c = question.visualData['c'];
    final d = question.visualData['d'];

    _drawText(
      canvas,
      '${a}x ${b >= 0 ? '+' : ''} $b',
      Offset(center.dx - 35, rect.top - 30),
      textPainter,
    );
    _drawText(
      canvas,
      '${c}x ${d >= 0 ? '+' : ''} $d',
      Offset(rect.left - 50, center.dy - 5),
      textPainter,
    );
  }

  void _drawAlgebraicTriangle(
    Canvas canvas,
    Size size,
    Paint paint,
    TextPainter textPainter,
  ) {
    paint.color = Colors.deepOrange[600]!;

    final center = Offset(size.width / 2, size.height / 2);
    final triangleSize = 100.0;

    final p1 = Offset(center.dx, center.dy - triangleSize / 2);
    final p2 = Offset(
      center.dx - triangleSize / 2,
      center.dy + triangleSize / 2,
    );
    final p3 = Offset(
      center.dx + triangleSize / 2,
      center.dy + triangleSize / 2,
    );

    final path = Path();
    path.moveTo(p1.dx, p1.dy);
    path.lineTo(p2.dx, p2.dy);
    path.lineTo(p3.dx, p3.dy);
    path.close();

    canvas.drawPath(path, paint);

    // Draw equal marks on two sides (isosceles)
    final markPaint = Paint()
      ..strokeWidth = 2
      ..color = Colors.deepOrange[800]!;

    // Mark on left side
    final leftMid = Offset((p1.dx + p2.dx) / 2 - 3, (p1.dy + p2.dy) / 2);
    canvas.drawLine(
      Offset(leftMid.dx - 3, leftMid.dy - 3),
      Offset(leftMid.dx + 3, leftMid.dy + 3),
      markPaint,
    );

    // Mark on right side
    final rightMid = Offset((p1.dx + p3.dx) / 2 + 3, (p1.dy + p3.dy) / 2);
    canvas.drawLine(
      Offset(rightMid.dx - 3, rightMid.dy - 3),
      Offset(rightMid.dx + 3, rightMid.dy + 3),
      markPaint,
    );

    // Labels
    final a = question.visualData['a'];
    final b = question.visualData['b'];
    final c = question.visualData['c'];
    final d = question.visualData['d'];

    _drawText(
      canvas,
      '${a}x ${b >= 0 ? '+' : ''} $b',
      Offset(p1.dx - 50, center.dy - 15),
      textPainter,
    );
    _drawText(
      canvas,
      '${c}x ${d >= 0 ? '+' : ''} $d',
      Offset(p1.dx + 20, center.dy - 15),
      textPainter,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
