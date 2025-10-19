import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // User data placeholders
  final String userName = 'User';

  late TabController _tabController;

  // Mock data structure for questions stats
  final Map<String, Map<String, Map<String, int>>> _statsData = {
    'Algebra': {
      'Easy': {'attempted': 45, 'correct': 42},
      'Medium': {'attempted': 30, 'correct': 24},
      'Hard': {'attempted': 15, 'correct': 9},
    },
    'Geometry': {
      'Easy': {'attempted': 38, 'correct': 35},
      'Medium': {'attempted': 22, 'correct': 18},
      'Hard': {'attempted': 10, 'correct': 5},
    },
    'Graphs': {
      'Easy': {'attempted': 50, 'correct': 48},
      'Medium': {'attempted': 35, 'correct': 30},
      'Hard': {'attempted': 20, 'correct': 14},
    },
  };

  // Category colors
  final Map<String, Color> _categoryColors = {
    'Algebra': const Color(0xFF7C3AED),
    'Geometry': const Color(0xFF10B981),
    'Graphs': const Color(0xFF3B82F6),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  double _calculateAccuracy(int attempted, int correct) {
    if (attempted == 0) return 0.0;
    return (correct / attempted) * 100;
  }

  String _getCurrentCategory() {
    switch (_tabController.index) {
      case 0:
        return 'Algebra';
      case 1:
        return 'Geometry';
      case 2:
        return 'Graphs';
      default:
        return 'Algebra';
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF101922) : const Color(0xFFF5F7F8),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_getGreeting()}, $userName! 👋',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Lexend',
                          color:
                              isDark ? Colors.white : const Color(0xFF111418),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ready to master some math today?',
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Lexend',
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Your Progress',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Lexend',
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Tab Bar with underline indicator and content
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A2633) : Colors.white,
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
                    children: [
                      TabBar(
                        controller: _tabController,
                        indicator: UnderlineTabIndicator(
                          borderSide: BorderSide(
                            width: 3.0,
                            color: _categoryColors[_getCurrentCategory()]!,
                          ),
                          insets: const EdgeInsets.symmetric(horizontal: 16.0),
                        ),
                        labelColor:
                            isDark ? Colors.white : const Color(0xFF111418),
                        unselectedLabelColor:
                            isDark ? Colors.grey[400] : Colors.grey[600],
                        labelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Lexend',
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Lexend',
                        ),
                        onTap: (index) {
                          setState(() {});
                        },
                        tabs: const [
                          Tab(text: 'Algebra'),
                          Tab(text: 'Geometry'),
                          Tab(text: 'Graphs'),
                        ],
                      ),
                      // Content inside the tab container
                      SizedBox(
                        height: 450,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildCategoryContent(theme, 'Algebra'),
                            _buildCategoryContent(theme, 'Geometry'),
                            _buildCategoryContent(theme, 'Graphs'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Mathix Tutor Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildMathixTutorSection(theme),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryContent(ThemeData theme, String category) {
    final isDark = theme.brightness == Brightness.dark;
    final categoryData = _statsData[category]!;
    final categoryColor = _categoryColors[category]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Practice Questions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Lexend',
              color: isDark ? Colors.white : const Color(0xFF111418),
            ),
          ),
          const SizedBox(height: 16),
          _buildDifficultyCard(
            theme,
            'Easy',
            categoryData['Easy']!,
            isDark ? Colors.green[400]! : Colors.green[600]!,
            categoryColor,
          ),
          const SizedBox(height: 12),
          _buildDifficultyCard(
            theme,
            'Medium',
            categoryData['Medium']!,
            isDark ? Colors.orange[400]! : Colors.orange[600]!,
            categoryColor,
          ),
          const SizedBox(height: 12),
          _buildDifficultyCard(
            theme,
            'Hard',
            categoryData['Hard']!,
            isDark ? Colors.red[400]! : Colors.red[600]!,
            categoryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyCard(
    ThemeData theme,
    String difficulty,
    Map<String, int> stats,
    Color accentColor,
    Color progressColor,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    final attempted = stats['attempted']!;
    final correct = stats['correct']!;
    final accuracy = _calculateAccuracy(attempted, correct);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1620) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with difficulty level
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              difficulty,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Lexend',
                color: accentColor,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  theme,
                  'Attempted',
                  attempted.toString(),
                  Icons.quiz_outlined,
                  isDark ? Colors.blue[300]! : Colors.blue[600]!,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatItem(
                  theme,
                  'Correct',
                  correct.toString(),
                  Icons.check_circle_outline,
                  isDark ? Colors.green[300]! : Colors.green[600]!,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress Bar with right-aligned percentage
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Lexend',
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${accuracy.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lexend',
                      color: progressColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: accuracy / 100,
                  minHeight: 6,
                  backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800]?.withOpacity(0.3) : Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Lexend',
              color: isDark ? Colors.white : const Color(0xFF111418),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'Lexend',
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMathixTutorSection(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2633) : Colors.white,
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
            'Mathix Tutor',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Lexend',
              color: isDark ? Colors.white : const Color(0xFF111418),
            ),
          ),
          const SizedBox(height: 16),

          // AI Tutor Profile Section
          Row(
            children: [
              // Profile Picture
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF7C3AED), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDeBCCFajOnySabMAvgIx5oGyEtZihecAGFkFCB6qGRKwlY3rffK20Hbiob9mhln3SvheEG_jLk-AHYkdZUayQdUjsAnOQBvcSRX8G36EJipNWTguh3jBjhgt3HU8vnSauMwN-sBCs2QQcOi2mc-ESRJibYh91NPtMzhUe9r6DhXE3r_xBmRzdjvjRhRkKnKXljVZzrhFFUBvaRBeFiLI0GuyfRgIOxNJBiXo8WaLE0ujfTC0IUqTHycoE9DpifB6hSMW5Z1tFTsb-W',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Tutor Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mathix AI',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Lexend',
                        color: isDark ? Colors.white : const Color(0xFF111418),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Your personal AI tutor',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Lexend',
                        color:
                            isDark ? Colors.grey[400] : const Color(0xFF60758A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Chat Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isDark
                      ? const Color(0xFF7C3AED).withOpacity(0.1)
                      : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Robot Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFF7C3AED),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.smart_toy,
                    color: Colors.white,
                    size: 24,
                  ),
                ),

                const SizedBox(height: 12),

                // Chat Message
                Text(
                  'Need help with a problem?\nChat with your AI Tutor now!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Lexend',
                    color: isDark ? Colors.grey[200] : const Color(0xFF111418),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Start Chat Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Navigate to chat screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: const Color(0xFF7C3AED).withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Start Chat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Lexend',
                      ),
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
