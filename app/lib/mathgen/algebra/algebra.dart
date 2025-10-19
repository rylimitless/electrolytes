import 'package:petitparser/petitparser.dart';
import 'dart:math';

// Abstract syntax tree for expressions
abstract class Expr {
  double eval(Map<String, double> vars);
  Expr simplify();
  String toDisplayString();
  bool containsVar(String varName);
  Expr substitute(String varName, double value);

  // New methods for detailed solving
  Expr moveTermToOtherSide(String varName);
  bool isConstant();
  double? getCoefficient(String varName);
}

class Num extends Expr {
  final double value;
  Num(this.value);

  @override
  double eval(Map<String, double> vars) => value;

  @override
  Expr simplify() => this;

  @override
  String toDisplayString() {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  @override
  bool containsVar(String varName) => false;

  @override
  Expr substitute(String varName, double value) => this;

  @override
  Expr moveTermToOtherSide(String varName) => this;

  @override
  bool isConstant() => true;

  @override
  double? getCoefficient(String varName) => null;
}

class Var extends Expr {
  final String name;
  Var(this.name);

  @override
  double eval(Map<String, double> vars) {
    if (!vars.containsKey(name)) {
      throw Exception('Variable $name not defined');
    }
    return vars[name]!;
  }

  @override
  Expr simplify() => this;

  @override
  String toDisplayString() => name;

  @override
  bool containsVar(String varName) => name == varName;

  @override
  Expr substitute(String varName, double value) {
    if (name == varName) {
      return Num(value);
    }
    return this;
  }

  @override
  Expr moveTermToOtherSide(String varName) => this;

  @override
  bool isConstant() => false;

  @override
  double? getCoefficient(String varName) => name == varName ? 1.0 : null;
}

class BinOp extends Expr {
  final Expr left;
  final String op;
  final Expr right;

  BinOp(this.left, this.op, this.right);

  @override
  double eval(Map<String, double> vars) {
    final l = left.eval(vars);
    final r = right.eval(vars);

    switch (op) {
      case '+':
        return l + r;
      case '-':
        return l - r;
      case '*':
        return l * r;
      case '/':
        return l / r;
      case '^':
        return pow(l, r).toDouble();
      default:
        throw Exception('Unknown operator: $op');
    }
  }

  @override
  Expr simplify() {
    final l = left.simplify();
    final r = right.simplify();

    if (l is Num && r is Num) {
      return Num(BinOp(l, op, r).eval({}));
    }

    // Simplification rules
    if (op == '+') {
      if (l is Num && l.value == 0) return r;
      if (r is Num && r.value == 0) return l;
    }
    if (op == '-') {
      if (r is Num && r.value == 0) return l;
      if (l is Num && l.value == 0) return UnaryOp('-', r).simplify();
    }
    if (op == '*') {
      if (l is Num && l.value == 1) return r;
      if (r is Num && r.value == 1) return l;
      if (l is Num && l.value == 0) return Num(0);
      if (r is Num && r.value == 0) return Num(0);
    }
    if (op == '/') {
      if (r is Num && r.value == 1) return l;
    }

    return BinOp(l, op, r);
  }

  @override
  String toDisplayString() {
    final leftStr =
        (left is BinOp && _needsParens(left as BinOp, true))
            ? '(${left.toDisplayString()})'
            : left.toDisplayString();
    final rightStr =
        (right is BinOp && _needsParens(right as BinOp, false))
            ? '(${right.toDisplayString()})'
            : right.toDisplayString();
    return '$leftStr $op $rightStr';
  }

  bool _needsParens(BinOp child, bool isLeft) {
    final parentPrecedence = _precedence(op);
    final childPrecedence = _precedence(child.op);

    if (childPrecedence < parentPrecedence) return true;
    if (childPrecedence == parentPrecedence &&
        !isLeft &&
        (op == '-' || op == '/'))
      return true;
    return false;
  }

