import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/chat_model.dart';
import '../model/message_model.dart';

class ChatRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// ✅ إنشاء أو جلب Chat موجود
  Future<ChatModel> getOrCreateChat({
    required String adId,
    required String sellerId,
  }) async {
    try {
      final currentUserId = _client.auth.currentUser!.id;

      // محاولة جلب Chat موجود
      final existing = await _client
          .from('chats')
          .select('*, ads(*)')
          .eq('ad_id', adId)
          .eq('buyer_id', currentUserId)
          .eq('seller_id', sellerId)
          .maybeSingle();

      if (existing != null) {
        return ChatModel.fromMap(existing);
      }

      // إنشاء Chat جديد
      final newChat = await _client
          .from('chats')
          .insert({
        'ad_id': adId,
        'buyer_id': currentUserId,
        'seller_id': sellerId,
      })
          .select('*, ads(*)')
          .single();

      return ChatModel.fromMap(newChat);
    } catch (e) {
      print('❌ خطأ في getOrCreateChat: $e');
      throw Exception('فشل إنشاء المحادثة: $e');
    }
  }

  /// ✅ Real-time Stream للرسائل - الإصدار المحسن
  Stream<List<MessageModel>> streamMessages(String chatId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at')
        .map((data) {
      print('📨 New messages received: ${data.length} messages');
      return data.map((json) => MessageModel.fromMap(json)).toList();
    });
  }

  /// ✅ إرسال رسالة مع تحديث Real-time
  Future<MessageModel> sendMessage({
    required String chatId,
    required String text,
    String? imageUrl,
  }) async {
    try {
      final currentUserId = _client.auth.currentUser!.id;

      final response = await _client
          .from('messages')
          .insert({
        'chat_id': chatId,
        'sender_id': currentUserId,
        'text': text,
        'image_url': imageUrl,
        'is_read': false,
      })
          .select()
          .single();

      // ✅ تحديث last_message في الـ chat
      await _client
          .from('chats')
          .update({
        'last_message': text,
        'last_message_time': DateTime.now().toIso8601String(),
      })
          .eq('id', chatId);

      print('✅ Message sent successfully: $text');
      return MessageModel.fromMap(response);
    } catch (e) {
      print('❌ خطأ في إرسال الرسالة: $e');
      throw Exception('فشل إرسال الرسالة: $e');
    }
  }

  /// ✅ جلب الرسائل الحالية (للتأكد من البيانات)
  Future<List<MessageModel>> getMessages(String chatId) async {
    try {
      final response = await _client
          .from('messages')
          .select()
          .eq('chat_id', chatId)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => MessageModel.fromMap(json))
          .toList();
    } catch (e) {
      print('❌ خطأ في جلب الرسائل: $e');
      throw Exception('فشل جلب الرسائل: $e');
    }
  }

  /// ✅ تحديد الرسائل كـ مقروءة
  Future<void> markMessagesAsRead(String chatId) async {
    try {
      final currentUserId = _client.auth.currentUser!.id;

      await _client
          .from('messages')
          .update({'is_read': true})
          .eq('chat_id', chatId)
          .neq('sender_id', currentUserId)
          .eq('is_read', false);

      print('✅ Messages marked as read');
    } catch (e) {
      print('❌ خطأ في تحديث حالة القراءة: $e');
    }
  }
  String getCurrentUserId() {
    return _client.auth.currentUser!.id;
  }
  /// ✅ جلب جميع المحادثات للمستخدم الحالي
  Future<List<ChatModel>> fetchUserChats() async {
    try {
      final currentUserId = _client.auth.currentUser!.id;

      final response = await _client
          .from('chats')
          .select('*, ads(*)')
          .or('buyer_id.eq.$currentUserId,seller_id.eq.$currentUserId')
          .order('last_message_time', ascending: false);

      return (response as List)
          .map((json) => ChatModel.fromMap(json))
          .toList();
    } catch (e) {
      print('❌ خطأ في جلب المحادثات: $e');
      throw Exception('فشل جلب المحادثات: $e');
    }
  }
}