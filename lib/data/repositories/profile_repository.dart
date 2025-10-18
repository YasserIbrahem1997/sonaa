import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/user_stats_model.dart';
import '../model/ad_model.dart';

class ProfileRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// ✅ جلب إحصائيات المستخدم
  Future<UserStatsModel> getUserStats() async {
    try {
      final userId = _client.auth.currentUser!.id;

      // عدد الإعلانات الكلي
      final totalAdsResponse = await _client
          .from('ads')
          .select('id')
          .eq('user_id', userId);

      final totalAds = (totalAdsResponse as List).length;

      // عدد الإعلانات النشطة (يمكن إضافة شرط للحالة لاحقاً)
      final activeAds = totalAds;

      // عدد المفضلة (سنفترض 0 الآن أو يمكن إضافة جدول favorites)
      final favoriteCount = 0;

      return UserStatsModel(
        totalAds: totalAds,
        activeAds: activeAds,
        favoriteCount: favoriteCount,
      );
    } catch (e) {
      print('❌ خطأ في جلب الإحصائيات: $e');
      return UserStatsModel();
    }
  }

  /// ✅ جلب إعلانات المستخدم
  Future<List<AdModel>> getUserAds() async {
    try {
      final userId = _client.auth.currentUser!.id;

      final response = await _client
          .from('ads')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => AdModel.fromMap(json))
          .toList();
    } catch (e) {
      print('❌ خطأ في جلب إعلانات المستخدم: $e');
      throw Exception('فشل جلب الإعلانات: $e');
    }
  }

  /// ✅ تحديث معلومات الملف الشخصي
  Future<void> updateProfile({
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      final userId = _client.auth.currentUser!.id;

      await _client.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': fullName,
            'phone_number': phoneNumber,
          },
        ),
      );
    } catch (e) {
      print('❌ خطأ في تحديث الملف الشخصي: $e');
      throw Exception('فشل تحديث الملف الشخصي: $e');
    }
  }

  /// ✅ حذف إعلان
  Future<void> deleteAd(String adId) async {
    try {
      await _client.from('ads').delete().eq('id', adId);
    } catch (e) {
      print('❌ خطأ في حذف الإعلان: $e');
      throw Exception('فشل حذف الإعلان: $e');
    }
  }
}