  int _precedence(String operator) {
    switch (operator) {
      case '+':
      case '-':
        return 1;
      case '*':
      case '/':
        return 2;
      case '^':
        return 3;
      default:
        return 0;
    }
  }

  @override
  bool containsVar(String varName) =>
      left.containsVar(varName) || right.containsVar(varName);

  @override
  Expr substitute(String varName, double value) {
    return BinOp(
      left.substitute(varName, value),
      op,
      right.substitute(varName, value),
    );
  }

  @override
  Expr moveTermToOtherSide(String varName) => this;

  @override
  bool isConstant() => left.isConstant() && right.isConstant();

  @override
  double? getCoefficient(String varName) {
    if (op == '*') {
      if (left is Num && right.containsVar(varName) && right is Var) {
        return (left as Num).value;
      }
      if (right is Num && left.containsVar(varName) && left is Var) {
        return (right as Num).value;
      }
    }
    return null;
  }
}

class UnaryOp extends Expr {
  final String op;
  final Expr operand;

  UnaryOp(this.op, this.operand);

  @override
  double eval(Map<String, double> vars) {
    final val = operand.eval(vars);
    switch (op) {
      case '-':
        return -val;
      default:
        throw Exception('Unknown operator: $op');
    }
  }

  @override
  Expr simplify() {
    final o = operand.simplify();
    if (o is Num) {
      return Num(UnaryOp(op, o).eval({}));
    }
    return UnaryOp(op, o);
  }

  @override
  String toDisplayString() => '$op${operand.toDisplayString()}';

  @override
  bool containsVar(String varName) => operand.containsVar(varName);

  @override
  Expr substitute(String varName, double value) {
    return UnaryOp(op, operand.substitute(varName, value));
  }

  @override
  Expr moveTermToOtherSide(String varName) => this;

  @override
  bool isConstant() => operand.isConstant();

  @override
  double? getCoefficient(String varName) => operand.getCoefficient(varName);
}

class SolverStep {
  final String description;
  final String leftSide;
  final String rightSide;
  final String? explanation;

  SolverStep(
    this.description,
    this.leftSide,
    this.rightSide, [
    this.explanation,
  ]);

  @override
  String toString() {
    var result = '$description\n  $leftSide = $rightSide';
    if (explanation != null && explanation!.isNotEmpty) {
      result += '\n  ($explanation)';
    }
    return result;
  }
}

// Algebra Question Model
class AlgebraQuestion {
  final String question;
  final String topic;
  final String difficulty;
  final String? answer;
  final String? hint;

  AlgebraQuestion({
    required this.question,
    required this.topic,
    required this.difficulty,
    this.answer,
    this.hint,
  });

  Map<String, dynamic> toJson() => {
    'question': question,
    'topic': topic,
    'difficulty': difficulty,
    'answer': answer,
    'hint': hint,
  };
}

// Question Generator with Topic Support
class QuestionGenerator {
  final Random _random = Random();

  // Supported topics
  static const List<String> supportedTopics = [
    'solve',
    'simplify',
    'evaluate',
    'expand',
    'factor',
  ];

  // Generate questions by topic
  List<AlgebraQuestion> generateByTopic(
    String topic,
    String difficulty,
    int count,
  ) {
    switch (topic.toLowerCase()) {
      case 'solve':
        return _generateSolveQuestions(difficulty, count);
      case 'simplify':
        return _generateSimplifyQuestions(difficulty, count);
      case 'evaluate':
        return _generateEvaluateQuestions(difficulty, count);
      case 'expand':
        return _generateExpandQuestions(difficulty, count);
      case 'factor':
        return _generateFactorQuestions(difficulty, count);
      default:
        throw Exception('Unknown topic: $topic');
    }
  }

