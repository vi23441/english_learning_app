class AdminStats {
  final int totalUsers;
  final int totalVideos;
  final int totalTests;
  final int totalVocabularies;
  final int totalFeedbacks;
  final Map<String, int> usersByRole;
  final Map<String, int> testScoreDistribution;
  final Map<String, int> videoViewStats;
  final Map<String, int> vocabularyLearningStats;
  final List<UserActivity> recentActivities;

  AdminStats({
    required this.totalUsers,
    required this.totalVideos,
    required this.totalTests,
    required this.totalVocabularies,
    required this.totalFeedbacks,
    required this.usersByRole,
    required this.testScoreDistribution,
    required this.videoViewStats,
    required this.vocabularyLearningStats,
    required this.recentActivities,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalUsers': totalUsers,
      'totalVideos': totalVideos,
      'totalTests': totalTests,
      'totalVocabularies': totalVocabularies,
      'totalFeedbacks': totalFeedbacks,
      'usersByRole': usersByRole,
      'testScoreDistribution': testScoreDistribution,
      'videoViewStats': videoViewStats,
      'vocabularyLearningStats': vocabularyLearningStats,
      'recentActivities': recentActivities.map((x) => x.toMap()).toList(),
    };
  }

  factory AdminStats.fromMap(Map<String, dynamic> map) {
    return AdminStats(
      totalUsers: map['totalUsers'] ?? 0,
      totalVideos: map['totalVideos'] ?? 0,
      totalTests: map['totalTests'] ?? 0,
      totalVocabularies: map['totalVocabularies'] ?? 0,
      totalFeedbacks: map['totalFeedbacks'] ?? 0,
      usersByRole: Map<String, int>.from(map['usersByRole'] ?? {}),
      testScoreDistribution: Map<String, int>.from(map['testScoreDistribution'] ?? {}),
      videoViewStats: Map<String, int>.from(map['videoViewStats'] ?? {}),
      vocabularyLearningStats: Map<String, int>.from(map['vocabularyLearningStats'] ?? {}),
      recentActivities: List<UserActivity>.from(
        map['recentActivities']?.map((x) => UserActivity.fromMap(x)) ?? [],
      ),
    );
  }
}

class UserActivity {
  final String userId;
  final String userName;
  final String activity;
  final DateTime timestamp;
  final String? details;

  UserActivity({
    required this.userId,
    required this.userName,
    required this.activity,
    required this.timestamp,
    this.details,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'activity': activity,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'details': details,
    };
  }

  factory UserActivity.fromMap(Map<String, dynamic> map) {
    return UserActivity(
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      activity: map['activity'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      details: map['details'],
    );
  }
}
