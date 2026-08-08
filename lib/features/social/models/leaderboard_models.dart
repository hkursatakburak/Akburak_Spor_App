class LeaderboardUser {
  final String name;
  final String email;
  final int totalPoints;
  final String rank;
  final int longestStreak;

  LeaderboardUser({
    required this.name,
    required this.email,
    required this.totalPoints,
    required this.rank,
    required this.longestStreak,
  });

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      name: json['name'] ?? 'Sporcu',
      email: json['email'] ?? '',
      totalPoints: json['total_points'] ?? 0,
      rank: json['rank'] ?? 'Başlangıç',
      longestStreak: json['longest_streak'] ?? 0,
    );
  }
}
