import 'package:equatable/equatable.dart';
import '../../data/model/ad_model.dart';

class HomeState extends Equatable {
  final List<AdModel> recentAds;
  final List<AdModel> featuredAds;
  final List<String> categories; // ✅ الكاتيجوري من السابابيز
  final Map<String, int> categoryCounts;
  final bool isLoading;
  final bool isFeaturedLoading;
  final bool isCategoriesLoading;
  final String? error;

  const HomeState({
    this.recentAds = const [],
    this.featuredAds = const [],
    this.categories = const [],
    this.categoryCounts = const {},
    this.isLoading = false,
    this.isFeaturedLoading = false,
    this.isCategoriesLoading = false,
    this.error,
  });

  HomeState copyWith({
    List<AdModel>? recentAds,
    List<AdModel>? featuredAds,
    List<String>? categories,
    Map<String, int>? categoryCounts,
    bool? isLoading,
    bool? isFeaturedLoading,
    bool? isCategoriesLoading,
    String? error,
  }) {
    return HomeState(
      recentAds: recentAds ?? this.recentAds,
      featuredAds: featuredAds ?? this.featuredAds,
      categories: categories ?? this.categories,
      categoryCounts: categoryCounts ?? this.categoryCounts,
      isLoading: isLoading ?? this.isLoading,
      isFeaturedLoading: isFeaturedLoading ?? this.isFeaturedLoading,
      isCategoriesLoading: isCategoriesLoading ?? this.isCategoriesLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    recentAds,
    featuredAds,
    categories,
    categoryCounts,
    isLoading,
    isFeaturedLoading,
    isCategoriesLoading,
    error,
  ];
}