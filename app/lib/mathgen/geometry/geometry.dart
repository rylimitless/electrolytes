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

  @override
  void initState() {
    super.initState();
    _generateQuestions();
  }

  void _generateQuestions() {
    questions = [
      _generateTriangleQuestion(),
      _generateAngleQuestion(),
      _generateAreaQuestion(),
      _generatePerimeterQuestion(),
      _generateCircleQuestion(),
      _generateAlgebraicSquareQuestion(),
      _generateAlgebraicRectangleQuestion(),
      _generateAlgebraicTriangleQuestion(),
    ];
  }

  GeometryQuestion _generateTriangleQuestion() {
    int a = random.nextInt(8) + 3; // 3-10
    int b = random.nextInt(8) + 3; // 3-10
    int c = random.nextInt(8) + 3; // 3-10

    // Make it a valid triangle
    if (a + b <= c) c = a + b - 1;
    if (a + c <= b) b = a + c - 1;
    if (b + c <= a) a = b + c - 1;

    String correctAnswer = c.toString();
    List<String> options = [
      correctAnswer,
      (c + 1).toString(),
      (c - 1).toString(),
      (c + 2).toString(),
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

  GeometryQuestion _generateAngleQuestion() {
    int angle1 = random.nextInt(60) + 30; // 30-89
    int angle2 =
        180 - angle1 - (random.nextInt(30) + 30); // Make valid triangle
    int angle3 = 180 - angle1 - angle2;

    String correctAnswer = angle3.toString();
    List<String> options = [
      correctAnswer,
      (angle3 + 10).toString(),
      (angle3 - 10).toString(),
      (angle3 + 15).toString(),
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

  GeometryQuestion _generateAreaQuestion() {
    int length = random.nextInt(8) + 4; // 4-11
    int width = random.nextInt(8) + 3; // 3-10
    int area = length * width;

    String correctAnswer = area.toString();
    List<String> options = [
      correctAnswer,
      (area + 5).toString(),
      (area - 3).toString(),
      (length + width).toString(),
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

  GeometryQuestion _generatePerimeterQuestion() {
    int side1 = random.nextInt(6) + 3; // 3-8
    int side2 = random.nextInt(6) + 3; // 3-8
    int side3 = random.nextInt(6) + 3; // 3-8
    int perimeter = side1 + side2 + side3;

    String correctAnswer = perimeter.toString();
    List<String> options = [
      correctAnswer,
      (perimeter + 2).toString(),
      (perimeter - 1).toString(),
      (perimeter * 2).toString(),
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

  GeometryQuestion _generateCircleQuestion() {
    int radius = random.nextInt(8) + 2; // 2-9
    double area = 3.14159 * radius * radius;
    int roundedArea = area.round();

    String correctAnswer = roundedArea.toString();
    List<String> options = [
      correctAnswer,
      (roundedArea + 5).toString(),
      (roundedArea - 3).toString(),
      (radius * 2).toString(),
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

  GeometryQuestion _generateAlgebraicSquareQuestion() {
    // Generate x value (solution)
    int x = random.nextInt(6) + 2; // 2-7

    // Create two expressions that should be equal for a square
    int a = random.nextInt(3) + 1; // coefficient for first side
    int b = random.nextInt(5) + 1; // constant for first side

    // Second side = first side when x is the solution
    // First side: ax + b
    // Second side: c*x + d where c*x + d = a*x + b when solved
    int firstSide = a * x + b;

    // Create second expression
    int c = random.nextInt(3) + 1;
    int d = firstSide - (c * x);

    String correctAnswer = x.toString();
    List<String> options = [
      correctAnswer,
      (x + 1).toString(),
      (x - 1).toString(),
      (x + 2).toString(),
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

  GeometryQuestion _generateAlgebraicRectangleQuestion() {
    // For rectangle: opposite sides are equal
    int x = random.nextInt(5) + 3; // 3-7

    int a = random.nextInt(3) + 2; // coefficient
    int b = random.nextInt(6) + 1; // constant

    // Length: ax + b
    int length = a * x + b;

    // Width: cx + d (should equal length's opposite side)
    int c = random.nextInt(2) + 1;
    int d = length - (c * x);

    String correctAnswer = x.toString();
    List<String> options = [
      correctAnswer,
      (x + 1).toString(),
      (x - 1).toString(),
      (x * 2).toString(),
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

  GeometryQuestion _generateAlgebraicTriangleQuestion() {
    // For isosceles triangle: two sides are equal
    int x = random.nextInt(6) + 2; // 2-7

    int a = random.nextInt(3) + 1;
    int b = random.nextInt(7) + 2;

    // Side 1: ax + b
    int side1 = a * x + b;

    // Side 2: cx + d (equal to side 1 for isosceles)
    int c = random.nextInt(2) + 2;
    int d = side1 - (c * x);

    String correctAnswer = x.toString();
    List<String> options = [
      correctAnswer,
      (x + 1).toString(),
      (x - 1).toString(),
      (x + 2).toString(),
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

  void _selectAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      showResult = true;
      final isCorrect = answer == questions[currentQuestionIndex].correctAnswer;
      if (isCorrect) {
        correctAnswers++;
      }
      // For now, mark Geometry difficulty as 'medium' by default.
      // You can later wire a UI selector similar to Algebra.
      StatsService.instance.incrementAttempt(
        'Geometry',
        'medium',
        correct: isCorrect,
      );
    });
  }

  void _nextQuestion() {
    setState(() {
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
        selectedAnswer = null;
        showResult = false;
      } else {
        _showResults();
      }
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
                    onTap: showResult ? null : () => _selectAnswer(option),
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

              // Next Button
              if (showResult)
                Container(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      currentQuestionIndex < questions.length - 1
                          ? 'Next Question'
                          : 'Finish Quiz',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
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
