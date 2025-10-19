import 'package:flutter/material.dart';
import 'dart:math';

// This file contains the FloatingCalculator widget and CalculatorScreen
// Import this file in your main app to use the calculator

// Calculator Screen - Navigate to this from your main app
class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.3),
      body: Stack(
        children: [
          // Tap anywhere to close
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(color: Colors.transparent),
          ),
          const FloatingCalculator(),
        ],
      ),
    );
  }
}

class FloatingCalculator extends StatefulWidget {
  const FloatingCalculator({Key? key}) : super(key: key);

  @override
  State<FloatingCalculator> createState() => _FloatingCalculatorState();
}

class _FloatingCalculatorState extends State<FloatingCalculator> {
  Offset _position = const Offset(20, 100);
  String _display = '0';
  String _expression = '';
  double? _firstOperand;
  String? _operator;
  bool _shouldResetDisplay = false;
  List<String> _history = [];
  bool _showHistory = false;

  void _onNumberPressed(String number) {
    setState(() {
      if (_shouldResetDisplay || _display == '0') {
        _display = number;
        _shouldResetDisplay = false;
      } else {
        _display += number;
      }
      _expression = _buildExpression();
    });
  }

  void _onOperatorPressed(String op) {
    setState(() {
      if (_operator != null && !_shouldResetDisplay) {
        _calculate();
      }
      _firstOperand = double.tryParse(_display);
      _operator = op;
      _shouldResetDisplay = true;
      _expression = _buildExpression();
    });
  }

  void _calculate() {
    if (_firstOperand == null || _operator == null) return;

    double secondOperand = double.tryParse(_display) ?? 0;
    double result = 0;

    switch (_operator) {
      case '+':
        result = _firstOperand! + secondOperand;
        break;
      case '-':
        result = _firstOperand! - secondOperand;
        break;
      case '×':
        result = _firstOperand! * secondOperand;
        break;
      case '÷':
        result = secondOperand != 0 ? _firstOperand! / secondOperand : 0;
        break;
    }

    // Add to history
    String historyEntry =
        '${_formatNumber(_firstOperand!)} $_operator ${_formatNumber(secondOperand)} = ${_formatNumber(result)}';

    setState(() {
      _display = result.toString();
      if (_display.endsWith('.0')) {
        _display = _display.substring(0, _display.length - 2);
      }
      _history.insert(0, historyEntry);
      if (_history.length > 50) {
        _history = _history.sublist(0, 50);
      }
      _firstOperand = null;
      _operator = null;
      _shouldResetDisplay = true;
      _expression = '';
    });
  }

  String _formatNumber(double num) {
    String str = num.toString();
    if (str.endsWith('.0')) {
      return str.substring(0, str.length - 2);
    }
    return str;
  }

  void _onEqualsPressed() {
    _calculate();
  }

  void _onClearPressed() {
    setState(() {
      _display = '0';
      _expression = '';
      _firstOperand = null;
      _operator = null;
      _shouldResetDisplay = false;
    });
  }

  void _onAllClearPressed() {
    _onClearPressed();
  }

  void _onDecimalPressed() {
    setState(() {
      if (_shouldResetDisplay) {
        _display = '0.';
        _shouldResetDisplay = false;
      } else if (!_display.contains('.')) {
        _display += '.';
      }
      _expression = _buildExpression();
    });
  }

  void _onSquareRootPressed() {
    setState(() {
      double value = double.tryParse(_display) ?? 0;
      _display = sqrt(value).toString();
      if (_display.endsWith('.0')) {
        _display = _display.substring(0, _display.length - 2);
      }
      _shouldResetDisplay = true;
      _expression = '';
    });
  }

  void _onExponentPressed() {
    _onOperatorPressed('^');
  }

