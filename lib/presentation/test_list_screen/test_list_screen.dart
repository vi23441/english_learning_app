import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/app_export.dart';
import '../../providers/test_provider.dart';
import '../../models/test.dart';
import '../../routes/app_routes.dart';
import '../../services/test_data_seeder.dart';

class TestListScreen extends StatefulWidget {
  const TestListScreen({Key? key}) : super(key: key);

  @override
  State<TestListScreen> createState() => _TestListScreenState();
}

class _TestListScreenState extends State<TestListScreen> {
  late TestProvider testProvider;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      testProvider = Provider.of<TestProvider>(context, listen: false);
      testProvider.loadTests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Available Tests',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Consumer<TestProvider>(
        builder: (context, testProvider, child) {
          if (testProvider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading tests...'),
                ],
              ),
            );
          }

          if (testProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load tests',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    testProvider.error!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => testProvider.loadTests(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (testProvider.filteredTests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No tests available',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Check back later for new tests',
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      final seeder = TestDataSeeder();
                      await seeder.seedTestData();
                      testProvider.loadTests();
                    },
                    child: Text('Create Sample Tests'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: testProvider.filteredTests.length,
            itemBuilder: (context, index) {
              final test = testProvider.filteredTests[index];
              return _buildTestCard(test);
            },
          );
        },
      ),
    );
  }

  Widget _buildTestCard(Test test) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _startTest(test),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Test header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      test.title,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(test.difficulty).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      test.difficulty.displayName,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getDifficultyColor(test.difficulty),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 8),
              
              // Test description
              Text(
                test.description,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              SizedBox(height: 12),
              
              // Test info
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.category,
                    label: test.category.displayName,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 8),
                  _buildInfoChip(
                    icon: Icons.quiz,
                    label: '${test.questions.length} questions',
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  SizedBox(width: 8),
                  _buildInfoChip(
                    icon: Icons.timer,
                    label: '${test.duration} min',
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              // Start test button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _startTest(test),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: Text(
                    'Start Test',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(TestDifficulty difficulty) {
    switch (difficulty) {
      case TestDifficulty.beginner:
        return Colors.green;
      case TestDifficulty.intermediate:
        return Colors.orange;
      case TestDifficulty.advanced:
        return Colors.red;
    }
  }

  void _startTest(Test test) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Start Test',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are about to start "${test.title}"',
              style: GoogleFonts.inter(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              'Test Details:',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text('• ${test.questions.length} questions'),
            Text('• ${test.duration} minutes duration'),
            Text('• ${test.difficulty.displayName} difficulty'),
            SizedBox(height: 12),
            Text(
              'Once you start, you cannot pause or restart the test.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                AppRoutes.testTakingScreen,
                arguments: test.id,
              );
            },
            child: Text('Start Test'),
          ),
        ],
      ),
    );
  }
}