  // Generate all types of questions (mixed)
  List<AlgebraQuestion> generateMixedQuestions(String difficulty, int count) {
    final questions = <AlgebraQuestion>[];
    final topics = List.from(supportedTopics)..shuffle(_random);

    for (int i = 0; i < count; i++) {
      final topic = topics[i % topics.length];
      questions.addAll(generateByTopic(topic, difficulty, 1));
    }

    return questions;
  }

  // Get all questions organized by topic
  Map<String, List<AlgebraQuestion>> generateQuestionsByAllTopics(
    String difficulty,
    int questionsPerTopic,
  ) {
    final result = <String, List<AlgebraQuestion>>{};
    for (final topic in supportedTopics) {
      result[topic] = generateByTopic(topic, difficulty, questionsPerTopic);
    }
    return result;
  }

  // SOLVE QUESTIONS
  List<AlgebraQuestion> _generateSolveQuestions(String difficulty, int count) {
    final questions = <AlgebraQuestion>[];
    for (int i = 0; i < count; i++) {
      final eq = _generateEquation(difficulty);
      questions.add(
        AlgebraQuestion(
          question: 'Solve for x: $eq',
          topic: 'solve',
          difficulty: difficulty,
          hint: _getSolveHint(difficulty),
        ),
      );
    }
    return questions;
  }

  String _generateEquation(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return _generateEasyEquation();
      case 'medium':
        return _generateMediumEquation();
      case 'hard':
        return _generateHardEquation();
      default:
        return _generateMediumEquation();
    }
  }

  String _generateEasyEquation() {
    final type = _random.nextInt(3);
    switch (type) {
      case 0: // x + a = b
        final a = _random.nextInt(20) - 10;
        final b = _random.nextInt(20) + 1;
        return 'x + $a = $b';
      case 1: // ax = b
        final a = _random.nextInt(9) + 2;
        final b = a * (_random.nextInt(10) + 1);
        return '$a*x = $b';
      default: // x - a = b
        final a = _random.nextInt(15) + 1;
        final b = _random.nextInt(15) + 1;
        return 'x - $a = $b';
    }
  }

  String _generateMediumEquation() {
    final type = _random.nextInt(4);
    switch (type) {
      case 0: // ax + b = c
        final a = _random.nextInt(8) + 2;
        final b = _random.nextInt(20) - 10;
        final x_value = _random.nextInt(10) + 1;
        final c = a * x_value + b;
        return '$a*x + $b = $c';
      case 1: // ax - b = cx + d
        final a = _random.nextInt(5) + 3;
        final b = _random.nextInt(15) + 5;
        final c = _random.nextInt(4) + 1;
        final d = _random.nextInt(10) + 1;
        return '$a*x - $b = $c*x + $d';
      case 2: // x/a + b = c
        final a = _random.nextInt(4) + 2;
        final x_value = a * (_random.nextInt(10) + 1);
        final b = _random.nextInt(15) + 1;
        final c = (x_value / a).round() + b;
        return 'x/$a + $b = $c';
      default: // a(x + b) = c (will expand to ax + ab = c)
        final a = _random.nextInt(5) + 2;
        final b = _random.nextInt(8) + 1;
        final x_value = _random.nextInt(10) + 1;
        final c = a * (x_value + b);
        return '$a*x + ${a * b} = $c';
    }
  }

  String _generateHardEquation() {
    final type = _random.nextInt(3);
    switch (type) {
      case 0: // Complex linear: a(x + b) = c(x - d)
        final a = _random.nextInt(4) + 2;
        final b = _random.nextInt(8) + 1;
        final c = _random.nextInt(3) + 1;
        final d = _random.nextInt(8) + 1;
        return '${a}*x + ${a * b} = ${c}*x - ${c * d}';
      case 1: // Fractions: x/a + x/b = c
        final a = _random.nextInt(3) + 2;
        final b = _random.nextInt(3) + 2;
        if (a == b) return _generateHardEquation();
        final x_value = _random.nextInt(10) + 2;
        final c = (x_value / a + x_value / b).round();
        return 'x/$a + x/$b = $c';
      default: // Quadratic: x^2 = a
        final a = [4, 9, 16, 25, 36, 49, 64, 81, 100][_random.nextInt(9)];
        return 'x^2 = $a';
    }
  }

