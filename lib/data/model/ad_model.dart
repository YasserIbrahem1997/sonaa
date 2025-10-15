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
  final bool featured;
  final List<String> images;
  final DateTime? createdAt;

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
    this.featured = false,
    this.images = const [],
    this.createdAt,
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
      featured: map['featured'] ?? map['is_featured'] ?? false,
      images: imagesList,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
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
      'featured': featured,
      'images': images,
    };
  }
}