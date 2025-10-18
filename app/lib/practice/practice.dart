import 'package:app/mathgen/algebra/algebra_screen.dart';
import 'package:app/mathgen/geometry/geometry.dart';
import 'package:flutter/material.dart';

class PracticePage extends StatelessWidget {
  const PracticePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32.0),
                margin: const EdgeInsets.only(bottom: 40.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[50]!, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.15),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Foundational Math',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Master problem solving\nessentials in math',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Colors.grey[600],
                                  height: 1.5,
                                  fontSize: 16,
                                ),
                          ),
                        ],
                      ),
                    ),
                    // Math icon representation
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[200]!, Colors.blue[400]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 15,
                            left: 15,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.blue[300],
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 15,
                            right: 15,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.blue[700],
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Topic Cards with connecting line
              Stack(
                children: [
                  // Connecting line
                  Positioned(
                    left: 55,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue[300]!,
                            Colors.purple[300]!,
                            Colors.green[300]!,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Topic Cards
                  Column(
                    children: [
                      _buildTopicCard(
                        title: 'Functions & Graphs',
                        icon: _buildPaintingIcon(),
                        onTap: () {
                          //TODO take you to the page to do questions on this
                        },
                        index: 0,
                      ),
                      const SizedBox(height: 32),
                      _buildTopicCard(
                        title: 'Algebra Basics',
                        icon: _buildAlgebraIcon(),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AlgebraScreen(),
                            ),
                          );
                        },
                        index: 1,
                      ),
                      const SizedBox(height: 32),
                      _buildTopicCard(
                        title: 'Geometry Fundamentals',
                        icon: _buildGeometryIcon(),
                        onTap: () {
                          //TODO , do geometry
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GeometryPage(),
                            ),
                          );
                        },
                        index: 2,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicCard({
    required String title,
    required Widget icon,
    bool isNew = false,
    required VoidCallback onTap,
    required int index,
  }) {
    final colors = [
      [Colors.blue[50]!, Colors.blue[100]!],
      [Colors.purple[50]!, Colors.purple[100]!],
      [Colors.green[50]!, Colors.green[100]!],
    ];

    return Stack(
      children: [
        // Connection dot
        Positioned(
          left: 45,
          top: 50,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: index == 0
                    ? Colors.blue[300]!
                    : index == 1
                    ? Colors.purple[300]!
                    : Colors.green[300]!,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        // Main card
        Container(
          margin: const EdgeInsets.only(left: 20),
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(28.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors[index % colors.length],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(width: 80, height: 80, child: icon),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Practice essential skills',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[700],
                      size: 16,
                    ),
                  ),
                  if (isNew)
                    Positioned(
                      top: -8,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaintingIcon() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Canvas
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              width: 35,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.blue[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // Easel legs
          Positioned(
            bottom: 5,
            left: 15,
            child: Container(width: 2, height: 15, color: Colors.orange[300]),
          ),
          Positioned(
            bottom: 5,
            left: 25,
            child: Container(width: 2, height: 15, color: Colors.orange[300]),
          ),
          Positioned(
            bottom: 5,
            left: 35,
            child: Container(width: 2, height: 15, color: Colors.orange[300]),
          ),
          // Paint palette
          Positioned(
            top: 15,
            right: 8,
            child: Container(
              width: 20,
              height: 15,
              decoration: BoxDecoration(
                color: Colors.orange[200],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProportionIcon() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Palette base
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              width: 40,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.blue[300],
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          // Color dots
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.yellow,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 26,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 26,
            left: 21,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Brush
          Positioned(
            top: 5,
            right: 8,
            child: Container(
              width: 3,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.brown[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNegativeNumbersIcon() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Minus block
          Positioned(
            top: 12,
            left: 8,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text(
                  '−',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          // Plus block
          Positioned(
            bottom: 12,
            right: 8,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.blue[300],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text(
                  '+',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          // Arrow
          Positioned(
            top: 20,
            left: 32,
            child: Icon(
              Icons.arrow_forward,
              color: Colors.orange[400],
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlgebraIcon() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.purple[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          'x²',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
      ),
    );
  }

  Widget _buildGeometryIcon() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Triangle
          Positioned(
            top: 15,
            left: 15,
            child: CustomPaint(
              size: const Size(30, 25),
              painter: TrianglePainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.shade600
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
