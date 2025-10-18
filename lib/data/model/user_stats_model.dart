class UserStatsModel {
  final int totalAds;
  final int activeAds;
  final int favoriteCount;

const UserStatsModel({
    this.totalAds = 0,
    this.activeAds = 0,
    this.favoriteCount = 0,
  });

  factory UserStatsModel.fromMap(Map<String, dynamic> map) {
    return UserStatsModel(
      totalAds: map['total_ads'] ?? 0,
      activeAds: map['active_ads'] ?? 0,
      favoriteCount: map['favorite_count'] ?? 0,
    );
  }
}