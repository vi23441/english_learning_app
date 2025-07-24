import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // Import for date formatting

import '../../core/app_export.dart';
import '../../providers/admin_provider.dart';
import '../../models/admin_stats.dart';

class AdminStatisticsScreen extends StatefulWidget {
  const AdminStatisticsScreen({super.key});

  @override
  State<AdminStatisticsScreen> createState() => _AdminStatisticsScreenState();
}

class _AdminStatisticsScreenState extends State<AdminStatisticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Statistics',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.primaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryLight),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryLight,
              ),
            );
          }

          if (adminProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Error: ${adminProvider.error}',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => adminProvider.fetchStats(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final stats = adminProvider.stats;
          if (stats == null) {
            return Center(
              child: Text(
                'No statistics available',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview Cards
                _buildOverviewSection(stats),
                SizedBox(height: 24),
                
                // User Role Distribution
                _buildUserRoleChart(stats),
                SizedBox(height: 24),
                
                // Test Score Distribution
                _buildTestScoreChart(stats),
                SizedBox(height: 24),
                
                // Video Views (simplified)
                _buildSimpleStatCard('Total Video Views', stats.videoViewStats['Total Views']?.toString() ?? 'N/A', Icons.videocam, Colors.orange),
                SizedBox(height: 24),
                
                // Vocabulary Learning (simplified)
                _buildSimpleStatCard('Total Vocabularies', stats.vocabularyLearningStats['Total Vocabularies']?.toString() ?? 'N/A', Icons.book, Colors.purple),
                SizedBox(height: 24),

                // Recent Activities
                _buildRecentActivitiesSection(stats),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewSection(AdminStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildOverviewCard(
              'Total Users',
              stats.totalUsers.toString(),
              Icons.people,
              Colors.blue,
            ),
            _buildOverviewCard(
              'Total Videos',
              stats.totalVideos.toString(),
              Icons.video_library,
              Colors.orange,
            ),
            _buildOverviewCard(
              'Total Tests',
              stats.totalTests.toString(),
              Icons.quiz,
              Colors.green,
            ),
            _buildOverviewCard(
              'Total Vocabularies',
              stats.totalVocabularies.toString(),
              Icons.book,
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: color),
          SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 28, color: color),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserRoleChart(AdminStats stats) {
    return _buildChartCard(
      'User Distribution by Role',
      Container(
        height: 200,
        child: PieChart(
          PieChartData(
            sections: stats.usersByRole.entries.map((entry) {
              final color = _getRoleColor(entry.key);
              return PieChartSectionData(
                color: color,
                value: entry.value.toDouble(),
                title: '${entry.key}\n${entry.value}',
                radius: 60,
                titleStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList(),
            sectionsSpace: 2,
            centerSpaceRadius: 40,
          ),
        ),
      ),
    );
  }

  Widget _buildTestScoreChart(AdminStats stats) {
    return _buildChartCard(
      'Test Score Distribution',
      Container(
        height: 200,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: stats.testScoreDistribution.values.isNotEmpty 
                ? stats.testScoreDistribution.values.reduce((a, b) => a > b ? a : b).toDouble() + 10
                : 100,
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final keys = stats.testScoreDistribution.keys.toList();
                    if (value.toInt() < keys.length) {
                      return Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          keys[value.toInt()],
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    }
                    return Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                    );
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            barGroups: stats.testScoreDistribution.entries.toList().asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.value.toDouble(),
                    color: AppTheme.primaryLight,
                    width: 20,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            chart,
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitiesSection(AdminStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activities',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        stats.recentActivities.isEmpty
            ? Center(
                child: Text(
                  'No recent activities.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: stats.recentActivities.length,
                itemBuilder: (context, index) {
                  final activity = stats.recentActivities[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(Icons.info_outline, color: Colors.blueAccent),
                      title: Text(activity.activity),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(activity.userName),
                          Text(activity.details ?? ''),
                          Text(DateFormat('MMM dd, yyyy HH:mm').format(activity.timestamp)),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'teacher':
        return Colors.orange;
      case 'student':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getVocabularyColor(String key) {
    switch (key) {
      case 'New Words':
        return Colors.blue;
      case 'Reviewed':
        return Colors.orange;
      case 'Mastered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}