import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../data/repositories/home_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository repository;
  StreamSubscription? _recentAdsSubscription;
  StreamSubscription? _featuredAdsSubscription;

  // Cache للبيانات
  final Map<String, dynamic> _cache = {};
  DateTime? _lastLoadTime;

  HomeCubit({required this.repository}) : super(const HomeState());

  /// ✅ تحميل البيانات مع Cache وتحسين الأداء
  Future<void> loadAllData() async {
    // إذا تم التحميل خلال آخر 30 ثانية، استخدم البيانات المخزنة
    if (_lastLoadTime != null &&
        DateTime.now().difference(_lastLoadTime!).inSeconds < 30 &&
        _cache.containsKey('categories')) {
      emit(state.copyWith(
        recentAds: _cache['recentAds'] ?? [],
        featuredAds: _cache['featuredAds'] ?? [],
        categories: _cache['categories'] ?? [],
        categoryCounts: _cache['categoryCounts'] ?? {},
        isLoading: false,
        isFeaturedLoading: false,
        isCategoriesLoading: false,
      ));
      return;
    }

    emit(state.copyWith(
      isLoading: true,
      isFeaturedLoading: true,
      isCategoriesLoading: true,
      error: null,
    ));

    try {
      // تحميل البيانات بالتوازي لسرعة أفضل
      final categoriesFuture = repository.fetchUniqueCategories();
      final countsFuture = repository.getCategoryCounts();

      // بدء الـ Streams فوراً
      _setupStreamSubscriptions();

      // انتظار البيانات الأساسية
      final results = await Future.wait([categoriesFuture, countsFuture]);
      final categories = results[0] as List<String>;
      final counts = results[1] as Map<String, int>;

      // حفظ في Cache
      _cache['categories'] = categories;
      _cache['categoryCounts'] = counts;
      _lastLoadTime = DateTime.now();

      emit(state.copyWith(
        categories: categories,
        categoryCounts: counts,
        isCategoriesLoading: false,
      ));

    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        isFeaturedLoading: false,
        isCategoriesLoading: false,
        error: e.toString(),
      ));
    }
  }

  void _setupStreamSubscriptions() {
    _recentAdsSubscription?.cancel();
    _recentAdsSubscription = repository.streamRecentAds(limit: 10).listen(
          (ads) {
        _cache['recentAds'] = ads;
        emit(state.copyWith(recentAds: ads, isLoading: false));
      },
      onError: (error) {
        emit(state.copyWith(isLoading: false, error: error.toString()));
      },
    );

    _featuredAdsSubscription?.cancel();
    _featuredAdsSubscription = repository.streamFeaturedAds(limit: 5).listen(
          (ads) {
        _cache['featuredAds'] = ads;
        emit(state.copyWith(featuredAds: ads, isFeaturedLoading: false));
      },
      onError: (error) {
        emit(state.copyWith(isFeaturedLoading: false, error: error.toString()));
      },
    );
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