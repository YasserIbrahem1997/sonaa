
import 'dart:io';

import 'package:equatable/equatable.dart';

class AddAdState extends Equatable {
  final List<File> images;
  final String title;
  final String description;
  final String priceText;
  final String category;
  final String condition;
  final String location;
  final String phone;
  final String email;
  final bool featured;
  final bool loading;
  final bool success;
  final String? error;

  const AddAdState({
    this.images = const [],
    this.title = '',
    this.description = '',
    this.priceText = '',
    this.category = '',
    this.condition = '',
    this.location = '',
    this.phone = '',
    this.email = '',
    this.featured = false,
    this.loading = false,
    this.success = false,
    this.error,
  });

  AddAdState copyWith({
    List<File>? images,
    String? title,
    String? description,
    String? priceText,
    String? category,
    String? condition,
    String? location,
    String? phone,
    String? email,
    bool? featured,
    bool? loading,
    bool? success,
    String? error,
  }) {
    return AddAdState(
      images: images ?? this.images,
      title: title ?? this.title,
      description: description ?? this.description,
      priceText: priceText ?? this.priceText,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      featured: featured ?? this.featured,
      loading: loading ?? this.loading,
      success: success ?? this.success,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    images,
    title,
    description,
    priceText,
    category,
    condition,
    location,
    phone,
    email,
    featured,
    loading,
    success,
    error,
  ];
}