  String _getSolveHint(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 'Isolate the variable by performing inverse operations';
      case 'medium':
        return 'Move all variable terms to one side and constants to the other';
      case 'hard':
        return 'Simplify both sides first, then solve step by step';
      default:
        return 'Work through the problem systematically';
    }
  }

  // SIMPLIFY QUESTIONS
  List<AlgebraQuestion> _generateSimplifyQuestions(
    String difficulty,
    int count,
  ) {
    final questions = <AlgebraQuestion>[];
    for (int i = 0; i < count; i++) {
      final expr = _generateSimplifiableExpression(difficulty);
      questions.add(
        AlgebraQuestion(
          question: 'Simplify: $expr',
          topic: 'simplify',
          difficulty: difficulty,
          hint: 'Combine like terms and apply algebraic rules',
        ),
      );
    }
    return questions;
  }

  String _generateSimplifiableExpression(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        final type = _random.nextInt(3);
        switch (type) {
          case 0: // ax + bx
            final a = _random.nextInt(9) + 1;
            final b = _random.nextInt(9) + 1;
            return '$a*x + $b*x';
          case 1: // ax - ax
            final a = _random.nextInt(9) + 2;
            final b = _random.nextInt(a);
            return '$a*x - $b*x';
          default: // a + b + x
            final a = _random.nextInt(10) + 1;
            final b = _random.nextInt(10) + 1;
            return '$a + $b + x';
        }
      case 'medium':
        final type = _random.nextInt(3);
        switch (type) {
          case 0: // ax + b + cx - d
            final a = _random.nextInt(5) + 2;
            final b = _random.nextInt(10) + 1;
            final c = _random.nextInt(5) + 1;
            final d = _random.nextInt(10) + 1;
            return '$a*x + $b + $c*x - $d';
          case 1: // (a + b)*x
            final a = _random.nextInt(8) + 1;
            final b = _random.nextInt(8) + 1;
            return '($a + $b)*x';
          default: // a*x*b
            final a = _random.nextInt(7) + 2;
            final b = _random.nextInt(7) + 2;
            return '$a*x*$b';
        }
      case 'hard':
        final type = _random.nextInt(2);
        switch (type) {
          case 0: // Complex: (ax + b) + (cx - d) + ex
            final a = _random.nextInt(5) + 1;
            final b = _random.nextInt(10) + 1;
            final c = _random.nextInt(5) + 1;
            final d = _random.nextInt(10) + 1;
            final e = _random.nextInt(5) + 1;
            return '($a*x + $b) + ($c*x - $d) + $e*x';
          default: // With division: (ax + bx)/c
            final a = _random.nextInt(4) + 1;
            final b = _random.nextInt(4) + 1;
            final c = _random.nextInt(4) + 2;
            return '($a*x + $b*x)/$c';
        }
      default:
        return '2*x + 3*x';
    }
  }

  // EVALUATE QUESTIONS
  List<AlgebraQuestion> _generateEvaluateQuestions(
    String difficulty,
    int count,
  ) {
    final questions = <AlgebraQuestion>[];
    for (int i = 0; i < count; i++) {
      final data = _generateEvaluationExpression(difficulty);
      questions.add(
        AlgebraQuestion(
          question: 'Evaluate ${data['expr']} when ${data['vars']}',
          topic: 'evaluate',
          difficulty: difficulty,
          hint: 'Substitute the given values and calculate',
        ),
      );
    }
    return questions;
  }

  Map<String, String> _generateEvaluationExpression(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        final a = _random.nextInt(10) + 1;
        final xVal = _random.nextInt(10) + 1;
        return {'expr': '$a*x', 'vars': 'x = $xVal'};
      case 'medium':
        final a = _random.nextInt(8) + 2;
        final b = _random.nextInt(15) + 1;
        final xVal = _random.nextInt(10) + 1;
        return {'expr': '$a*x + $b', 'vars': 'x = $xVal'};
      case 'hard':
        final a = _random.nextInt(5) + 1;
        final b = _random.nextInt(8) + 1;
        final xVal = _random.nextInt(8) + 1;
        final yVal = _random.nextInt(8) + 1;
        return {'expr': '$a*x + $b*y', 'vars': 'x = $xVal, y = $yVal'};
      default:
        return {'expr': '2*x + 3', 'vars': 'x = 5'};
    }
  }

  // EXPAND QUESTIONS
  List<AlgebraQuestion> _generateExpandQuestions(String difficulty, int count) {
    final questions = <AlgebraQuestion>[];
    for (int i = 0; i < count; i++) {
      final expr = _generateExpandableExpression(difficulty);
      questions.add(
        AlgebraQuestion(
          question: 'Expand: $expr',
          topic: 'expand',
          difficulty: difficulty,
          hint: 'Apply the distributive property',
        ),
      );
    }
    return questions;
  }

  String _generateExpandableExpression(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        final a = _random.nextInt(9) + 2;
        final b = _random.nextInt(10) + 1;
        return '$a*(x + $b)';
      case 'medium':
        final a = _random.nextInt(7) + 2;
        final b = _random.nextInt(10) + 1;
        final c = _random.nextInt(10) + 1;
        return '$a*(x + $b) + $c';
      case 'hard':
        final a = _random.nextInt(8) + 1;
        final b = _random.nextInt(8) + 1;
        final c = _random.nextInt(8) + 1;
        final d = _random.nextInt(8) + 1;
        return '($a*x + $b)*($c*x + $d)';
      default:
        return '2*(x + 3)';
    }
  }

  // FACTOR QUESTIONS
  List<AlgebraQuestion> _generateFactorQuestions(String difficulty, int count) {
    final questions = <AlgebraQuestion>[];
    for (int i = 0; i < count; i++) {
      final expr = _generateFactorableExpression(difficulty);
      questions.add(
        AlgebraQuestion(
          question: 'Factor: $expr',
          topic: 'factor',
          difficulty: difficulty,
          hint: 'Find common factors or use factoring patterns',
        ),
      );
    }
    return questions;
  }

  String _generateFactorableExpression(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        final a = _random.nextInt(7) + 2;
        final b = _random.nextInt(9) + 1;
        final c = _random.nextInt(9) + 1;
        final gcf = a;
        return '${gcf * b}*x + ${gcf * c}';
      case 'medium':
        final a = _random.nextInt(6) + 2;
        final b = _random.nextInt(8) + 1;
        return '${a * b}*x + ${a * b}';
      case 'hard':
        // Difference of squares or simple trinomial
        final a = _random.nextInt(8) + 1;
        final b = _random.nextInt(8) + 1;
        return 'x^2 + ${a + b}*x + ${a * b}';
      default:
        return '6*x + 9';
    }
  }

  // Legacy methods for backward compatibility
  String generateQuestion(String difficulty) {
    return _generateEquation(difficulty);
  }

  List<String> generateMultiple(String difficulty, int count) {
    final questions = <String>[];
    for (int i = 0; i < count; i++) {
      questions.add(generateQuestion(difficulty));
    }
    return questions;
  }
}

