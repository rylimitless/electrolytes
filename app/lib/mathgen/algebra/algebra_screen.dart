import 'package:flutter/material.dart';
import 'algebra.dart';

class AlgebraScreen extends StatefulWidget {
  const AlgebraScreen({Key? key}) : super(key: key);

  @override
  State<AlgebraScreen> createState() => _AlgebraScreenState();
}

class _AlgebraScreenState extends State<AlgebraScreen> {
  final QuestionGenerator _generator = QuestionGenerator();
  final TextEditingController _answerController = TextEditingController();
  // Perf: avoid rebuilding whole page on every keystroke
  final ValueNotifier<String> _answerText = ValueNotifier('');
  final ValueNotifier<bool> _checking = ValueNotifier(false);

  String _selectedTopic = 'solve';
  String _selectedDifficulty = 'easy';
  List<AlgebraQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  bool _showAnswer = false;
  String? _userAnswer;
  bool? _isCorrect;
  List<SolverStep>? _solutionSteps;

  @override
  void initState() {
    super.initState();
    _generateQuestions();
    _answerController.addListener(() {
      _answerText.value = _answerController.text;
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    _answerText.dispose();
    _checking.dispose();
    super.dispose();
  }

  void _generateQuestions() {
    setState(() {
      _questions = _generator.generateByTopic(
        _selectedTopic,
        _selectedDifficulty,
        10,
      );
      _currentQuestionIndex = 0;
      _showAnswer = false;
      _isCorrect = null;
      _solutionSteps = null;
      _answerController.clear();
    });
  }

  void _checkAnswer() {
    if (_answerController.text.isEmpty) return;

    final currentQuestion = _questions[_currentQuestionIndex];
    _userAnswer = _answerController.text;

    try {
      _checking.value = true;

      switch (_selectedTopic) {
        case 'solve':
          _checkSolveQuestion(currentQuestion);
          break;
        case 'simplify':
          _checkSimplifyQuestion(currentQuestion);
          break;
        case 'evaluate':
          _checkEvaluateQuestion(currentQuestion);
          break;
        case 'expand':
          _checkExpandQuestion(currentQuestion);
          break;
        case 'factor':
          _checkFactorQuestion(currentQuestion);
          break;
        default:
          setState(() {
            _showAnswer = true;
            _isCorrect = null;
          });
      }
    } catch (e) {
      setState(() {
        _showAnswer = true;
        _isCorrect = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error checking answer: $e')));
    } finally {
      _checking.value = false;
    }
  }

  void _checkSolveQuestion(AlgebraQuestion question) {
    final questionText = question.question.replaceAll('Solve for x: ', '');
    final parser = createEquationParser();
    final equation = parser.parse(questionText).value;
    final steps = equation.solveWithSteps('x');

    // Extract the solution from the last step
    final lastStep = steps.last;
    final solution = lastStep.rightSide;

    // Compare user's answer with the solution
    final userValue = double.tryParse(_userAnswer!);
    final solutionValue = double.tryParse(solution);

    setState(() {
      _showAnswer = true;
      _solutionSteps = steps;
      if (userValue != null && solutionValue != null) {
        _isCorrect = (userValue - solutionValue).abs() < 0.01;
      } else {
        _isCorrect = false;
      }
    });
  }

  void _checkSimplifyQuestion(AlgebraQuestion question) {
    final exprText = question.question.replaceAll('Simplify: ', '');
    final parser = createExpressionParser();
    final expr = parser.parse(exprText).value;
    final simplified = expr.simplify();
    final solution = simplified.toDisplayString();

    // Create step-by-step explanation
    final steps = <SolverStep>[
      SolverStep(
        'Step 1: Original expression',
        exprText,
        '',
        'We need to simplify this expression',
      ),
      SolverStep(
        'Step 2: Simplified result',
        solution,
        '',
        'Combine like terms and apply algebraic rules',
      ),
    ];

    // Normalize both answers for comparison (remove spaces, convert to lowercase)
    final normalizedUser = _userAnswer!.replaceAll(' ', '').toLowerCase();
    final normalizedSolution = solution.replaceAll(' ', '').toLowerCase();

    setState(() {
      _showAnswer = true;
      _solutionSteps = steps;
      _isCorrect = normalizedUser == normalizedSolution;
    });
  }

  void _checkEvaluateQuestion(AlgebraQuestion question) {
    // Extract expression and variable values
    final parts = question.question.split(' when ');
    final exprText = parts[0].replaceAll('Evaluate ', '');
    final varsText = parts[1];

    // Parse variable assignments
    final vars = <String, double>{};
    final varPairs = varsText.split(', ');
    for (final pair in varPairs) {
      final kv = pair.split(' = ');
      if (kv.length == 2) {
        vars[kv[0].trim()] = double.parse(kv[1].trim());
      }
    }

    final parser = createExpressionParser();
    final expr = parser.parse(exprText).value;
    final result = expr.eval(vars);
    final solution = result.toString();

    // Create step-by-step explanation
    final steps = <SolverStep>[
      SolverStep(
        'Step 1: Original expression',
        exprText,
        '',
        'With values: $varsText',
      ),
      SolverStep(
        'Step 2: Substitute values',
        exprText,
        '',
        'Replace variables with their values',
      ),
      SolverStep(
        'Step 3: Calculate result',
        solution,
        '',
        'Perform the arithmetic operations',
      ),
    ];

    // Compare numerical values
    final userValue = double.tryParse(_userAnswer!);
    final solutionValue = double.tryParse(solution);

    setState(() {
      _showAnswer = true;
      _solutionSteps = steps;
      if (userValue != null && solutionValue != null) {
        _isCorrect = (userValue - solutionValue).abs() < 0.01;
      } else {
        _isCorrect = false;
      }
    });
  }

  void _checkExpandQuestion(AlgebraQuestion question) {
    final exprText = question.question.replaceAll('Expand: ', '');

    // For expand, we need to manually compute the expanded form
    // This is a simplified version - in production you'd want a proper expansion algorithm
    final steps = <SolverStep>[
      SolverStep(
        'Step 1: Original expression',
        exprText,
        '',
        'Apply the distributive property',
      ),
      SolverStep(
        'Step 2: Expanded form',
        'See hint for guidance',
        '',
        'Multiply each term inside the parentheses by the term outside',
      ),
    ];

    setState(() {
      _showAnswer = true;
      _solutionSteps = steps;
      _isCorrect =
          null; // Can't auto-verify expand without more complex parsing
    });
  }

  void _checkFactorQuestion(AlgebraQuestion question) {
    final exprText = question.question.replaceAll('Factor: ', '');

    // For factor, similar to expand - needs specialized algorithm
    final steps = <SolverStep>[
      SolverStep(
        'Step 1: Original expression',
        exprText,
        '',
        'Find common factors or use factoring patterns',
      ),
      SolverStep(
        'Step 2: Factored form',
        'See hint for guidance',
        '',
        'Look for greatest common factor (GCF) or special patterns',
      ),
    ];

    setState(() {
      _showAnswer = true;
      _solutionSteps = steps;
      _isCorrect =
          null; // Can't auto-verify factor without more complex parsing
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _showAnswer = false;
        _isCorrect = null;
        _solutionSteps = null;
        _answerController.clear();
      });
    } else {
      // Generate new set of questions
      _generateQuestions();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _showAnswer = false;
        _isCorrect = null;
        _solutionSteps = null;
        _answerController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Topic and Difficulty Selectors
                    Row(
                      children: [
                        Expanded(child: _buildTopicSelector()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDifficultySelector()),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Progress indicator
                    _buildProgressIndicator(),
                    const SizedBox(height: 24),

                    // Question Card
                    _buildQuestionCard(currentQuestion),
                    const SizedBox(height: 24),

                    // Answer Input
                    _buildAnswerInput(),
                    const SizedBox(height: 16),

                    // Check Answer Button
                    if (!_showAnswer) _buildCheckButton(),

                    // Answer Feedback
                    if (_showAnswer) _buildAnswerFeedback(),

                    // Solution Steps (for solve questions)
                    if (_showAnswer && _solutionSteps != null) ...[
                      const SizedBox(height: 24),
                      _buildSolutionSteps(),
                    ],

                    // Navigation Buttons
                    const SizedBox(height: 24),
                    _buildNavigationButtons(),
                  ],
                ),
              ),
            ),
          ],
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
          items: QuestionGenerator.supportedTopics.map((topic) {
            return DropdownMenuItem(
              value: topic,
              child: Text(topic.toUpperCase()),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedTopic = value;
              });
              _generateQuestions();
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
              });
              _generateQuestions();
            }
          },
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${(((_currentQuestionIndex + 1) / _questions.length) * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[700],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (_currentQuestionIndex + 1) / _questions.length,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[400]!),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(AlgebraQuestion question) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[400]!, Colors.blue[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    question.topic.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.emoji_events, color: Colors.yellow[300], size: 20),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              question.question,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            if (question.hint != null && !_showAnswer) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.yellow[200],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Hint: ${question.hint}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerInput() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isCorrect == null
              ? Colors.grey[300]!
              : _isCorrect!
              ? Colors.green[400]!
              : Colors.red[400]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ValueListenableBuilder<String>(
        valueListenable: _answerText,
        builder: (context, value, _) {
          return TextField(
            controller: _answerController,
            enabled: !_showAnswer,
            decoration: InputDecoration(
              hintText: 'Enter your answer...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              prefixIcon: Icon(Icons.edit_outlined, color: Colors.blue[400]),
              suffixIcon: value.isNotEmpty && !_showAnswer
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey[400]),
                      onPressed: () {
                        _answerController.clear();
                        // listener will update _answerText
                      },
                    )
                  : null,
            ),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            onSubmitted: (value) {
              if (!_showAnswer) _checkAnswer();
            },
          );
        },
      ),
    );
  }

  Widget _buildCheckButton() {
    return ValueListenableBuilder<String>(
      valueListenable: _answerText,
      builder: (context, text, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: _checking,
          builder: (context, checking, __) {
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: text.isEmpty || checking
                    ? null
                    : () => _checkAnswer(),
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
                    if (checking) ...[
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
            );
          },
        );
      },
    );
  }

  Widget _buildAnswerFeedback() {
    if (_isCorrect == null && !_showAnswer) {
      return const SizedBox();
    }

    if (_isCorrect == null) {
      // For expand and factor where we can't auto-verify
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your answer has been submitted.',
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Your answer: $_userAnswer',
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Check the solution steps below to verify your answer.',
              style: TextStyle(
                color: Colors.blue[800],
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isCorrect! ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isCorrect! ? Colors.green[300]! : Colors.red[300]!,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isCorrect! ? Icons.check_circle : Icons.cancel,
                color: _isCorrect! ? Colors.green[700] : Colors.red[700],
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _isCorrect! ? 'Correct! Well done!' : 'Incorrect. Try again!',
                  style: TextStyle(
                    color: _isCorrect! ? Colors.green[900] : Colors.red[900],
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (_userAnswer != null) ...[
            const SizedBox(height: 8),
            Text(
              'Your answer: $_userAnswer',
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSolutionSteps() {
    if (_solutionSteps == null || _solutionSteps!.isEmpty) {
      return const SizedBox();
    }

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.purple[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.purple[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.school_outlined,
                  color: Colors.purple[700],
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Solution Steps',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[900],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              primary: false,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _solutionSteps!.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final step = _solutionSteps![index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple[100]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.description,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple[800],
                        ),
                      ),
                      if (step.leftSide.isNotEmpty &&
                          step.rightSide.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${step.leftSide} = ${step.rightSide}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[900],
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                      if (step.explanation != null &&
                          step.explanation!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          step.explanation!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _currentQuestionIndex > 0 ? _previousQuestion : null,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(
                color: _currentQuestionIndex > 0
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
                  color: _currentQuestionIndex > 0
                      ? Colors.blue[700]
                      : Colors.grey[400],
                ),
                const SizedBox(width: 8),
                Text(
                  'Previous',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _currentQuestionIndex > 0
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
                  _currentQuestionIndex < _questions.length - 1
                      ? 'Next'
                      : 'New Set',
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
    );
  }
}
