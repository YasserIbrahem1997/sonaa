import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/ad_model.dart';

class HomeRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// ✅ Real-time Stream للإعلانات الحديثة
  Stream<List<AdModel>> streamRecentAds({int limit = 10}) {
    return _client
        .from('ads')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(limit)
        .map((data) => data.map((json) => AdModel.fromMap(json)).toList());
  }

  /// ✅ Real-time Stream للإعلانات المميزة
  Stream<List<AdModel>> streamFeaturedAds({int limit = 5}) {
    return _client
        .from('ads')
        .stream(primaryKey: ['id'])
        .eq('featured', true)
        .order('created_at', ascending: false)
        .limit(limit)
        .map((data) => data.map((json) => AdModel.fromMap(json)).toList());
  }

  /// ✅ جلب الكاتيجوري الفريدة من قاعدة البيانات (مع تنظيفها)
  Future<List<String>> fetchUniqueCategories() async {
    try {
      final response = await _client
          .from('ads')
          .select('category')
          .order('category');

      // استخراج الكاتيجوري وتنظيفها
      final Set<String> uniqueCategories = {};

      for (final item in response as List) {
        final category = (item['category'] as String?)?.trim() ?? '';
        if (category.isNotEmpty) {
          // تحويل الكاتيجوري لـ Title Case (أول حرف Capital)
          final normalized = _normalizeCategory(category);
          uniqueCategories.add(normalized);
        }
      }

      return uniqueCategories.toList()..sort();
    } catch (e) {
      print('❌ خطأ في جلب الكاتيجوري: $e');
      return [];
    }
  }

  /// ✅ تنظيف وتوحيد الكاتيجوري المتشابهة
  String _normalizeCategory(String category) {
    // تحويل لـ lowercase وإزالة المسافات الزائدة
    final cleaned = category.trim().toLowerCase();

    // تصحيح الأخطاء الشائعة
    final Map<String, String> corrections = {
      'car': 'Cars',
      'cars': 'Cars',
      'real estate': 'Real Estate',
      'realestate': 'Real Estate',
      'job': 'Jobs',
      'jobs': 'Jobs',
      'electronic': 'Electronics',
      'electronics': 'Electronics',
      'mobile': 'Mobiles',
      'mobiles': 'Mobiles',
      'phone': 'Mobiles',
      'phones': 'Mobiles',
      'fashion': 'Fashion',
      'furniture': 'Furniture',
      'service': 'Services',
      'services': 'Services',
    };

    return corrections[cleaned] ?? _toTitleCase(cleaned);
  }

  /// ✅ تحويل النص لـ Title Case
  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// ✅ جلب كل الإعلانات (Recent Ads)
  Future<List<AdModel>> fetchRecentAds({int limit = 10}) async {
    try {
      final response = await _client
          .from('ads')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => AdModel.fromMap(json))
          .toList();
    } catch (e) {
      print('❌ خطأ في جلب الإعلانات: $e');
      throw Exception('فشل جلب الإعلانات: $e');
    }
  }

  /// ✅ جلب الإعلانات المميزة (Featured Ads)
  Future<List<AdModel>> fetchFeaturedAds({int limit = 5}) async {
    try {
      final response = await _client
          .from('ads')
          .select()
          .eq('featured', true)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => AdModel.fromMap(json))
          .toList();
    } catch (e) {
      print('❌ خطأ في جلب الإعلانات المميزة: $e');
      throw Exception('فشل جلب الإعلانات المميزة: $e');
    }
  }

  /// ✅ جلب الإعلانات حسب الفئة (Category)
  Future<List<AdModel>> fetchAdsByCategory(String category, {int limit = 20}) async {
    try {
      final response = await _client
          .from('ads')
          .select()
          .eq('category', category)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => AdModel.fromMap(json))
          .toList();
    } catch (e) {
      print('❌ خطأ في جلب إعلانات الفئة: $e');
      throw Exception('فشل جلب إعلانات الفئة: $e');
    }
  }

  /// ✅ البحث في الإعلانات
  Future<List<AdModel>> searchAds(String query) async {
    try {
      final response = await _client
          .from('ads')
          .select()
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .order('created_at', ascending: false)
          .limit(20);

      return (response as List)
          .map((json) => AdModel.fromMap(json))
          .toList();
    } catch (e) {
      print('❌ خطأ في البحث: $e');
      throw Exception('فشل البحث: $e');
    }
  }

  /// ✅ عدد الإعلانات في كل فئة (للـ Categories)
  Future<Map<String, int>> getCategoryCounts() async {
    try {
      final categories = [
        'Cars',
        'Real Estate',
        'Jobs',
        'Electronics',
        'Mobiles',
        'Fashion',
        'Furniture',
        'Services'
      ];

      final Map<String, int> counts = {};

      for (final category in categories) {
        final response = await _client
            .from('ads')
            .select('id')
            .eq('category', category)
            .count();

        counts[category] = response.count;
      }

      return counts;
    } catch (e) {
      print('❌ خطأ في جلب عدد الفئات: $e');
      return {};
    }
  }
}