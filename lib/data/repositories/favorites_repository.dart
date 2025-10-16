import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// ✅ إضافة إعلان للمفضلة
  Future<void> addToFavorites(String adId) async {
    try {
      final currentUserId = _client.auth.currentUser!.id;

      await _client
          .from('favorites')
          .insert({
        'user_id': currentUserId,
        'ad_id': adId,
      })
          .select()
          .single();

    } catch (e) {
      print('❌ Error adding to favorites: $e');
      throw Exception('فشل إضافة للمفضلة: $e');
    }
  }

  /// ✅ إزالة إعلان من المفضلة
  Future<void> removeFromFavorites(String adId) async {
    try {
      final currentUserId = _client.auth.currentUser!.id;

      await _client
          .from('favorites')
          .delete()
          .eq('user_id', currentUserId)
          .eq('ad_id', adId);

    } catch (e) {
      print('❌ Error removing from favorites: $e');
      throw Exception('فشل إزالة من المفضلة: $e');
    }
  }

  /// ✅ التحقق إذا الإعلان في المفضلة
  Future<bool> isAdFavorited(String adId) async {
    try {
      final currentUserId = _client.auth.currentUser!.id;

      final response = await _client
          .from('favorites')
          .select()
          .eq('user_id', currentUserId)
          .eq('ad_id', adId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('❌ Error checking favorite: $e');
      return false;
    }
  }

  /// ✅ جلب جميع المفضلة للمستخدم
  Future<List<String>> getUserFavorites() async {
    try {
      final currentUserId = _client.auth.currentUser!.id;

      final response = await _client
          .from('favorites')
          .select('ad_id')
          .eq('user_id', currentUserId);

      return (response as List)
          .map((item) => item['ad_id'] as String)
          .toList();
    } catch (e) {
      print('❌ Error getting favorites: $e');
      return [];
    }
  }

  /// ✅ Real-time stream للمفضلة
  Stream<List<String>> streamUserFavorites() {
    final currentUserId = _client.auth.currentUser!.id;

    return _client
        .from('favorites')
        .stream(primaryKey: ['id'])
        .eq('user_id', currentUserId)
        .map((data) => data.map((item) => item['ad_id'] as String).toList());
  }
}