import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../data/model/ad_model.dart';
import '../../data/repositories/add_ad_repository.dart';
import 'ad_state.dart';

class AddAdViewModel extends Cubit<AddAdState> {
  final SupabaseRepository repo;
  final ImagePicker _picker = ImagePicker();
  final _uuid = const Uuid();
  final SupabaseClient client = Supabase.instance.client;
  AddAdViewModel({required this.repo}) : super(const AddAdState());

  // pick multiple images (up to 10)
  Future<void> pickImages() async {
    try {
      final picked = await _picker.pickMultiImage(imageQuality: 75);
      if (picked == null) return;
      final files = picked.map((x) => File(x.path)).toList();

      final newList = [...state.images];
      for (final f in files) {
        if (newList.length >= 10) break;
        newList.add(f);
      }
      emit(state.copyWith(images: newList));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  // remove image by index
  void removeImage(int index) {
    final list = [...state.images];
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      emit(state.copyWith(images: list));
    }
  }

  void setTitle(String v) => emit(state.copyWith(title: v));
  void setDescription(String v) => emit(state.copyWith(description: v));
  void setPrice(String v) => emit(state.copyWith(priceText: v));
  void setCategory(String v) => emit(state.copyWith(category: v));
  void setCondition(String v) => emit(state.copyWith(condition: v));
  void setLocation(String v) => emit(state.copyWith(location: v));
  void setPhone(String v) => emit(state.copyWith(phone: v));
  void setEmail(String v) => emit(state.copyWith(email: v));
  void setFeatured(bool v) => emit(state.copyWith(featured: v));

  // Validate minimal form
  bool validate() {
    if (state.title.trim().isEmpty) {
      emit(state.copyWith(error: 'Title is required'));
      return false;
    }
    if (state.category.trim().isEmpty) {
      emit(state.copyWith(error: 'Category is required'));
      return false;
    }
    if (state.condition.trim().isEmpty) {
      emit(state.copyWith(error: 'Condition is required'));
      return false;
    }
    if (state.location.trim().isEmpty) {
      emit(state.copyWith(error: 'Location is required'));
      return false;
    }

    if (state.description.trim().length < 20) {
      emit(state.copyWith(error: 'Description must be at least 20 characters'));
      return false;
    }
    return true;
  }

  // Upload images to supabase storage and return list of urls
  Future<List<String>> _uploadAllImages() async {
    final bucket = 'ads'; // تأكد إنه موجود في Supabase
    final uploadedUrls = <String>[];
    for (final f in state.images) {
      final url = await repo.uploadFile(file: f, bucketName: bucket, folder: _uuid.v4());
      uploadedUrls.add(url);
    }
    return uploadedUrls;
  }

  // Main publish method
  Future<void> publishAd() async {
    if (!validate()) return;

    emit(state.copyWith(loading: true, error: null));

    try {
      final user = client.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // ✅ تحقق من وجود البيانات المهمة
      if (state.images.isEmpty) {
        throw Exception('Please add at least one image');
      }
      if (state.priceText.isEmpty) {
        throw Exception('Price is required');
      }

      // ✅ لو في بيانات مستخدم من Supabase Auth
      final email = user.email ?? state.email;
      final phone = user.userMetadata?['phone_number'] ?? "Not Found Number";

      if ((email == null || email.isEmpty) && (phone == null || phone.isEmpty)) {
        throw Exception('Missing contact info (email or phone)');
      }

      // ✅ رفع الصور
      final imageUrls = await _uploadAllImages();

      // ✅ إنشاء الإعلان
      final ad = AdModel(
        id: _uuid.v4(),
        title: state.title.trim(),
        description: state.description.trim(),
        price: double.tryParse(state.priceText),
        category: state.category,
        condition: state.condition,
        location: state.location,
        phone: phone,
        email: email,
        featured: state.featured,
        images: imageUrls,
      );

      await repo.createAd(ad.toMap());

      emit(state.copyWith(loading: false, success: true));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

}