  void _onBackspacePressed() {
    setState(() {
      if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
      } else {
        _display = '0';
      }
      _expression = _buildExpression();
    });
  }

  void _onFractionPressed() {
    setState(() {
      // Check if current display is a fraction
      if (_display.contains('/')) {
        // Convert fraction to decimal
        List<String> parts = _display.split('/');
        if (parts.length == 2) {
          double numerator = double.tryParse(parts[0]) ?? 0;
          double denominator = double.tryParse(parts[1]) ?? 1;
          if (denominator != 0) {
            double result = numerator / denominator;
            _display = result.toString();
            if (_display.endsWith('.0')) {
              _display = _display.substring(0, _display.length - 2);
            }
          }
        }
        _shouldResetDisplay = true;
        _expression = '';
        return;
      }

      // Convert decimal to fraction
      double value = double.tryParse(_display) ?? 0;
      if (value == 0) {
        _display = '0/1';
        _shouldResetDisplay = true;
        return;
      }

      // Handle whole numbers
      bool isNegative = value < 0;
      value = value.abs();

      if (value == value.truncateToDouble()) {
        _display = '${isNegative ? '-' : ''}${value.toInt()}/1';
        _shouldResetDisplay = true;
        return;
      }

      // Find fraction using continued fractions method
      double tolerance = 1.0e-6;
      int maxDenominator = 10000;

      int numerator = 0;
      int denominator = 1;

      int h1 = 1, h2 = 0;
      int k1 = 0, k2 = 1;

      double b = value;
      do {
        int a = b.floor();
        int aux = h1;
        h1 = a * h1 + h2;
        h2 = aux;
        aux = k1;
        k1 = a * k1 + k2;
        k2 = aux;
        b = 1 / (b - a);
      } while ((value - h1 / k1).abs() > value * tolerance &&
          k1 < maxDenominator);

      numerator = h1;
      denominator = k1;

      if (isNegative) numerator = -numerator;

      _display = '$numerator/$denominator';
      _shouldResetDisplay = true;
      _expression = '';
    });
  }

  String _buildExpression() {
    if (_firstOperand != null && _operator != null) {
      String first = _firstOperand.toString();
      if (first.endsWith('.0')) {
        first = first.substring(0, first.length - 2);
      }
      return '$first $_operator ${_shouldResetDisplay ? '' : _display}';
    }
    return _display;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _position += details.delta;
          });
        },
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 340,
            height: 580,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(Icons.arrow_back, color: Colors.grey[800]),
                      ),
                      Text(
                        'Calculator',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showHistory = !_showHistory;
                          });
                        },
                        child: Icon(Icons.history, color: Colors.grey[800]),
                      ),
                    ],
                  ),
                ),
                // Display or History
                Expanded(
                  child:
                      _showHistory
                          ? Container(
                            padding: const EdgeInsets.all(20),
                            child:
                                _history.isEmpty
                                    ? Center(
                                      child: Text(
                                        'No calculation history',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    )
                                    : ListView.builder(
                                      itemCount: _history.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            // Extract result from history and use it
                                            String historyItem =
                                                _history[index];
                                            String result =
                                                historyItem
                                                    .split('=')
                                                    .last
                                                    .trim();
                                            setState(() {
                                              _display = result;
                                              _showHistory = false;
                                              _shouldResetDisplay = true;
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                              horizontal: 16,
                                            ),
                                            margin: const EdgeInsets.only(
                                              bottom: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              _history[index],
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                          )
                          : Container(
                            padding: const EdgeInsets.all(20),
                            alignment: Alignment.bottomRight,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _expression,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _display,
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[900],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                ),
                // Buttons
                if (!_showHistory)
                  Container(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildButton(
                              'C',
                              onPressed: _onClearPressed,
                              isGray: true,
                            ),
                            _buildButton('(', isGray: true),
                            _buildButton(')', isGray: true),
                            _buildButton(
                              '^',
                              onPressed: _onExponentPressed,
                              isGray: true,
                            ),
                            _buildButton(
                              '÷',
                              onPressed: () => _onOperatorPressed('÷'),
                              isBlue: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildButton(
                              'AC',
                              onPressed: _onAllClearPressed,
                              isGray: true,
                            ),
                            _buildButton(
                              '7',
                              onPressed: () => _onNumberPressed('7'),
                            ),
                            _buildButton(
                              '8',
                              onPressed: () => _onNumberPressed('8'),
                            ),
                            _buildButton(
                              '9',
                              onPressed: () => _onNumberPressed('9'),
                            ),
                            _buildButton(
                              '×',
                              onPressed: () => _onOperatorPressed('×'),
                              isBlue: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildButton(
                              '√',
                              onPressed: _onSquareRootPressed,
                              isGray: true,
                            ),
                            _buildButton(
                              '4',
                              onPressed: () => _onNumberPressed('4'),
                            ),
                            _buildButton(
                              '5',
                              onPressed: () => _onNumberPressed('5'),
                            ),
                            _buildButton(
                              '6',
                              onPressed: () => _onNumberPressed('6'),
                            ),
                            _buildButton(
                              '-',
                              onPressed: () => _onOperatorPressed('-'),
                              isBlue: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildButton(
                              '⌫',
                              onPressed: _onBackspacePressed,
                              isGray: true,
                            ),
                            _buildButton(
                              '1',
                              onPressed: () => _onNumberPressed('1'),
                            ),
                            _buildButton(
                              '2',
                              onPressed: () => _onNumberPressed('2'),
                            ),
                            _buildButton(
                              '3',
                              onPressed: () => _onNumberPressed('3'),
                            ),
                            _buildButton(
                              '+',
                              onPressed: () => _onOperatorPressed('+'),
                              isBlue: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildButton(
                              'a/b',
                              onPressed: _onFractionPressed,
                              isGray: true,
                              fontSize: 16,
                            ),
                            _buildButton(
                              '0',
                              onPressed: () => _onNumberPressed('0'),
                            ),
                            _buildButton('.', onPressed: _onDecimalPressed),
                            _buildButton(
                              '=',
                              onPressed: _onEqualsPressed,
                              isBlue: true,
                              isWide: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    String text, {
    VoidCallback? onPressed,
    bool isGray = false,
    bool isBlue = false,
    bool isWide = false,
    double fontSize = 20,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: isWide ? 120 : 52,
        height: 52,
        decoration: BoxDecoration(
          color:
              isBlue
                  ? Colors.blue[400]
                  : isGray
                  ? Colors.grey[300]
                  : Colors.white,
          borderRadius: BorderRadius.circular(26),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            color: isBlue ? Colors.white : Colors.grey[800],
          ),
        ),
      ),
    );
  }
}
