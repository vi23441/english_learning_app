import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/app_export.dart';
import '../../providers/auth_provider.dart';
import '../../providers/test_provider.dart';
import '../../models/test_history.dart';

class TestHistoryScreen extends StatefulWidget {
  const TestHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TestHistoryScreen> createState() => _TestHistoryScreenState();
}

class _TestHistoryScreenState extends State<TestHistoryScreen> {
  late TestProvider testProvider;
  late AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    testProvider = Provider.of<TestProvider>(context, listen: false);
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    _loadTestHistory();
  }

  Future<void> _loadTestHistory() async {
    if (authProvider.user != null) {
      await testProvider.loadUserTestHistory(authProvider.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test History'),
      ),
      body: Consumer<TestProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          if (provider.testHistory.isEmpty) {
            return Center(child: Text('No test history found.'));
          }

          return ListView.builder(
            itemCount: provider.testHistory.length,
            itemBuilder: (context, index) {
              final history = provider.testHistory[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(history.testTitle),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Score: ${history.score}/${history.totalQuestions}'),
                      Text(
                        'Completed: ${DateFormat.yMd().add_jm().format(history.completedAt.toDate())}',
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // TODO: Navigate to test result details screen
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
