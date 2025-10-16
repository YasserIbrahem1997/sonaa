import 'dart:convert';

class AdModel {
  final String id;
  final String title;
  final String description;
  final double? price;
  final String category;
  final String condition;
  final String location;
  final String phone;
  final String? email;
  final String userId; // ✅ أضف هذا الحقل

  final bool featured;
  final List<String> images;
  final DateTime? createdAt;
  final String? userName; // ✅ أضف اسم المستخدم
  final bool isFavorited; // ✅ إضافة حقل الإعجاب



  AdModel({
    required this.id,
    required this.title,
    required this.description,
    this.price,
    required this.category,
    required this.condition,
    required this.location,
    required this.phone,
    this.email,
    required this.userId, // ✅ إضافة

    this.featured = false,
    this.images = const [],
    this.createdAt,
    this.userName, // ✅ إضافة
    this.isFavorited = false, // ✅ قيمة افتراضية


  });

  // ✅ تحويل من Map إلى Object
  factory AdModel.fromMap(Map<String, dynamic> map) {
    // ✅ معالجة الـ images سواء String أو List
    List<String> imagesList = [];
    if (map['images'] != null) {
      if (map['images'] is String) {
        // لو String، حوّلها لـ List
        try {
          final decoded = jsonDecode(map['images']);
          imagesList = List<String>.from(decoded);
        } catch (e) {
          print('Error parsing images: $e');
        }
      } else if (map['images'] is List) {
        imagesList = List<String>.from(map['images']);
      }
    }

    return AdModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] != null ? (map['price'] as num).toDouble() : null,
      category: map['category'] ?? '',
      condition: map['condition'] ?? '',
      location: map['location'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      userId: map['user_id'] ?? '', // ✅ إضافة

      featured: map['featured'] ?? map['is_featured'] ?? false,
      images: imagesList,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      userName: map['user_name'] ?? map['profiles']?['username'], // ✅ إضافة
      isFavorited: map['is_favorited'] ?? map['favorites'] != null, // ✅ من الجدول الرئيسي أو الجدول المنفصل


    );
  }
  // ✅ تحويل من Object إلى Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'condition': condition,
      'location': location,
      'phone': phone,
      'email': email,
      'user_id': userId, // ✅ إضافة
      'featured': featured,
      'images': images,
      'is_favorited': isFavorited,

    };
  }

  // ✅ دالة لنسخ الـ AdModel مع تحديث حالة الإعجاب
  AdModel copyWith({
    bool? isFavorited,
  }) {
    return AdModel(
      id: id,
      title: title,
      description: description,
      price: price,
      condition: condition,
      location: location,
      images: images,
      phone: phone,
      email: email,
      userId: userId,
      featured: featured,
      createdAt: createdAt,
      category: category,
      userName: userName,
      isFavorited: isFavorited ?? this.isFavorited,
    );
  }
}
