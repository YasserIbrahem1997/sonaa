import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

class SupabaseRepository {
  final SupabaseClient _client = Supabase.instance.client;
  final _uuid = const Uuid();

  /// ✅ رفع ملف إلى Storage وإرجاع الرابط العام
  Future<String> uploadFile({
    required File file,
    required String bucketName,
    String? folder,
  }) async {
    try {
      final ext = p.extension(file.path);
      final fileName = '${_uuid.v4()}$ext';
      final path = folder != null ? '$folder/$fileName' : fileName;

      await _client.storage.from(bucketName).upload(path, file);
      final publicUrl = _client.storage.from(bucketName).getPublicUrl(path);
      return publicUrl;
    } on StorageException catch (e) {
      print('Storage error thhhhhis : ${e.message}');
      throw Exception('Storage error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown upload error: $e');
    }
  }

  /// ✅ إدخال إعلان جديد في جدول ads
  Future<void> createAd(Map<String, dynamic> adData) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // نضيف user_id في البيانات
      final dataWithUser = {
        ...adData,
        'user_id': user.id,
      };

      await _client.from('ads').insert(dataWithUser);
    } on PostgrestException catch (e) {
      print('Insert ad failed: ${e.message}');
      throw Exception('Insert ad failed: ${e.message}');
    } catch (e) {
      throw Exception('Unknown insert error: $e');
    }
  }

}