class Equation {
  final Expr left;
  final Expr right;

  Equation(this.left, this.right);

  List<SolverStep> solveWithSteps(String varName) {
    final steps = <SolverStep>[];

    // Initial equation
    steps.add(
      SolverStep(
        'Step 1: Write the original equation',
        left.toDisplayString(),
        right.toDisplayString(),
      ),
    );

    // Simplify both sides
    var leftSide = left.simplify();
    var rightSide = right.simplify();

    if (leftSide.toDisplayString() != left.toDisplayString() ||
        rightSide.toDisplayString() != right.toDisplayString()) {
      steps.add(
        SolverStep(
          'Step 2: Simplify both sides',
          leftSide.toDisplayString(),
          rightSide.toDisplayString(),
          'Combine like terms and evaluate constants',
        ),
      );
    }

    // Try algebraic solving for linear equations
    final result = _solveLinearDetailed(leftSide, rightSide, varName, steps);

    if (result != null) {
      return steps;
    }

    // Fall back to numerical method
    steps.add(
      SolverStep(
        'Using numerical method (Newton\'s method)',
        leftSide.toDisplayString(),
        rightSide.toDisplayString(),
        'Equation is non-linear, using iterative approximation',
      ),
    );

    final solution = _solveNumerical(leftSide, rightSide, varName, steps);

    steps.add(
      SolverStep('Final Solution', varName, Num(solution).toDisplayString()),
    );

    return steps;
  }

