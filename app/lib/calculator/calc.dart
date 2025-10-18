// ...existing code...
import 'package:flutter/material.dart';
import 'dart:math' as math;

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _expr = '';
  String _displayExpr = '';
  String _result = '0';
  List<String> history = [];

  void _append(String s) {
    setState(() {
      _expr += s;
      _displayExpr = _expr;
    });
  }

  void _clear() {
    setState(() {
      _expr = '';
      _displayExpr = '';
      _result = '0';
    });
  }

  void _allClear() {
    setState(() {
      _expr = '';
      _displayExpr = '';
      _result = '0';
      history.clear();
    });
  }

  void _backspace() {
    if (_expr.isEmpty) return;
    setState(() {
      _expr = _expr.substring(0, _expr.length - 1);
      _displayExpr = _expr;
    });
  }

  void _evaluate() {
    try {
      final r = _CalcEvaluator().eval(_expr);
      final out = r.toDisplayString();
      setState(() {
        _result = out;
        history.insert(0, '$_expr = $out');
      });
    } catch (e) {
      setState(() {
        _result = 'Error';
      });
    }
  }

  Widget _button(String label,
      {Color? color, Color? textColor, void Function()? onTap, double radius = 40}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: radius * 2,
        width: radius * 2,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.grey[200],
            shape: const CircleBorder(),
            elevation: 0,
          ),
          onPressed: onTap ?? () => _append(label),
          child: Text(
            label,
            style: TextStyle(
              color: textColor ?? Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // build UI similar to screenshot
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Calculator', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => ListView(
                  padding: const EdgeInsets.all(16),
                  children: history.isEmpty
                      ? [const Text('No history')]
                      : history.map((e) => ListTile(title: Text(e))).toList(),
                ),
              );
            },
          )
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // display area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        reverse: true,
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          _displayExpr.isEmpty ? '' : _displayExpr,
                          style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _result,
                      style: const TextStyle(
                          fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),

            // keypad
            Container(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _button('C', color: Colors.grey[200], onTap: _clear),
                      _button('(', color: Colors.grey[200], onTap: () => _append('(')),
                      _button(')', color: Colors.grey[200], onTap: () => _append(')')),
                      _button('^', color: Colors.grey[200], onTap: () => _append('^')),
                      _button('÷',
                          color: Colors.blue[50],
                          textColor: Colors.blue,
                          onTap: () => _append('/')),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _button('AC', color: Colors.grey[300], onTap: _allClear),
                      _button('7', color: Colors.white, onTap: () => _append('7')),
                      _button('8', color: Colors.white, onTap: () => _append('8')),
                      _button('9', color: Colors.white, onTap: () => _append('9')),
                      _button('×',
                          color: Colors.blue[50],
                          textColor: Colors.blue,
                          onTap: () => _append('*')),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _button('√', color: Colors.grey[300], onTap: () => _append('sqrt(')),
                      _button('4', color: Colors.white, onTap: () => _append('4')),
                      _button('5', color: Colors.white, onTap: () => _append('5')),
                      _button('6', color: Colors.white, onTap: () => _append('6')),
                      _button('-', color: Colors.blue[50], textColor: Colors.blue, onTap: () => _append('-')),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _button('⌫', color: Colors.grey[300], onTap: _backspace),
                      _button('1', color: Colors.white, onTap: () => _append('1')),
                      _button('2', color: Colors.white, onTap: () => _append('2')),
                      _button('3', color: Colors.white, onTap: () => _append('3')),
                      _button('+', color: Colors.blue[50], textColor: Colors.blue, onTap: () => _append('+')),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _button('a/b', color: Colors.grey[300], onTap: () => _append('/')),
                            _button('0', color: Colors.white, onTap: () => _append('0')),
                            _button('.', color: Colors.white, onTap: () => _append('.')),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 64,
                        width: 140,
                        child: ElevatedButton(
                          onPressed: _evaluate,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32))),
                          child: const Text('=', style: TextStyle(fontSize: 28, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

/// Simple rational number class for exact fraction math
class Rational {
  BigInt n;
  BigInt d;
  Rational(this.n, this.d) {
    if (d == BigInt.zero) throw Exception('Division by zero');
    if (d.isNegative) {
      n = -n;
      d = -d;
    }
    _reduce();
  }

  static Rational fromInt(int v) => Rational(BigInt.from(v), BigInt.one);

  static Rational fromDecimalString(String s) {
    if (!s.contains('.')) {
      return Rational(BigInt.parse(s), BigInt.one);
    }
    final neg = s.startsWith('-');
    final clean = s.replaceFirst('-', '');
    final parts = clean.split('.');
    final intPart = parts[0];
    final fracPart = parts[1];
    final denom = BigInt.from(math.pow(10, fracPart.length) as int);
    final numer = BigInt.parse(intPart) * denom + BigInt.parse(fracPart);
    return Rational(neg ? -numer : numer, denom);
  }

  static Rational fromString(String s) {
    if (s.contains('/')) {
      final parts = s.split('/');
      final left = parts[0];
      final right = parts[1];
      final ln = left.contains('.') ? fromDecimalString(left) : Rational(BigInt.parse(left), BigInt.one);
      final rn = right.contains('.') ? fromDecimalString(right) : Rational(BigInt.parse(right), BigInt.one);
      return ln / rn;
    } else if (s.contains('.')) {
      return fromDecimalString(s);
    } else {
      return Rational(BigInt.parse(s), BigInt.one);
    }
  }

  void _reduce() {
    final g = n.gcd(d);
    if (g != BigInt.one) {
      n = n ~/ g;
      d = d ~/ g;
    }
  }

  Rational operator +(Rational other) => Rational(n * other.d + other.n * d, d * other.d);
  Rational operator -(Rational other) => Rational(n * other.d - other.n * d, d * other.d);
  Rational operator *(Rational other) => Rational(n * other.n, d * other.d);
  Rational operator /(Rational other) {
    if (other.n == BigInt.zero) throw Exception('Division by zero');
    return Rational(n * other.d, d * other.n);
  }

  Rational powInt(int e) {
    if (e >= 0) {
      return Rational(n.pow(e), d.pow(e));
    } else {
      final pos = Rational(n.pow(-e), d.pow(-e));
      return Rational(pos.d, pos.n);
    }
  }

  double toDouble() => n.toDouble() / d.toDouble();

  String toDisplayString() {
    if (d == BigInt.one) return n.toString();
    // if small denominator show exact fraction, else show decimal with 10 digits
    if (d.abs() <= BigInt.from(1000000)) {
      return '${n.toString()}/${d.toString()}';
    } else {
      return toDouble().toStringAsPrecision(10);
    }
  }
}

/// Simple evaluator using recursive descent producing Rational results.
class _CalcEvaluator {
  late List<String> _tokens;
  int _pos = 0;

  Rational eval(String expr) {
    // normalize
    final s = expr.replaceAll('×', '*').replaceAll('÷', '/').replaceAll(' ', '');
    _tokens = _tokenize(s);
    _pos = 0;
    final r = _parseExpression();
    if (_pos < _tokens.length) {
      throw Exception('Unexpected token: ${_tokens[_pos]}');
    }
    return r;
  }

  List<String> _tokenize(String s) {
    final tokens = <String>[];
    final buffer = StringBuffer();
    int i = 0;
    while (i < s.length) {
      final ch = s[i];
      if (_isDigit(ch) || ch == '.') {
        buffer.clear();
        while (i < s.length && (_isDigit(s[i]) || s[i] == '.')) {
          buffer.write(s[i]);
          i++;
        }
        tokens.add(buffer.toString());
      } else if (ch == 's' && i + 3 < s.length && s.substring(i, i + 4) == 'sqrt') {
        tokens.add('sqrt');
        i += 4;
      } else if ('+-*/^()'.contains(ch)) {
        tokens.add(ch);
        i++;
      } else {
        // unknown char, skip
        i++;
      }
    }
    return tokens;
  }

  bool _isDigit(String ch) => RegExp(r'\d').hasMatch(ch);

  String _peek() => _pos < _tokens.length ? _tokens[_pos] : '';
  String _next() => _pos < _tokens.length ? _tokens[_pos++] : '';

  Rational _parseExpression() {
    var left = _parseTerm();
    while (_peek() == '+' || _peek() == '-') {
      final op = _next();
      final right = _parseTerm();
      if (op == '+') left = left + right;
      else left = left - right;
    }
    return left;
  }

  Rational _parseTerm() {
    var left = _parseFactor();
    while (_peek() == '*' || _peek() == '/') {
      final op = _next();
      final right = _parseFactor();
      if (op == '*') left = left * right;
      else left = left / right;
    }
    return left;
  }

  Rational _parseFactor() {
    var left = _parseUnary();
    // right-associative power
    while (_peek() == '^') {
      _next();
      final right = _parseFactor();
      // try integer exponent
      final isInt = right.d == BigInt.one;
      if (isInt) {
        final exp = right.n.toInt();
        left = left.powInt(exp);
      } else {
        // fallback to double pow
        final val = math.pow(left.toDouble(), right.toDouble());
        left = Rational.fromDecimalString(val.toString());
      }
    }
    return left;
  }

  Rational _parseUnary() {
    if (_peek() == '+') {
      _next();
      return _parseUnary();
    } else if (_peek() == '-') {
      _next();
      return Rational.fromInt(0) - _parseUnary();
    } else if (_peek() == 'sqrt') {
      _next();
      final inside = _parseUnary();
      final val = math.sqrt(inside.toDouble());
      return Rational.fromDecimalString(val.toString());
    } else {
      return _parsePrimary();
    }
  }

  Rational _parsePrimary() {
    final t = _peek();
    if (t == '(') {
      _next();
      final v = _parseExpression();
      if (_peek() == ')') _next();
      return v;
   // filepath: /home/ry/Desktop/electrolytes/app/lib/calculator/calc.dart
// ...existing code...
import 'package:flutter/material.dart';
import 'dart:math' as math;

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _expr = '';
  String _displayExpr = '';
  String _result = '0';
  List<String> history = [];

  void _append(String s) {
    setState(() {
      _expr += s;
      _displayExpr = _expr;
    });
  }

  void _clear() {
    setState(() {
      _expr = '';
      _displayExpr = '';
      _result = '0';
    });
  }

  void _allClear() {
    setState(() {
      _expr = '';
      _displayExpr = '';
      _result = '0';
      history.clear();
    });
  }

  void _backspace() {
    if (_expr.isEmpty) return;
    setState(() {
      _expr = _expr.substring(0, _expr.length - 1);
      _displayExpr = _expr;
    });
  }

  void _evaluate() {
    try {
      final r = _CalcEvaluator().eval(_expr);
      final out = r.toDisplayString();
      setState(() {
        _result = out;
        history.insert(0, '$_expr = $out');
      });
    } catch (e) {
      setState(() {
        _result = 'Error';
      });
    }
  }

  Widget _button(String label,
      {Color? color, Color? textColor, void Function()? onTap, double radius = 40}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: radius * 2,
        width: radius * 2,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.grey[200],
            shape: const CircleBorder(),
            elevation: 0,
          ),
          onPressed: onTap ?? () => _append(label),
          child: Text(
            label,
            style: TextStyle(
              color: textColor ?? Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // build UI similar to screenshot
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Calculator', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => ListView(
                  padding: const EdgeInsets.all(16),
                  children: history.isEmpty
                      ? [const Text('No history')]
                      : history.map((e) => ListTile(title: Text(e))).toList(),
                ),
              );
            },
          )
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // display area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        reverse: true,
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          _displayExpr.isEmpty ? '' : _displayExpr,
                          style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _result,
                      style: const TextStyle(
                          fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),

            // keypad
            Container(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _button('C', color: Colors.grey[200], onTap: _clear),
                      _button('(', color: Colors.grey[200], onTap: () => _append('(')),
                      _button(')', color: Colors.grey[200], onTap: () => _append(')')),
                      _button('^', color: Colors.grey[200], onTap: () => _append('^')),
                      _button('÷',
                          color: Colors.blue[50],
                          textColor: Colors.blue,
                          onTap: () => _append('/')),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _button('AC', color: Colors.grey[300], onTap: _allClear),
                      _button('7', color: Colors.white, onTap: () => _append('7')),
                      _button('8', color: Colors.white, onTap: () => _append('8')),
                      _button('9', color: Colors.white, onTap: () => _append('9')),
                      _button('×',
                          color: Colors.blue[50],
                          textColor: Colors.blue,
                          onTap: () => _append('*')),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _button('√', color: Colors.grey[300], onTap: () => _append('sqrt(')),
                      _button('4', color: Colors.white, onTap: () => _append('4')),
                      _button('5', color: Colors.white, onTap: () => _append('5')),
                      _button('6', color: Colors.white, onTap: () => _append('6')),
                      _button('-', color: Colors.blue[50], textColor: Colors.blue, onTap: () => _append('-')),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _button('⌫', color: Colors.grey[300], onTap: _backspace),
                      _button('1', color: Colors.white, onTap: () => _append('1')),
                      _button('2', color: Colors.white, onTap: () => _append('2')),
                      _button('3', color: Colors.white, onTap: () => _append('3')),
                      _button('+', color: Colors.blue[50], textColor: Colors.blue, onTap: () => _append('+')),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _button('a/b', color: Colors.grey[300], onTap: () => _append('/')),
                            _button('0', color: Colors.white, onTap: () => _append('0')),
                            _button('.', color: Colors.white, onTap: () => _append('.')),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 64,
                        width: 140,
                        child: ElevatedButton(
                          onPressed: _evaluate,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32))),
                          child: const Text('=', style: TextStyle(fontSize: 28, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

/// Simple rational number class for exact fraction math
class Rational {
  BigInt n;
  BigInt d;
  Rational(this.n, this.d) {
    if (d == BigInt.zero) throw Exception('Division by zero');
    if (d.isNegative) {
      n = -n;
      d = -d;
    }
    _reduce();
  }

  static Rational fromInt(int v) => Rational(BigInt.from(v), BigInt.one);

  static Rational fromDecimalString(String s) {
    if (!s.contains('.')) {
      return Rational(BigInt.parse(s), BigInt.one);
    }
    final neg = s.startsWith('-');
    final clean = s.replaceFirst('-', '');
    final parts = clean.split('.');
    final intPart = parts[0];
    final fracPart = parts[1];
    final denom = BigInt.from(math.pow(10, fracPart.length) as int);
    final numer = BigInt.parse(intPart) * denom + BigInt.parse(fracPart);
    return Rational(neg ? -numer : numer, denom);
  }

  static Rational fromString(String s) {
    if (s.contains('/')) {
      final parts = s.split('/');
      final left = parts[0];
      final right = parts[1];
      final ln = left.contains('.') ? fromDecimalString(left) : Rational(BigInt.parse(left), BigInt.one);
      final rn = right.contains('.') ? fromDecimalString(right) : Rational(BigInt.parse(right), BigInt.one);
      return ln / rn;
    } else if (s.contains('.')) {
      return fromDecimalString(s);
    } else {
      return Rational(BigInt.parse(s), BigInt.one);
    }
  }

  void _reduce() {
    final g = n.gcd(d);
    if (g != BigInt.one) {
      n = n ~/ g;
      d = d ~/ g;
    }
  }

  Rational operator +(Rational other) => Rational(n * other.d + other.n * d, d * other.d);
  Rational operator -(Rational other) => Rational(n * other.d - other.n * d, d * other.d);
  Rational operator *(Rational other) => Rational(n * other.n, d * other.d);
  Rational operator /(Rational other) {
    if (other.n == BigInt.zero) throw Exception('Division by zero');
    return Rational(n * other.d, d * other.n);
  }

  Rational powInt(int e) {
    if (e >= 0) {
      return Rational(n.pow(e), d.pow(e));
    } else {
      final pos = Rational(n.pow(-e), d.pow(-e));
      return Rational(pos.d, pos.n);
    }
  }

  double toDouble() => n.toDouble() / d.toDouble();

  String toDisplayString() {
    if (d == BigInt.one) return n.toString();
    // if small denominator show exact fraction, else show decimal with 10 digits
    if (d.abs() <= BigInt.from(1000000)) {
      return '${n.toString()}/${d.toString()}';
    } else {
      return toDouble().toStringAsPrecision(10);
    }
  }
}

/// Simple evaluator using recursive descent producing Rational results.
class _CalcEvaluator {
  late List<String> _tokens;
  int _pos = 0;

  Rational eval(String expr) {
    // normalize
    final s = expr.replaceAll('×', '*').replaceAll('÷', '/').replaceAll(' ', '');
    _tokens = _tokenize(s);
    _pos = 0;
    final r = _parseExpression();
    if (_pos < _tokens.length) {
      throw Exception('Unexpected token: ${_tokens[_pos]}');
    }
    return r;
  }

  List<String> _tokenize(String s) {
    final tokens = <String>[];
    final buffer = StringBuffer();
    int i = 0;
    while (i < s.length) {
      final ch = s[i];
      if (_isDigit(ch) || ch == '.') {
        buffer.clear();
        while (i < s.length && (_isDigit(s[i]) || s[i] == '.')) {
          buffer.write(s[i]);
          i++;
        }
        tokens.add(buffer.toString());
      } else if (ch == 's' && i + 3 < s.length && s.substring(i, i + 4) == 'sqrt') {
        tokens.add('sqrt');
        i += 4;
      } else if ('+-*/^()'.contains(ch)) {
        tokens.add(ch);
        i++;
      } else {
        // unknown char, skip
        i++;
      }
    }
    return tokens;
  }

  bool _isDigit(String ch) => RegExp(r'\d').hasMatch(ch);

  String _peek() => _pos < _tokens.length ? _tokens[_pos] : '';
  String _next() => _pos < _tokens.length ? _tokens[_pos++] : '';

  Rational _parseExpression() {
    var left = _parseTerm();
    while (_peek() == '+' || _peek() == '-') {
      final op = _next();
      final right = _parseTerm();
      if (op == '+') left = left + right;
      else left = left - right;
    }
    return left;
  }

  Rational _parseTerm() {
    var left = _parseFactor();
    while (_peek() == '*' || _peek() == '/') {
      final op = _next();
      final right = _parseFactor();
      if (op == '*') left = left * right;
      else left = left / right;
    }
    return left;
  }

  Rational _parseFactor() {
    var left = _parseUnary();
    // right-associative power
    while (_peek() == '^') {
      _next();
      final right = _parseFactor();
      // try integer exponent
      final isInt = right.d == BigInt.one;
      if (isInt) {
        final exp = right.n.toInt();
        left = left.powInt(exp);
      } else {
        // fallback to double pow
        final val = math.pow(left.toDouble(), right.toDouble());
        left = Rational.fromDecimalString(val.toString());
      }
    }
    return left;
  }

  Rational _parseUnary() {
    if (_peek() == '+') {
      _next();
      return _parseUnary();
    } else if (_peek() == '-') {
      _next();
      return Rational.fromInt(0) - _parseUnary();
    } else if (_peek() == 'sqrt') {
      _next();
      final inside = _parseUnary();
      final val = math.sqrt(inside.toDouble());
      return Rational.fromDecimalString(val.toString());
    } else {
      return _parsePrimary();
    }
  }

  Rational _parsePrimary() {
    final t = _peek();
    if (t == '(') {
      _next();
      final v = _parseExpression();
      if (_peek() == ')') _next();
      return v;
   