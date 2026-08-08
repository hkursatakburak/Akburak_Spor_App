import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/social_service.dart';
import '../models/leaderboard_models.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<LeaderboardUser>> _leaderboardFuture;
  String _currentUserName = "";

  @override
  void initState() {
    super.initState();
    _leaderboardFuture = SocialService().getLeaderboard();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserName = prefs.getString('user_name') ?? "Sporcu";
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F12) : const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text("Liderlik Tablosu 🏆", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<List<LeaderboardUser>>(
        future: _leaderboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.tealAccent),
            );
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Yüklenirken bir hata oluştu."));
          }

          final List<LeaderboardUser> users = snapshot.data ?? [];
          if (users.isEmpty) {
            return const Center(child: Text("Liderlik tablosu henüz boş."));
          }

          // Separate top 3 and others
          final topThree = users.take(3).toList();
          final remainingUsers = users.skip(3).toList();

          // Find current user rank
          int currentUserRankIndex = users.indexWhere((u) => u.name.toLowerCase() == _currentUserName.toLowerCase());
          LeaderboardUser currentUserInfo;
          int currentUserRankNumber;
          if (currentUserRankIndex != -1) {
            currentUserInfo = users[currentUserRankIndex];
            currentUserRankNumber = currentUserRankIndex + 1;
          } else {
            currentUserInfo = LeaderboardUser(
              name: _currentUserName,
              email: '',
              totalPoints: 50,
              rank: 'Başlangıç',
              longestStreak: 1,
            );
            currentUserRankNumber = 11;
          }

          return Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 12),
                  // Podium for Top 3
                  _buildPodium(topThree),
                  const SizedBox(height: 24),
                  
                  // Rank 4-10 List View
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF16161A) : Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 90),
                        itemCount: remainingUsers.length,
                        separatorBuilder: (context, index) => Divider(color: Colors.grey.withOpacity(0.1)),
                        itemBuilder: (context, index) {
                          final user = remainingUsers[index];
                          final rankNumber = index + 4;
                          return _buildUserRow(user, rankNumber, isDark);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              
              // Sticky User Rank Footer
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildStickyFooter(currentUserInfo, currentUserRankNumber, isDark),
              ),
            ],
          );
        },
      ),
    );
  }

  // Top 3 Podium Widget
  Widget _buildPodium(List<LeaderboardUser> topThree) {
    if (topThree.isEmpty) return const SizedBox.shrink();

    final hasFirst = topThree.isNotEmpty;
    final hasSecond = topThree.length > 1;
    final hasThird = topThree.length > 2;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // #2 Place (Left side)
        if (hasSecond)
          _buildPodiumAvatar(
            user: topThree[1],
            rank: 2,
            avatarSize: 65,
            borderColor: const Color(0xFFC0C0C0),
            glowColor: Colors.blueGrey.withOpacity(0.4),
          ),

        // #1 Place (Center, larger)
        if (hasFirst)
          _buildPodiumAvatar(
            user: topThree[0],
            rank: 1,
            avatarSize: 85,
            borderColor: const Color(0xFFFFD700),
            glowColor: Colors.amberAccent.withOpacity(0.6),
          ),

        // #3 Place (Right side)
        if (hasThird)
          _buildPodiumAvatar(
            user: topThree[2],
            rank: 3,
            avatarSize: 60,
            borderColor: const Color(0xFFCD7F32),
            glowColor: Colors.brown.withOpacity(0.4),
          ),
      ],
    );
  }

  // Podium Avatar with Glowing Ring and Badge
  Widget _buildPodiumAvatar({
    required LeaderboardUser user,
    required int rank,
    required double avatarSize,
    required Color borderColor,
    required Color glowColor,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (rank == 1)
          const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 30)
        else
          const SizedBox(height: 30),
        const SizedBox(height: 6),
        
        // Avatar Ring with Glow
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: glowColor,
                blurRadius: 15,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CircleAvatar(
                radius: avatarSize / 2,
                backgroundColor: borderColor,
                child: CircleAvatar(
                  radius: (avatarSize / 2) - 3,
                  backgroundColor: const Color(0xFF2C2C2C),
                  child: Text(
                    user.name.substring(0, 1),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: avatarSize * 0.35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              // Rank Tag Overlay
              Container(
                transform: Matrix4.translationValues(0, 10, 0),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "#$rank",
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          user.name.split(' ').first,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(
          "${user.totalPoints} P",
          style: const TextStyle(
            color: Colors.tealAccent,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        if (user.longestStreak >= 5) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 14),
              Text(
                "${user.longestStreak} Gün",
                style: const TextStyle(color: Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // Row for 4-10 user lists
  Widget _buildUserRow(LeaderboardUser user, int rank, bool isDark) {
    final showFlame = user.longestStreak >= 5;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Rank ID
          SizedBox(
            width: 32,
            child: Text(
              "$rank",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
          ),
          
          // User Initial Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.tealAccent.withOpacity(0.15),
            child: Text(
              user.name.substring(0, 1),
              style: const TextStyle(
                color: Colors.tealAccent,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Name and Belt
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  user.rank,
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
          
          // Flame Streak Icon
          if (showFlame) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
                  const SizedBox(width: 2),
                  Text(
                    "${user.longestStreak}",
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Points
          Text(
            "${user.totalPoints} Puan",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // Sticky footer ranking summary
  Widget _buildStickyFooter(LeaderboardUser user, int rank, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(color: Colors.tealAccent.withOpacity(0.2), width: 1.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Text(
              "#$rank",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.tealAccent,
              ),
            ),
            const SizedBox(width: 16),
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.tealAccent,
              child: Text(
                user.name.substring(0, 1),
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Senin Sıran",
                    style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
            Text(
              "${user.totalPoints} Puan",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.tealAccent),
            ),
          ],
        ),
      ),
    );
  }
}