  Expr? _solveLinearDetailed(
    Expr left,
    Expr right,
    String varName,
    List<SolverStep> steps,
  ) {
    int stepNum = steps.length + 1;

    // Try to extract linear form
    final leftTerms = _extractTerms(left, varName);
    final rightTerms = _extractTerms(right, varName);

    if (leftTerms == null || rightTerms == null) return null;

    var leftVarCoeff = leftTerms['varCoeff']!;
    var leftConst = leftTerms['const']!;
    var rightVarCoeff = rightTerms['varCoeff']!;
    var rightConst = rightTerms['const']!;

    // Step: Show the equation in expanded form
    steps.add(
      SolverStep(
        'Step $stepNum: Identify terms with $varName and constant terms',
        _buildTermString(leftVarCoeff, leftConst, varName),
        _buildTermString(rightVarCoeff, rightConst, varName),
        'Left side: ${leftVarCoeff != 0 ? '${_formatCoeff(leftVarCoeff)}$varName' : '0'} ${leftConst >= 0 ? '+' : ''} ${leftConst != 0 ? leftConst : ''} | Right side: ${rightVarCoeff != 0 ? '${_formatCoeff(rightVarCoeff)}$varName' : '0'} ${rightConst >= 0 ? '+' : ''} ${rightConst != 0 ? rightConst : ''}',
      ),
    );
    stepNum++;

    // Move variable terms to left
    if (rightVarCoeff != 0) {
      steps.add(
        SolverStep(
          'Step $stepNum: Subtract ${_formatCoeff(rightVarCoeff)}$varName from both sides',
          _buildTermString(leftVarCoeff, leftConst, varName) +
              ' - ${_formatCoeff(rightVarCoeff)}$varName',
          _buildTermString(rightVarCoeff, rightConst, varName) +
              ' - ${_formatCoeff(rightVarCoeff)}$varName',
          'Move all $varName terms to the left side',
        ),
      );
      stepNum++;

      leftVarCoeff -= rightVarCoeff;
      rightVarCoeff = 0;

      steps.add(
        SolverStep(
          'Step $stepNum: Simplify',
          _buildTermString(leftVarCoeff, leftConst, varName),
          _buildTermString(rightVarCoeff, rightConst, varName),
        ),
      );
      stepNum++;
    }

    // Move constant terms to right
    if (leftConst != 0) {
      steps.add(
        SolverStep(
          'Step $stepNum: Subtract ${leftConst} from both sides',
          _buildTermString(leftVarCoeff, leftConst, varName) +
              ' - ${leftConst}',
          _buildTermString(rightVarCoeff, rightConst, varName) +
              ' - ${leftConst}',
          'Move all constant terms to the right side',
        ),
      );
      stepNum++;

      rightConst -= leftConst;
      leftConst = 0;

      steps.add(
        SolverStep(
          'Step $stepNum: Simplify',
          _buildTermString(leftVarCoeff, leftConst, varName),
          _buildTermString(rightVarCoeff, rightConst, varName),
        ),
      );
      stepNum++;
    }

    if (leftVarCoeff.abs() < 1e-10) {
      throw Exception('Variable $varName does not appear in equation');
    }

    // Divide by coefficient
    if (leftVarCoeff != 1) {
      steps.add(
        SolverStep(
          'Step $stepNum: Divide both sides by ${_formatCoeff(leftVarCoeff)}',
          '${_formatCoeff(leftVarCoeff)}$varName ÷ ${_formatCoeff(leftVarCoeff)}',
          '${rightConst} ÷ ${_formatCoeff(leftVarCoeff)}',
          'Isolate $varName by dividing by its coefficient',
        ),
      );
      stepNum++;
    }

    final solution = rightConst / leftVarCoeff;

    steps.add(
      SolverStep(
        'Step $stepNum: Final Solution',
        varName,
        Num(solution).toDisplayString(),
        '✓ Solution found!',
      ),
    );

    return Num(solution);
  }

