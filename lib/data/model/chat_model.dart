import 'ad_model.dart';

class ChatModel {
  final String id;
  final String adId;
  final String buyerId;
  final String sellerId;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final DateTime createdAt;

  // معلومات إضافية (optional)
  final AdModel? ad;
  final String? otherUserName;
  final String? otherUserAvatar;

  ChatModel({
    required this.id,
    required this.adId,
    required this.buyerId,
    required this.sellerId,
    this.lastMessage,
    this.lastMessageTime,
    required this.createdAt,
    this.ad,
    this.otherUserName,
    this.otherUserAvatar,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map['id'] ?? '',
      adId: map['ad_id'] ?? '',
      buyerId: map['buyer_id'] ?? '',
      sellerId: map['seller_id'] ?? '',
      lastMessage: map['last_message'],
      lastMessageTime: map['last_message_time'] != null
          ? DateTime.parse(map['last_message_time'])
          : null,
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      ad: map['ads'] != null ? AdModel.fromMap(map['ads']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ad_id': adId,
      'buyer_id': buyerId,
      'seller_id': sellerId,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}