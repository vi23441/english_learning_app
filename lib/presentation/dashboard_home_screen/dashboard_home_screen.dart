import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date formatting

import '../../providers/auth_provider.dart';
import '../../providers/video_provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../providers/test_provider.dart';
import '../../routes/app_routes.dart';

class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({super.key});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final videoProvider = Provider.of<VideoProvider>(context, listen: false);
    final vocabularyProvider = Provider.of<VocabularyProvider>(context, listen: false);
    final testProvider = Provider.of<TestProvider>(context, listen: false);

    if (authProvider.user != null) {
      // Load user data
      await vocabularyProvider.loadTopics();
      await videoProvider.loadVideos();
      await testProvider.loadTests();
      await testProvider.loadUserTestHistory(authProvider.user!.uid);
    }
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.videoLibraryScreen);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.testListScreen);
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.vocabularySetsScreen);
        break;
      case 4:
        _showProfileOptions();
        break;
    }
  }

  void _showProfileOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 200,
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.profileScreen);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.settingsScreen);
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Test History'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.testHistoryScreen);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pop(context);
                  Provider.of<AuthProvider>(context, listen: false).logout();
                  Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EduLearn'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer4<AuthProvider, VideoProvider, VocabularyProvider, TestProvider>(
        builder: (context, authProvider, videoProvider, vocabularyProvider, testProvider, child) {
          if (authProvider.isLoading || videoProvider.isLoading || vocabularyProvider.isLoading || testProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, ${authProvider.user?.name ?? 'User'}!',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        const Text('Ready to continue your English learning journey?'),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Quick stats
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildStatColumn('Vocabulary', '${vocabularyProvider.vocabularies.length}', Icons.book),
                          const SizedBox(width: 24),
                          _buildStatColumn('Tests', '${testProvider.tests.length}', Icons.quiz),
                          const SizedBox(width: 24),
                          _buildStatColumn('Videos', '${videoProvider.videos.length}', Icons.video_library),
                          const SizedBox(width: 24),
                          _buildStatColumn('Streak', '5', Icons.local_fire_department),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Feature grid
                Text(
                  'Features',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    _buildFeatureCard('Vocabulary Sets', 'Practice with sets', Icons.layers, () {
                      Navigator.pushNamed(context, AppRoutes.vocabularySetsScreen);
                    }),
                    _buildFeatureCard('Flashcards', 'Practice words', Icons.style, () {
                      Navigator.pushNamed(context, AppRoutes.flashcardSetDetailScreen, arguments: 'default_flashcards_set_id');
                    }),
                    _buildFeatureCard('Tests', 'Take a test', Icons.quiz, () {
                      Navigator.pushNamed(context, AppRoutes.testListScreen);
                    }),
                    _buildFeatureCard('Videos', 'Watch lessons', Icons.video_library, () {
                      Navigator.pushNamed(context, AppRoutes.videoLibraryScreen);
                    }),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Recent activity
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                testProvider.testHistory.isEmpty
                    ? const Card(
                        child: ListTile(
                          title: Text('No recent test activity.'),
                          subtitle: Text('Take a test to see your history here!'),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: testProvider.testHistory.length > 3 ? 3 : testProvider.testHistory.length, // Show up to 3 recent activities
                        itemBuilder: (context, index) {
                          final history = testProvider.testHistory[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Icon(
                                history.score >= 70 ? Icons.check_circle : Icons.cancel,
                                color: history.score >= 70 ? Colors.green : Colors.red,
                              ),
                              title: Text('${history.testTitle} - ${history.score}%'),
                              subtitle: Text('Completed on ${DateFormat('MMM dd, yyyy HH:mm').format(history.completedAt.toDate())}'),
                              onTap: () {
                                // Optionally navigate to test results screen
                              },
                            ),
                          );
                        },
                      ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.video_library), label: 'Videos'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Tests'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Vocabulary'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.blue),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}