  Map<String, double>? _extractTerms(Expr expr, String varName) {
    try {
      final withVar = expr.substitute(varName, 1).eval({});
      final withoutVar = expr.substitute(varName, 0).eval({});
      final varCoeff = withVar - withoutVar;
      final constTerm = withoutVar;

      // Verify it's linear
      final testVal = 5.0;
      final testResult = expr.substitute(varName, testVal).eval({});
      final expected = varCoeff * testVal + constTerm;

      if ((testResult - expected).abs() < 1e-10) {
        return {'varCoeff': varCoeff, 'const': constTerm};
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String _buildTermString(double varCoeff, double constTerm, String varName) {
    final parts = <String>[];

    if (varCoeff != 0) {
      if (varCoeff == 1) {
        parts.add(varName);
      } else if (varCoeff == -1) {
        parts.add('-$varName');
      } else {
        parts.add('${_formatCoeff(varCoeff)}$varName');
      }
    }

    if (constTerm != 0) {
      if (parts.isEmpty) {
        parts.add(Num(constTerm).toDisplayString());
      } else {
        parts.add(
          '${constTerm >= 0 ? '+' : ''} ${Num(constTerm).toDisplayString()}',
        );
      }
    }

    if (parts.isEmpty) return '0';
    return parts.join(' ');
  }

  String _formatCoeff(double coeff) {
    if (coeff == coeff.toInt()) {
      return coeff.toInt().toString();
    }
    return coeff.toStringAsFixed(2);
  }

  double _solveNumerical(
    Expr left,
    Expr right,
    String varName,
    List<SolverStep> steps,
  ) {
    double x = 0;
    const epsilon = 1e-10;
    const h = 1e-7;
    const maxIterations = 100;

    for (int i = 0; i < maxIterations; i++) {
      final vars = {varName: x};
      final fx = left.eval(vars) - right.eval(vars);

      if (i < 10) {
        steps.add(
          SolverStep(
            'Iteration ${i + 1}: Test $varName = ${Num(x).toDisplayString()}',
            'Left side = ${Num(left.eval(vars)).toDisplayString()}',
            'Right side = ${Num(right.eval(vars)).toDisplayString()}',
            'Difference = ${Num(fx).toDisplayString()}',
          ),
        );
      } else if (i % 10 == 0) {
        steps.add(
          SolverStep(
            'Iteration ${i + 1}: $varName = ${Num(x).toDisplayString()}',
            '',
            '',
            'Still converging... difference = ${Num(fx).toDisplayString()}',
          ),
        );
      }

      if (fx.abs() < epsilon) {
        if (i >= 1) {
          steps.add(
            SolverStep(
              'Converged!',
              '',
              '',
              'Solution found after ${i + 1} iterations with error < $epsilon',
            ),
          );
        }
        return x;
      }

      // Numerical derivative
      final vars2 = {varName: x + h};
      final fxh = left.eval(vars2) - right.eval(vars2);
      final derivative = (fxh - fx) / h;

      if (derivative.abs() < epsilon) {
        throw Exception('Derivative too small, cannot continue');
      }

      final oldX = x;
      x = x - fx / derivative;

      if (i < 10) {
        steps.add(
          SolverStep(
            '  → Newton step',
            '',
            '',
            'New estimate: ${Num(x).toDisplayString()} (moved ${Num((x - oldX).abs()).toDisplayString()} units)',
          ),
        );
      }
    }

    throw Exception('Did not converge after $maxIterations iterations');
  }

  @override
  String toString() => '${left.toDisplayString()} = ${right.toDisplayString()}';
}

// Helper function to create an equation parser
Parser<Equation> createEquationParser() {
  final builder = ExpressionBuilder<Expr>();

  // Numbers
  builder.primitive(
    digit()
        .plus()
        .seq(char('.').seq(digit().plus()).optional())
        .flatten()
        .trim()
        .map((s) => Num(double.parse(s))),
  );

  // Variables (letters)
  builder.primitive(letter().plus().flatten().trim().map((s) => Var(s)));

  // Parentheses
  builder.group().wrapper(
    char('(').trim(),
    char(')').trim(),
    (left, value, right) => value,
  );

  // Negation (prefix)
  builder.group().prefix(
    char('-').trim(),
    (operator, value) => UnaryOp('-', value),
  );

  // Power (right-associative)
  builder.group().right(
    char('^').trim(),
    (left, operator, right) => BinOp(left, '^', right),
  );

  // Multiplication and division (left-associative)
  builder.group()
    ..left(char('*').trim(), (left, operator, right) => BinOp(left, '*', right))
    ..left(
      char('/').trim(),
      (left, operator, right) => BinOp(left, '/', right),
    );

  // Addition and subtraction (left-associative)
  builder.group()
    ..left(char('+').trim(), (left, operator, right) => BinOp(left, '+', right))
    ..left(
      char('-').trim(),
      (left, operator, right) => BinOp(left, '-', right),
    );

  final exprParser = builder.build();

  // Equation parser: expr = expr
  return exprParser
      .trim()
      .seq(char('=').trim())
      .seq(exprParser.trim())
      .map((values) => Equation(values[0], values[2]))
      .end();
}

// Helper function to create an expression parser (for simplify, evaluate, etc.)
Parser<Expr> createExpressionParser() {
  final builder = ExpressionBuilder<Expr>();

  // Numbers
  builder.primitive(
    digit()
        .plus()
        .seq(char('.').seq(digit().plus()).optional())
        .flatten()
        .trim()
        .map((s) => Num(double.parse(s))),
  );

  // Variables (letters)
  builder.primitive(letter().plus().flatten().trim().map((s) => Var(s)));

  // Parentheses
  builder.group().wrapper(
    char('(').trim(),
    char(')').trim(),
    (left, value, right) => value,
  );

  // Negation (prefix)
  builder.group().prefix(
    char('-').trim(),
    (operator, value) => UnaryOp('-', value),
  );

  // Power (right-associative)
  builder.group().right(
    char('^').trim(),
    (left, operator, right) => BinOp(left, '^', right),
  );

  // Multiplication and division (left-associative)
  builder.group()
    ..left(char('*').trim(), (left, operator, right) => BinOp(left, '*', right))
    ..left(
      char('/').trim(),
      (left, operator, right) => BinOp(left, '/', right),
    );

  // Addition and subtraction (left-associative)
  builder.group()
    ..left(char('+').trim(), (left, operator, right) => BinOp(left, '+', right))
    ..left(
      char('-').trim(),
      (left, operator, right) => BinOp(left, '-', right),
    );

  return builder.build().end();
}
