import 'package:equatable/equatable.dart';
import '../../data/model/user_stats_model.dart';
import '../../data/model/ad_model.dart';

class ProfileState extends Equatable {
  final UserStatsModel stats;
  final List<AdModel> userAds;
  final bool isLoading;
  final String? error;

  const ProfileState({
    this.stats = const UserStatsModel(),
    this.userAds = const [],
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    UserStatsModel? stats,
    List<AdModel>? userAds,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      stats: stats ?? this.stats,
      userAds: userAds ?? this.userAds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [stats, userAds, isLoading, error];
}