import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // User data placeholders
  final String userName = 'User';
  final String userProfileImageUrl = 'https://via.placeholder.com/150';
  final int userLevel = 1;
  final int userXP = 0;
  final int xpForNextLevel = 1000;
  final int dailyStreak = 0;

  // Challenge data placeholders
  final List<Map<String, dynamic>> challenges = [
    {
      'title': 'Challenge',
      'xp': '100 XP',
      'color': Colors.purple.shade500,
      'imageUrl': 'https://via.placeholder.com/150',
    },
    {
      'title': 'Challenge',
      'xp': '150 XP',
      'color': Colors.green.shade500,
      'imageUrl': 'https://via.placeholder.com/150',
    },
    {
      'title': 'Challenge',
      'xp': '75 XP',
      'color': Colors.blue.shade500,
      'imageUrl': 'https://via.placeholder.com/150',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeader(),

            // Level and XP Progress Section
            _buildLevelSection(),

            // Stats Cards Section
            _buildStatsCards(),

            // Daily Challenges Section
            _buildChallengesSection(),

            // Mathix Tutor Section
            _buildMathixTutorSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F8),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          // Profile Picture
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBlAgqL2satqmq2MQW-7id9QQ6jFqXx3uIjCMmrNEKQYhuH8VGgllpAn-HI5QAsSKn9cbzmrrgUDciLWL_Ne3Wmn4HK3NXyF6EVaZWDwgz7I2N482v-l5h-XRAu-O3aCofaX6sf7cnBPiwiljF4JtzxrwI5zplszCMmC4TknaW9uPmRGclKbr099rwCClbmSeMU0ktBjSaSXIzTZ7KBMpe5qWeIcwcoKWQ15GoZamR0fHOjcK7Mrp4wEVnmZfuE_rnYl-21bQ55-xvN',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Welcome Message
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, John!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111418),
                  ),
                ),
              ],
            ),
          ),

          // Notification Button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_outlined,
                color: Color(0xFF111418),
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Level and XP Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Level 12',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111418),
                ),
              ),
              Text(
                '12,345 XP',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Progress Bar
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: 0.6, // 60% progress
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Daily Streak Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Streak',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '🔥 5-day streak',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111418),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Total XP Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total XP',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '12,345 XP',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111418),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Challenges',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111418),
            ),
          ),

          const SizedBox(height: 16),

          // Challenge Cards
          _buildChallengeCard(
            title: 'Algebra',
            xp: '100 XP',
            color: Colors.purple.shade500,
            imageUrl:
                'https://lh3.googleusercontent.com/aida-public/AB6AXuC80lDOau_GPObboSnEdUb_fkZWNxkMNBKrSQlicfRys0AkJmy9aZEj1h-xzLoyLwWyOHj0jP8iArXLFv8XLu4_s7cYJi3iAOmX4wneSdd5-iIlAP1C5rS4Jimf6G6POIzbpf4iPLZRQDdVyWBc-fOtIk_hp7tlpwFELE6fjQA6Pn9-z1QkahtC2WkYBInYzvStw8jznja8_bxAX278xiFfMqVWUMNEDsLsy1jkZCLN-CjKwkim5ALMjIz3NvHJNlNVpupG-ApXCoL1',
          ),

          const SizedBox(height: 16),

          _buildChallengeCard(
            title: 'Geometry',
            xp: '150 XP',
            color: Colors.green.shade500,
            imageUrl:
                'https://lh3.googleusercontent.com/aida-public/AB6AXuAwvySK9mFncXnlqvwQvyZWbFZHAN_iJ2HTsm0JJKdIRjojDrVOq7bgptW68yxLJKt0FgY_79JDkKAdGeUOOi4NpLx3-rt6f2mtpiFFClJNKT0OGNluKdDnKapNb4NcPPci3y3DwHTrIFiy41vPEwCgRAZJButnEnBU-mMCGIHw_KLFM0mv5RKm3Vq8i5ofll-M-p2Bk575NKODb4DPSz5PP7lDAfCzxcUv54rNnMoQBlG2AeqKzvOsHVixyLzJYYicCksC-QkI9yZx',
          ),

          const SizedBox(height: 16),

          _buildChallengeCard(
            title: 'Graphs',
            xp: '75 XP',
            color: Colors.blue.shade500,
            imageUrl:
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCy2RsVAjX3L-PaeQw0mEomxnYmiWplfUkCeqmXEcJd9jvsdDmzXinGjKai5X5IqQ4F1j1cBvvZIXGSG_bpqhyrPlzk9PtLpzhjRWSmD54GQ_doEHlOwIwL-ClWNJPWq91t7W2SnwWQd8LGy7_T_w-KM-iWjI69F8QktRKb8esXY1zWp4rjJsW7UIWpY_BPrHuEs8CgYCit5C0hedOSLNmzGLKPb-faZJNMGqUUBHAbf9Fy48VM57OG52YPntnEyKnaD4MfRG1D2MIm',
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard({
    required String title,
    required String xp,
    required Color color,
    required String imageUrl,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Challenge Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111418),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    xp,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: color.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      'Start',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Challenge Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMathixTutorSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mathix Tutor',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111418),
            ),
          ),

          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // AI Tutor Profile Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Profile Picture
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          image: DecorationImage(
                            image: NetworkImage(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuDeBCCFajOnySabMAvgIx5oGyEtZihecAGFkFCB6qGRKwlY3rffK20Hbiob9mhln3SvheEG_jLk-AHYkdZUayQdUjsAnOQBvcSRX8G36EJipNWTguh3jBjhgt3HU8vnSauMwN-sBCs2QQcOi2mc-ESRJibYh91NPtMzhUe9r6DhXE3r_xBmRzdjvjRhRkKnKXljVZzrhFFUBvaRBeFiLI0GuyfRgIOxNJBiXo8WaLE0ujfTC0IUqTHycoE9DpifB6hSMW5Z1tFTsb-W',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Tutor Info
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mathix AI',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111418),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Your personal AI tutor',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF60758A),
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
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Robot Icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.purple.shade500,
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
                        const Text(
                          'Need help with a problem?\nChat with your AI Tutor now!',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF111418),
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 16),

                        // Start Chat Button
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Navigate to chat screen
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple.shade500,
                              foregroundColor: Colors.white,
                              elevation: 3,
                              shadowColor: Colors.purple.shade200,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 10,
                              ),
                            ),
                            child: const Text(
                              'Start Chat',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
