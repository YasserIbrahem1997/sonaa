import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../data/repositories/home_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository repository;
  StreamSubscription? _recentAdsSubscription;
  StreamSubscription? _featuredAdsSubscription;

  HomeCubit({required this.repository}) : super(const HomeState());

  /// ✅ تحميل كل البيانات مع Real-time Streaming
  Future<void> loadAllData() async {
    emit(state.copyWith(
      isLoading: true,
      isFeaturedLoading: true,
      isCategoriesLoading: true,
      error: null,
    ));

    try {
      // 1. جلب الكاتيجوري من السابابيز
      final categories = await repository.fetchUniqueCategories();

      // 2. جلب عدد الإعلانات لكل فئة
      final counts = await repository.getCategoryCounts();

      emit(state.copyWith(
        categories: categories,
        categoryCounts: counts,
        isCategoriesLoading: false,
      ));

      // 3. الاشتراك في Real-time للإعلانات الحديثة
      _recentAdsSubscription?.cancel();
      _recentAdsSubscription = repository.streamRecentAds(limit: 10).listen(
            (ads) {
          emit(state.copyWith(recentAds: ads, isLoading: false));
        },
        onError: (error) {
          emit(state.copyWith(isLoading: false, error: error.toString()));
        },
      );

      // 4. الاشتراك في Real-time للإعلانات المميزة
      _featuredAdsSubscription?.cancel();
      _featuredAdsSubscription = repository.streamFeaturedAds(limit: 5).listen(
            (ads) {
          emit(state.copyWith(featuredAds: ads, isFeaturedLoading: false));
        },
        onError: (error) {
          emit(state.copyWith(isFeaturedLoading: false, error: error.toString()));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        isFeaturedLoading: false,
        isCategoriesLoading: false,
        error: e.toString(),
      ));
    }
  }

  /// ✅ البحث في الإعلانات
  Future<void> searchAds(String query) async {
    if (query.trim().isEmpty) {
      await loadAllData();
      return;
    }

    emit(state.copyWith(isLoading: true));
    try {
      final results = await repository.searchAds(query);
      emit(state.copyWith(recentAds: results, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// ✅ جلب إعلانات فئة معينة
  Future<void> loadCategoryAds(String category) async {
    emit(state.copyWith(isLoading: true));
    try {
      final ads = await repository.fetchAdsByCategory(category, limit: 20);
      emit(state.copyWith(recentAds: ads, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _recentAdsSubscription?.cancel();
    _featuredAdsSubscription?.cancel();
    return super.close();
  }
}